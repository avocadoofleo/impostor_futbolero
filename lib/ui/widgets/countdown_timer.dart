import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime startTime;
  final int durationInSeconds;
  final VoidCallback onFinished;

  const CountdownTimer({
    super.key,
    required this.startTime,
    this.durationInSeconds = 60,
    required this.onFinished,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateRemainingTime());
  }

  void _calculateRemainingTime() {
    final elapsed = DateTime.now().difference(widget.startTime).inSeconds;
    final remaining = widget.durationInSeconds - elapsed;

    if (remaining <= 0) {
      _timer.cancel();
      widget.onFinished();
      setState(() { _remainingSeconds = 0; });
    } else {
      setState(() { _remainingSeconds = remaining; });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return Text(
      '$minutes:$seconds',
      style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }
}
