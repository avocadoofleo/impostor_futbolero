import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impostor_futbolero/data/models/game_model.dart';
import 'package:impostor_futbolero/data/services/firebase_service.dart';
import 'package:impostor_futbolero/providers/game_provider.dart';

class RoleRevealScreen extends ConsumerStatefulWidget {
  final Game game;
  const RoleRevealScreen({super.key, required this.game});

  @override
  ConsumerState<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends ConsumerState<RoleRevealScreen> {

  @override
  void initState() {
    super.initState();
    final currentUserId = ref.read(firebaseServiceProvider).currentUserId;
    final isHost = widget.game.players.first.id == currentUserId;

    if (isHost) {
       Timer(const Duration(seconds: 4), () {
        if (mounted) {
          ref.read(gameNotifierProvider).startCluePhase(widget.game.gameId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.read(firebaseServiceProvider).currentUserId;
    final isImpostor = widget.game.impostorId == currentUserId;

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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("TU ROL ES:", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  decoration: BoxDecoration(
                    color: isImpostor ? Colors.red.shade700 : Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    isImpostor ? "IMPOSTOR" : "JUGADOR",
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                ),
                // --- BUG FIX: Show the footballer name to normal players ---
                if (!isImpostor)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Column(
                      children: [
                        const Text("El futbolista secreto es:", style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          widget.game.footballer?.toUpperCase() ?? 'ERROR',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
