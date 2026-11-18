import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impostor_futbolero/data/models/game_model.dart';
import 'package:impostor_futbolero/data/models/player_model.dart';
import 'package:impostor_futbolero/data/services/firebase_service.dart';
import 'package:impostor_futbolero/providers/game_provider.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  final String gameId;
  const LobbyScreen({super.key, required this.gameId});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen>
    with SingleTickerProviderStateMixin { 
      
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    ref.listenManual(gameStreamProvider(widget.gameId), (previous, next) {
      final game = next.value;
      // --- CRITICAL BUG FIX ---
      // The lobby now correctly listens for ANY state that is NOT 'waiting'.
      // This ensures navigation happens as soon as the game starts (e.g., moves to 'role_reveal').
      if (game != null && game.status != "waiting") { 
        context.go('/game/${widget.gameId}');
      }
    });
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.4),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameStream = ref.watch(gameStreamProvider(widget.gameId));
    final currentUserId = ref.watch(firebaseServiceProvider).currentUserId;

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
        child: gameStream.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
          error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.white))),
          data: (game) {
            return SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SlideTransition(
                        position: _offsetAnimation,
                        child: const Text('⚽', style: TextStyle(fontSize: 40)),
                      ),
                      const SizedBox(height: 12),
                      const Text('Sala de Espera', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Esperando jugadores... (${game.players.length}/5)', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
                      const SizedBox(height: 20),
                      _buildInfoBanner(),
                      const SizedBox(height: 20),
                      _buildMainLobbyCard(context, game, currentUserId),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Flexible(
            child: Text(
              'El juego iniciará automáticamente cuando sean 5 jugadores',
              style: TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainLobbyCard(BuildContext context, Game game, String? currentUserId) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
              ),
              child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: const [ Icon(Icons.group, color: Colors.white, size: 16), SizedBox(width: 8), Text('Partida Pública', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) ],
              ),
            ),
            const SizedBox(height: 16),
             Row(
              children: [ const Icon(Icons.group_outlined), const SizedBox(width: 8), Text('Jugadores (${game.players.length}/5)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), ],
            ),
            const SizedBox(height: 12),
            Column(
              children: game.players.map((player) => _buildPlayerTile(player, game.players.first.id == player.id, player.id == currentUserId)).toList(),
            ),
            const SizedBox(height: 12),
            if (game.players.length < 5)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [ const Text('•••', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)), const SizedBox(width: 8), Text('Esperando más jugadores...', style: TextStyle(color: Colors.grey[600])) ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerTile(Player player, bool isHost, bool isYou) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
         padding: const EdgeInsets.all(12),
         decoration: BoxDecoration(
           color: isYou ? Colors.blue.withOpacity(0.05) : Colors.transparent,
           border: Border.all(color: Colors.grey[300]!),
           borderRadius: BorderRadius.circular(12),
         ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              child: Text(player.name.isNotEmpty ? player.name[0].toUpperCase() : '?'),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (isYou) const Text('Tú', style: TextStyle(color: Colors.blue, fontSize: 12)),
              ],
            ),
            const Spacer(),
            if (isHost)
              Chip(
                label: const Text('Host', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.amber[100],
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
          ],
        ),
      ),
    );
  }
}
