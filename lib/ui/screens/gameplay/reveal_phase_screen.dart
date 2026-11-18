import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impostor_futbolero/data/models/game_model.dart';
import 'package:impostor_futbolero/data/services/firebase_service.dart';
import 'package:impostor_futbolero/providers/game_provider.dart';

class RevealPhaseScreen extends ConsumerStatefulWidget {
  final Game game;
  const RevealPhaseScreen({super.key, required this.game});

  @override
  ConsumerState<RevealPhaseScreen> createState() => _RevealPhaseScreenState();
}

class _RevealPhaseScreenState extends ConsumerState<RevealPhaseScreen> {
  final _clueController = TextEditingController();
  bool _isSubmitting = false;

  void _submitClue() async {
    if (_clueController.text.trim().isEmpty) return;
    setState(() { _isSubmitting = true; });

    final gameNotifier = ref.read(gameNotifierProvider);
    await gameNotifier.submitClue(widget.game.gameId, _clueController.text.trim());

    // The button will remain disabled after submitting
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(firebaseServiceProvider).currentUserId;
    final isImpostor = widget.game.impostorId == currentUserId;
    final alreadySubmitted = widget.game.clues.containsKey(currentUserId);

    final waitingForPlayers = widget.game.players
        .where((p) => !widget.game.clues.containsKey(p.id))
        .toList();

    final submittedPlayers = widget.game.players
        .where((p) => widget.game.clues.containsKey(p.id))
        .toList();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isImpostor
              ? const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFF97316)]) // Impostor Gradient
              : const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF10B981)]), // Player Gradient
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(isImpostor ? '🎭 ERES EL IMPOSTOR' : '🎯 ERES JUGADOR NORMAL', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('El futbolista secreto es:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 12),
                Text(
                  isImpostor ? '❓ ❓ ❓' : '⚽ ${widget.game.footballer?.toUpperCase() ?? "NO DEFINIDO"} ⚽',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  isImpostor ? 'Debes sobrevivir sin que te descubran.' : 'Da pistas relacionadas pero no seas demasiado obvio.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _clueController,
                  enabled: !alreadySubmitted,
                  maxLength: 30,
                  decoration: InputDecoration(
                    hintText: alreadySubmitted ? 'Pista enviada' : 'Escribe tu pista...',
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.2),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: alreadySubmitted || _isSubmitting ? null : _submitClue,
                  icon: const Icon(Icons.check),
                  label: const Text('ENVIAR PISTA'),
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Colors.white.withOpacity(0.3),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                ),
                const SizedBox(height: 40),
                if (waitingForPlayers.isNotEmpty)
                  _buildPlayerStatusList('⏳ Esperando a:', waitingForPlayers.map((p) => p.name).toList()),
                if (submittedPlayers.isNotEmpty)
                  _buildPlayerStatusList('✅ Ya enviaron:', submittedPlayers.map((p) => p.name).toList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerStatusList(String title, List<String> playerNames) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...playerNames.map((name) => Text('• $name', style: const TextStyle(color: Colors.white, fontSize: 16))),
        const SizedBox(height: 20),
      ],
    );
  }
}
