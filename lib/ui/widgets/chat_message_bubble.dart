import 'package:flutter/material.dart';
import 'package:impostor_futbolero/data/models/message_model.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const ChatMessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Card(
        color: isMe ? Colors.blue[100] : Colors.grey[300],
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                isMe ? 'Tú' : message.playerName,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(message.message, style: const TextStyle(color: Colors.black87, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
