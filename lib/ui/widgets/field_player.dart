import 'package:flutter/material.dart';

class FieldPlayer extends StatelessWidget {
  final String name;
  final String? clue;
  final bool isMyTurn;
  final bool isTurnOfThisPlayer;
  final Function(String) onClueSubmitted;

  const FieldPlayer({
    super.key,
    required this.name,
    this.clue,
    required this.isMyTurn,
    required this.isTurnOfThisPlayer,
    required this.onClueSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    final hasClue = clue != null && clue!.isNotEmpty;

    // Glowing effect for the player whose turn it is
    final playerAvatar = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isTurnOfThisPlayer ? [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 15.0,
            spreadRadius: 2.0,
          )
        ] : [],
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.blue.shade800,
        child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Clue bubble or input field
        if (hasClue)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(clue!, style: const TextStyle(color: Colors.black, fontSize: 16)),
          ),
        if (!hasClue && isMyTurn)
          SizedBox(
            width: 180,
            child: TextField(
              controller: textController,
              textAlign: TextAlign.center,
              maxLength: 30,
              decoration: InputDecoration(
                hintText: 'Es tu turno...',
                filled: true,
                fillColor: Colors.white,
                counterText: "",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
              onSubmitted: onClueSubmitted,
            ),
          ),
         if (!hasClue && !isMyTurn && isTurnOfThisPlayer)
           Text('$name está pensando...', style: const TextStyle(color: Colors.white70)),

        const SizedBox(height: 8),
        playerAvatar,
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
