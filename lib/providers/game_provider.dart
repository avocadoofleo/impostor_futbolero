import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impostor_futbolero/data/models/game_model.dart';
import 'package:impostor_futbolero/data/services/firebase_service.dart';
import 'package:uuid/uuid.dart';

final gameStreamProvider = StreamProvider.autoDispose.family<Game, String>((ref, gameId) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getGameStream(gameId);
});

final gameNotifierProvider = Provider.autoDispose((ref) {
  return GameNotifier(ref);
});

class GameNotifier {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  GameNotifier(this._ref);

  String? get _currentUserId => _ref.read(firebaseServiceProvider).currentUserId;

  Future<void> startCluePhase(String gameId) async {
    await _firestore.collection('games').doc(gameId).update({
      'status': 'clue_giving',
      'currentTurnIndex': 0,
    });
  }

  // --- ROBUST, TRANSACTIONAL SUBMIT CLUE LOGIC ---
  Future<void> submitClue(String gameId, String clue) async {
    if (_currentUserId == null) return;

    final gameRef = _firestore.collection('games').doc(gameId);

    await _firestore.runTransaction((transaction) async {
      // 1. Read the current game state atomically
      final freshDoc = await transaction.get(gameRef);
      if (!freshDoc.exists) throw Exception("Game not found");

      final game = Game.fromFirestore(freshDoc);

      // 2. Double-check all conditions before writing
      if (game.status != 'clue_giving') throw Exception("Not in clue giving phase.");
      if (game.players[game.currentTurnIndex].id != _currentUserId) throw Exception("Not your turn.");
      if (game.clues.containsKey(_currentUserId)) throw Exception("You have already submitted a clue.");

      // 3. All checks passed, prepare the updates
      final newClues = Map<String, String>.from(game.clues)..putIfAbsent(_currentUserId!, () => clue);
      final updates = <String, dynamic>{'clues': newClues};

      // 4. Decide if it's the next turn or next phase
      if (game.currentTurnIndex + 1 >= game.players.length) {
        // Last player, move to discussion
        updates['status'] = 'discussion';
        updates['discussionStartedAt'] = FieldValue.serverTimestamp();
      } else {
        // Next player's turn
        updates['currentTurnIndex'] = FieldValue.increment(1);
      }

      // 5. Write all changes in a single atomic operation
      transaction.update(gameRef, updates);
    });
  }

  Future<void> sendMessage(String gameId, String playerName, String message) async {
    if (_currentUserId == null || message.trim().isEmpty) return;
    final messageData = {
      'id': _uuid.v4(),
      'playerId': _currentUserId,
      'playerName': playerName,
      'message': message.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('games').doc(gameId).update({
      'messages': FieldValue.arrayUnion([messageData])
    });
  }

  Future<void> submitVote(String gameId, String targetPlayerId) async {
    if (_currentUserId == null) return;
    await _firestore.collection('games').doc(gameId).update({
      'votes.$_currentUserId': targetPlayerId,
    });
  }

  Future<void> nextRound(String gameId) async {
    await _firestore.collection('games').doc(gameId).update({
      'status': 'clue_giving',
      'currentTurnIndex': 0,
      'votes': {},
      'clues': {},
      'messages': [],
    });
  }
}
