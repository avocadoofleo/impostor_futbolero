import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:impostor_futbolero/data/models/player_model.dart';
import 'package:impostor_futbolero/data/models/message_model.dart';

// Updated enums for the new flow
enum GameStatus { waiting, role_reveal, clue_giving, discussion, voting, results, finished }

class Game {
  final String gameId;
  final String status;
  final String? footballer;
  final String? impostorId;
  final List<Player> players;
  final Map<String, String> clues;
  final Map<String, String> votes;
  final List<ChatMessage> messages;
  final List<String> eliminatedPlayers;
  final String? lastEliminatedId;
  final String? winner; 
  final DateTime? discussionStartedAt;
  final DateTime? votingStartedAt;
  final int currentTurnIndex; // NEW: Tracks whose turn it is to give a clue

  Game({
    required this.gameId,
    required this.status,
    this.footballer,
    this.impostorId,
    required this.players,
    required this.clues,
    required this.votes,
    required this.messages,
    required this.eliminatedPlayers,
    this.lastEliminatedId,
    this.winner,
    this.discussionStartedAt,
    this.votingStartedAt,
    this.currentTurnIndex = 0,
  });

  factory Game.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return Game(
      gameId: doc.id,
      status: data['status'] ?? 'waiting',
      footballer: data['footballer'],
      impostorId: data['impostorId'],
      players: (data['players'] as List<dynamic>? ?? [])
          .map((playerMap) => Player.fromMap(playerMap as Map<String, dynamic>))
          .toList(),
      clues: Map<String, String>.from(data['clues'] ?? {}),
      votes: Map<String, String>.from(data['votes'] ?? {}),
      messages: (data['messages'] as List<dynamic>? ?? [])
          .map((msgMap) => ChatMessage.fromMap(msgMap as Map<String, dynamic>))
          .toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp)),
      eliminatedPlayers: List<String>.from(data['eliminatedPlayers'] ?? []),
      lastEliminatedId: data['lastEliminatedId'],
      winner: data['winner'],
      discussionStartedAt: (data['discussionStartedAt'] as Timestamp?)?.toDate(),
      votingStartedAt: (data['votingStartedAt'] as Timestamp?)?.toDate(),
      currentTurnIndex: data['currentTurnIndex'] ?? 0, // Load turn index
    );
  }
}
