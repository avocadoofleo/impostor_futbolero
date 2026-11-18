import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResultsPhaseScreen extends StatelessWidget {
  final List<String> players;
  final String secretWord;
  final int impostorIndex;
  final Map<int, int> votes;

  const ResultsPhaseScreen({
    super.key,
    required this.players,
    required this.secretWord,
    required this.impostorIndex,
    required this.votes,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate results
    int maxVotes = 0;
    int mostVotedPlayerIndex = -1;
    bool tie = false;
    
    // Simple logic to find most voted player
    votes.forEach((playerIndex, count) {
      if (count > maxVotes) {
        maxVotes = count;
        mostVotedPlayerIndex = playerIndex;
        tie = false;
      } else if (count == maxVotes) {
        tie = true;
      }
    });

    final eliminatedPlayerName = (mostVotedPlayerIndex != -1 && !tie)
        ? players[mostVotedPlayerIndex]
        : "Nadie";

    final wasImpostor = (mostVotedPlayerIndex == impostorIndex) && !tie;
    
    // For this specific UI request, we are assuming someone WAS eliminated.
    // If it's a tie, you might want to show a different screen or "Nadie fue eliminado".
    // Following the user's design for an eliminated player:

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50), // Dark background
      body: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF5C6BC0), // Grey/Blueish avatar background
                ),
                child: const Icon(Icons.person, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                "$eliminatedPlayerName fue eliminado",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: wasImpostor ? const Color(0xFFFF5252) : const Color(0xFF448AFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  wasImpostor ? "Era el impostor" : "Era un jugador inocente",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              const Text(
                "Resultados de la votación:",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              // Votes List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: List.generate(players.length, (index) {
                    final voteCount = votes[index] ?? 0;
                    if (voteCount == 0) return const SizedBox.shrink();
                    
                    final isMostVoted = index == mostVotedPlayerIndex && !tie;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            players[index],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isMostVoted ? const Color(0xFFD32F2F) : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "$voteCount voto${voteCount != 1 ? 's' : ''}",
                              style: TextStyle(
                                color: isMostVoted ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              
              const SizedBox(height: 24),
              // Who voted for whom logic is not tracked in the current state passed from VotingPhaseScreen.
              // To match the design "Quién votó por quién", we would need to pass Map<int, int> voterToTarget.
              // For now, I'll omit this or show a placeholder if required, but user only passed aggregated votes.
              // Let's stick to the aggregated view as per logic available.
              
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                       context.go('/');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF37474F), // Dark button
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Continuar",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
