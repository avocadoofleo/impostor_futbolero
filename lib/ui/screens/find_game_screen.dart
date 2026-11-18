import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impostor_futbolero/data/services/firebase_service.dart';

class FindGameScreen extends ConsumerStatefulWidget {
  const FindGameScreen({super.key});

  @override
  ConsumerState<FindGameScreen> createState() => _FindGameScreenState();
}

class _FindGameScreenState extends ConsumerState<FindGameScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _findGame() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un nombre.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      final gameId = await firebaseService.findOrCreateGame(_nameController.text.trim());
      
      if (mounted) context.go('/lobby/$gameId');

    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar partida: $e')),
        );
       }
    } finally {
       if (mounted) {
        setState(() { _isLoading = false; });
       }
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows the gradient to go behind the AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // 1. Wrapped the content in a SingleChildScrollView to prevent overflow
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height, // Ensures the column takes full screen height
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Spacer(),
                    const Text(
                      'Buscar Partida',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Ingresa tu nombre',
                        labelStyle: TextStyle(color: Colors.green[100]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green[200]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white, width: 2),
                           borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : ElevatedButton(
                            onPressed: _findGame,
                             style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green[800], // Text color
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              'Buscar Partida Pública',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
