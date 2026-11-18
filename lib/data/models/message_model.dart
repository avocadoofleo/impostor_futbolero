import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single message in the in-game chat.
class ChatMessage {
  final String id;
  final String playerId;
  final String playerName;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      playerId: map['playerId'] ?? '',
      playerName: map['playerName'] ?? 'Desconocido',
      message: map['message'] ?? '',
      // Timestamps from Firestore need to be converted to DateTime
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
