import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class ClueGivingScreen extends StatefulWidget {
  final List<String> players;
  final int currentPlayerIndex;
  final String secretWord;
  final int impostorIndex;

  const ClueGivingScreen({
    super.key,
    required this.players,
    required this.currentPlayerIndex,
    required this.secretWord,
    required this.impostorIndex,
  });

  @override
  State<ClueGivingScreen> createState() => _ClueGivingScreenState();
}

class _ClueGivingScreenState extends State<ClueGivingScreen> {
  int _secondsRemaining = 20;
  Timer? _timer;
  bool _isTurnActive = false;

  void _startTurn() {
    setState(() {
      _isTurnActive = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _endTurn();
      }
    });
  }

  void _endTurn() {
    _timer?.cancel();
    // Navigate to next player or discussion phase
    if (widget.currentPlayerIndex < widget.players.length - 1) {
      context.pushReplacement(
        '/game-loop/${widget.currentPlayerIndex + 1}',
        extra: {
          'players': widget.players,
          'secretWord': widget.secretWord,
          'impostorIndex': widget.impostorIndex,
        },
      );
    } else {
      // All players have given clues, go to discussion
       context.go(
        '/discussion',
        extra: {
          'players': widget.players,
          'secretWord': widget.secretWord,
          'impostorIndex': widget.impostorIndex,
        },
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerName = widget.players[widget.currentPlayerIndex];
    final nextPlayerName = (widget.currentPlayerIndex < widget.players.length - 1)
        ? widget.players[widget.currentPlayerIndex + 1]
        : "Fase de Discusión";

    return Scaffold(
      backgroundColor: const Color(0xFF00C853),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00BFA5), Color(0xFF00C853)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: !_isTurnActive
              ? _buildHandoverView(playerName)
              : _buildActiveTurnView(playerName),
        ),
      ),
    );
  }

  Widget _buildHandoverView(String playerName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Pasa el teléfono a",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
        const SizedBox(height: 16),
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
          onPressed: _startTurn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF00C853),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            "Soy yo, Iniciar Turno",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTurnView(String playerName) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(
          "Turno de $playerName",
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Di una palabra sobre el futbolista",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _secondsRemaining / 20,
                    strokeWidth: 12,
                    color: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                ),
                Text(
                  "$_secondsRemaining",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _endTurn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF00C853),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Terminar Turno",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
