import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VotingPhaseScreen extends StatefulWidget {
  final List<String> players;
  final int currentPlayerIndex;
  final String secretWord;
  final int impostorIndex;
  final Map<int, int> votes; // Map<VotedPlayerIndex, VoteCount>

  const VotingPhaseScreen({
    super.key,
    required this.players,
    required this.currentPlayerIndex,
    required this.secretWord,
    required this.impostorIndex,
    required this.votes,
  });

  @override
  State<VotingPhaseScreen> createState() => _VotingPhaseScreenState();
}

class _VotingPhaseScreenState extends State<VotingPhaseScreen> {
  int? _selectedPlayerIndex;
  bool _voteConfirmed = false;

  void _submitVote() {
    if (_selectedPlayerIndex == null) return;

    // Record vote
    final currentVotes = Map<int, int>.from(widget.votes);
    currentVotes[_selectedPlayerIndex!] = (currentVotes[_selectedPlayerIndex!] ?? 0) + 1;

    if (widget.currentPlayerIndex < widget.players.length - 1) {
      // Pass to next player
      context.pushReplacement(
        '/voting/${widget.currentPlayerIndex + 1}',
        extra: {
          'players': widget.players,
          'secretWord': widget.secretWord,
          'impostorIndex': widget.impostorIndex,
          'votes': currentVotes,
        },
      );
    } else {
      // All votes cast, go to results
      context.go(
        '/results',
        extra: {
          'players': widget.players,
          'secretWord': widget.secretWord,
          'impostorIndex': widget.impostorIndex,
          'votes': currentVotes,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerName = widget.players[widget.currentPlayerIndex];
    final nextPlayerName = (widget.currentPlayerIndex < widget.players.length - 1)
        ? widget.players[widget.currentPlayerIndex + 1]
        : "Resultados";

    return Scaffold(
      backgroundColor: const Color(0xFFD32F2F), // Red theme for voting
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE53935), Color(0xFFC62828)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: !_voteConfirmed
              ? _buildHandoverView(playerName)
              : _buildVotingView(playerName),
        ),
      ),
    );
  }

  // Initial screen to confirm identity before voting
  Widget _buildHandoverView(String playerName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.how_to_vote, size: 64, color: Colors.white),
        const SizedBox(height: 24),
        const Text(
          "Hora de Votar",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          "Pasa el teléfono a",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          playerName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _voteConfirmed = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFC62828),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            "Soy yo, quiero votar",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // The actual voting interface
  Widget _buildVotingView(String playerName) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          "¿Quién es el impostor?",
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "$playerName, selecciona tu voto",
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: widget.players.length,
            itemBuilder: (context, index) {
              // Cannot vote for yourself? Usually allowed in Among Us style, but let's allow it for now.
              // If you want to disable self-voting: if (index == widget.currentPlayerIndex) return const SizedBox.shrink();
              
              final isSelected = _selectedPlayerIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPlayerIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isSelected ? const Color(0xFFC62828) : Colors.white24,
                        child: Text(
                          widget.players[index][0].toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.players[index],
                        style: TextStyle(
                          color: isSelected ? const Color(0xFFC62828) : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Color(0xFFC62828)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedPlayerIndex != null ? _submitVote : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.white.withOpacity(0.3),
                foregroundColor: const Color(0xFFC62828),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Confirmar Voto",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
