import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impostor_futbolero/data/models/game_models.dart';
import 'package:impostor_futbolero/data/services/firebase_service.dart';
import 'package:impostor_futbolero/domain/providers/game_provider.dart';

class GameplayScreen extends ConsumerWidget {
  final String gameId;
  const GameplayScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameStream = ref.watch(gameStreamProvider(gameId));
    final currentUserId = ref.watch(firebaseServiceProvider).currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ronda 1'), // This will be dynamic later
        automaticallyImplyLeading: false,
      ),
      body: gameStream.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (game) {
          // Find the current player's object from the list.
          final currentPlayer = game.players.firstWhere(
            (p) => p.uid == currentUserId,
            orElse: () => Player(uid: '', name: 'Desconocido'),
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Role and Objective Display
                _buildRoleInfo(context, currentPlayer, game.footballPlayerName),
                const SizedBox(height: 20),
                
                // This is where the main content of the current phase will go.
                Expanded(
                  child: Center(
                    child: Text(
                      'Fase actual del juego: [PENDIENTE]',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper widget to show player role and the footballer's name.
  Widget _buildRoleInfo(BuildContext context, Player player, String footballerName) {
    final bool isImpostor = player.isImpostor;
    return Card(
      color: isImpostor ? Colors.red.shade900 : Colors.blue.shade900,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              isImpostor ? 'Eres el IMPOSTOR' : 'Eres un COMPAÑERO',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isImpostor 
                ? 'Engaña a los demás para que no descubran al futbolista.' 
                : 'El futbolista es: ${footballerName.toUpperCase()}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
