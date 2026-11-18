import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class DiscussionPhaseScreen extends StatefulWidget {
  final List<String> players;
  final String secretWord;
  final int impostorIndex;

  const DiscussionPhaseScreen({
    super.key,
    required this.players,
    required this.secretWord,
    required this.impostorIndex,
  });

  @override
  State<DiscussionPhaseScreen> createState() => _DiscussionPhaseScreenState();
}

class _DiscussionPhaseScreenState extends State<DiscussionPhaseScreen> {
  int _secondsRemaining = 120;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _endDiscussion();
      }
    });
  }

  void _endDiscussion() {
    _timer?.cancel();
    // Navigate to voting phase starting with first player
    context.go(
      '/voting/0',
      extra: {
        'players': widget.players,
        'secretWord': widget.secretWord,
        'impostorIndex': widget.impostorIndex,
        'votes': <int, int>{}, // Initialize empty votes map
      },
    );
  }

  void _skipDiscussion() {
    _endDiscussion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E88E5), // Blue theme for discussion
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.forum, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                "Fase de Discusión",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  "Debatan quién creen que es el impostor. ¡Tienen 2 minutos!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              const Spacer(),
              Text(
                _formatTime(_secondsRemaining),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _skipDiscussion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1565C0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Votar Ahora",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
