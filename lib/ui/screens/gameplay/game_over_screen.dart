import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GameOverScreen extends StatelessWidget {
  final bool isImpostorWin;
  final String impostorName;

  const GameOverScreen({
    super.key,
    required this.isImpostorWin,
    required this.impostorName,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isImpostorWin ? const Color(0xFFD32F2F) : const Color(0xFF00C853);
    final String title = isImpostorWin ? "¡El Impostor Gana!" : "¡Ganaron los Futboleros!";
    final String message = isImpostorWin 
        ? "El impostor ($impostorName) ha eliminado a la mayoría."
        : "Han descubierto al impostor ($impostorName).";
    final IconData icon = isImpostorWin ? Icons.person_off : Icons.emoji_events;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 120, color: Colors.white),
            const SizedBox(height: 32),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Volver al Menú",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
