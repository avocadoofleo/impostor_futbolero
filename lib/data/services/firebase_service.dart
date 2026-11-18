import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impostor_futbolero/data/models/game_model.dart';
import 'package:impostor_futbolero/data/models/player_model.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService(FirebaseFirestore.instance, FirebaseAuth.instance);
});

class FirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseService(this._firestore, this._auth);

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<Game> getGameStream(String gameId) {
    return _firestore
        .collection('games')
        .doc(gameId)
        .snapshots()
        .map((doc) => Game.fromFirestore(doc));
  }

  // --- NEW, ROBUST & CORRECTED MATCHMAKING LOGIC ---
  Future<String> findOrCreateGame(String playerName) async {
    final String? userId = currentUserId;
    if (userId == null) throw Exception("User not authenticated!");

    final gamesRef = _firestore.collection('games');
    const maxPlayers = 5;

    // Step 1: Query for open games (this is a non-atomic "dirty" read)
    final querySnapshot = await gamesRef
        .where('status', isEqualTo: 'waiting')
        .where('playerCount', isLessThan: maxPlayers)
        .limit(1)
        .get();

    // Step 2: If a potential game is found, try to join it atomically.
    if (querySnapshot.docs.isNotEmpty) {
      final gameDocRef = querySnapshot.docs.first.reference;
      try {
        // The transaction only operates on a specific, known document.
        final gameId = await _firestore.runTransaction<String>((transaction) async {
          // Re-read the document INSIDE the transaction for a guaranteed fresh state.
          final freshDoc = await transaction.get(gameDocRef);
          if (!freshDoc.exists) throw Exception("Game was deleted just now.");

          final gameData = freshDoc.data()!;
          if (gameData['playerCount'] >= maxPlayers) throw Exception("Game is full.");

          // The game has space! Let's join.
          final newPlayer = Player(id: userId, name: playerName, isHost: false, isAlive: true);
          final List<dynamic> playersList = gameData['players'];
          playersList.add(newPlayer.toMap());

          var updates = <String, dynamic>{
            'players': playersList,
            'playerCount': FieldValue.increment(1),
          };

          // CRITICAL FIX: Only start the game if the room is now FULL.
          if (playersList.length == maxPlayers) {
            final List<Player> currentPlayers = playersList.map((p) => Player.fromMap(p)).toList();
            final impostor = currentPlayers[Random().nextInt(currentPlayers.length)];
            
            updates.addAll({
              'status': 'role_reveal',
              'startedAt': FieldValue.serverTimestamp(),
              'impostorId': impostor.id,
              'footballer': _getRandomFootballer(),
              'currentTurnIndex': 0, // Initialize turn index
            });
          }

          transaction.update(gameDocRef, updates);
          return gameDocRef.id;
        });
        return gameId;
      } catch (e) {
        // This is an expected failure if two players race to join the last spot.
        // We'll just fall through and create a new game.
        print("Could not join game. This is normal if it was a race. Creating new game. Reason: $e");
      }
    }

    // Step 3: If no game was found or joining failed, create a new one.
    final newGameRef = gamesRef.doc();
    final newPlayer = Player(id: userId, name: playerName, isHost: true, isAlive: true);
    final initialData = {
      'gameId': newGameRef.id,
      'status': 'waiting',
      'players': [newPlayer.toMap()],
      'playerCount': 1,
      'createdAt': FieldValue.serverTimestamp(),
      'clues': {},
      'votes': {},
      'messages': [],
      'eliminatedPlayers': [],
      'currentTurnIndex': 0,
    };
    await newGameRef.set(initialData);
    return newGameRef.id;
  }

  String _getRandomFootballer() {
    const footballers = [
      'Lionel Messi', 'Cristiano Ronaldo', 'Neymar Jr', 'Kylian Mbappé',
      'Robert Lewandowski', 'Kevin De Bruyne', 'Luka Modrić', 'Erling Haaland'
    ];
    return footballers[Random().nextInt(footballers.length)];
  }
}
