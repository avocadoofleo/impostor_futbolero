import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:impostor_futbolero/data/models/game_model.dart';
import 'package:impostor_futbolero/data/models/player_model.dart'; // <-- IMPORT ADDED

class FinishedScreen extends StatelessWidget {
  final Game game;
  const FinishedScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final bool playersWon = game.winner == 'players';
    // --- BUG FIX: Safely find the impostor ---
    final impostor = game.players.firstWhere(
      (p) => p.id == game.impostorId, 
      orElse: () => Player.fromMap({'name': 'Desconocido'}) // Return a dummy player if not found
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/stadium_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(playersWon ? '🎉 ¡VICTORIA DE LOS JUGADORES!' : '😈 ¡EL IMPOSTOR GANA!', 
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    playersWon
                        ? 'Han eliminado correctamente al impostor.'
                        : 'El impostor ha sobrevivido hasta el final.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 40),
                  _buildInfoCard('🎭 El impostor era:', impostor.name.toUpperCase()),
                  const SizedBox(height: 20),
                  _buildInfoCard('⚽ El futbolista era:', game.footballer?.toUpperCase() ?? 'N/A'),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () => context.go('/'), // Go back to main menu
                        icon: const Icon(Icons.exit_to_app, color: Colors.white,),
                        label: const Text('SALIR', style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/'), // For now, also goes back to main menu
                        icon: const Icon(Icons.refresh),
                        label: const Text('JUGAR DE NUEVO'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      color: Colors.black.withOpacity(0.3),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white.withOpacity(0.2))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
