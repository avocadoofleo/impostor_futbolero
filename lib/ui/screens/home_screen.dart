import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF1B5E20)],
            center: Alignment.topCenter,
            radius: 1.5,
          ),
        ),
        // 1. Wrapped in SingleChildScrollView to prevent overflow on smaller screens
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Spacer(flex: 2),
                    const Icon(Icons.sports_soccer, color: Colors.white, size: 50),
                    const SizedBox(height: 16),
                    const Text(
                      'El Impostor Futbolero',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¿Podrás descubrir quién es el impostor?',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                    ),
                    const Spacer(flex: 2),
                    _buildModeCard(
                      context: context,
                      icon: Icons.group,
                      title: 'Modo Local',
                      subtitle: 'Con amigos cerca',
                      buttonText: 'Jugar Local',
                      buttonColor: Colors.green,
                      onPressed: () {
                        context.go('/local-setup');
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildModeCard(
                      context: context,
                      icon: Icons.public,
                      title: 'Modo Online',
                      subtitle: 'Público o privado',
                      buttonText: 'Jugar Online',
                      buttonColor: Colors.blue.shade600,
                      onPressed: () {
                        context.go('/find-game');
                      },
                    ),
                    const Spacer(flex: 3),
                    Chip(
                      backgroundColor: Colors.black.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      label: const Text(
                        '3-5 jugadores  •  5-10 min',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: buttonColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: buttonColor, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(buttonText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
