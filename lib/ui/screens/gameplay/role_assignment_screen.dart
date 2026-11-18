import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleAssignmentScreen extends StatefulWidget {
  final List<String> players;
  final int currentPlayerIndex;
  final String? secretWord;
  final int? impostorIndex;

  const RoleAssignmentScreen({
    super.key,
    required this.players,
    required this.currentPlayerIndex,
    this.secretWord,
    this.impostorIndex,
  });

  @override
  State<RoleAssignmentScreen> createState() => _RoleAssignmentScreenState();
}

class _RoleAssignmentScreenState extends State<RoleAssignmentScreen> {
  bool _isRevealed = false;
  late String _assignedWord;
  late int _impostorIndex;

  // Lista de futbolistas para el juego
  final List<String> _soccerPlayers = [
    "Lionel Messi", "Cristiano Ronaldo", "Kylian Mbappé", "Neymar Jr",
    "Erling Haaland", "Kevin De Bruyne", "Luka Modrić", "Robert Lewandowski",
    "Mohamed Salah", "Vinícius Jr", "Jude Bellingham", "Harry Kane",
    "Antoine Griezmann", "Bernardo Silva", "Pedri", "Jamal Musiala",
    "Zlatan Ibrahimović", "Sergio Ramos", "Manuel Neuer", "Virgil van Dijk",
    "Lamine Yamal", "Toni Kroos", "Luis Suárez", "Rodri"
  ];

  @override
  void initState() {
    super.initState();
    // Lógica de inicialización para el primer jugador
    if (widget.secretWord == null || widget.impostorIndex == null) {
      // Elegir palabra aleatoria de la lista
      _assignedWord = _soccerPlayers[Random().nextInt(_soccerPlayers.length)]; 
      // Elegir impostor aleatorio
      _impostorIndex = Random().nextInt(widget.players.length);
    } else {
      _assignedWord = widget.secretWord!;
      _impostorIndex = widget.impostorIndex!;
    }
  }

  void _revealRole() {
    setState(() {
      _isRevealed = true;
    });
  }

  void _nextStep() {
    if (widget.currentPlayerIndex < widget.players.length - 1) {
      // Navegar al siguiente jugador.
      // Al hacer pushReplacement a una nueva instancia de RoleAssignmentScreen,
      // el estado _isRevealed comienza en false, mostrando la pantalla de privacidad nuevamente.
       context.pushReplacement(
        '/role-assignment/${widget.currentPlayerIndex + 1}',
        extra: {
          'players': widget.players,
          'secretWord': _assignedWord,
          'impostorIndex': _impostorIndex,
        },
      );
    } else {
      // Todos han visto su rol, ir al bucle de juego (Fase de Pistas)
      context.go(
        '/game-loop/0', // Empieza jugador 0
        extra: {
          'players': widget.players,
          'secretWord': _assignedWord,
          'impostorIndex': _impostorIndex,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerName = widget.players[widget.currentPlayerIndex];
    final isImpostor = widget.currentPlayerIndex == _impostorIndex;
    final nextPlayerName = (widget.currentPlayerIndex < widget.players.length - 1)
        ? widget.players[widget.currentPlayerIndex + 1]
        : "Nadie (Fin de asignación)";

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
        // Envuelto en SingleChildScrollView para corregir el overflow
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: SafeArea(
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Indicador de Jugador (Pill)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Jugador ${widget.currentPlayerIndex + 1} de ${widget.players.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Tarjeta Blanca Principal
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Avatar con Inicial
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF00C853), // Verde por defecto
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                playerName.isNotEmpty ? playerName[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              playerName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            
                            const SizedBox(height: 32),

                            // ESTADO: NO REVELADO (Pantalla de Privacidad)
                            if (!_isRevealed) ...[
                               const Text(
                                "¿Listo para ver tu rol?",
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              const SizedBox(height: 24),
                              // Caja de Advertencia
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E1), // Amarillo claro
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFFE082)),
                                ),
                                child: Column(
                                  children: const [
                                    Icon(Icons.visibility_off_outlined, color: Colors.orange),
                                    SizedBox(height: 8),
                                    Text(
                                      "Privado",
                                      style: TextStyle(
                                        color: Colors.orange, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Asegúrate de que nadie más esté mirando tu pantalla",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.brown, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _revealRole,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00C853),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "Ver Mi Rol",
                                    style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              // ESTADO: REVELADO (Muestra Rol)
                              if (isImpostor) ...[
                                // VISTA DE IMPOSTOR
                                 const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Color(0xFFFF5252), // Rojo
                                  child: Icon(Icons.person_off, size: 40, color: Colors.white),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Eres el Impostor",
                                  style: TextStyle(
                                    color: Color(0xFFFF5252),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                   padding: const EdgeInsets.all(16),
                                   width: double.infinity,
                                   decoration: BoxDecoration(
                                     color: const Color(0xFFFFEBEE),
                                     borderRadius: BorderRadius.circular(12),
                                     border: Border.all(color: const Color(0xFFFFCDD2)),
                                   ),
                                   child: Column(
                                     children: const [
                                       Text(
                                         "Tu objetivo:",
                                         style: TextStyle(
                                           fontWeight: FontWeight.bold,
                                           color: Color(0xFFD32F2F),
                                         ),
                                       ),
                                       SizedBox(height: 8),
                                       Text(
                                         "Engaña a los demás fingiendo que conoces al futbolista secreto. Escucha sus pistas y trata de encajar.",
                                         textAlign: TextAlign.center,
                                         style: TextStyle(color: Color(0xFFB71C1C), fontSize: 13),
                                       ),
                                     ],
                                   ),
                                ),
                              ] else ...[
                                // VISTA DE JUGADOR
                                 const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Color(0xFF448AFF), // Azul
                                  child: Icon(Icons.person, size: 40, color: Colors.white),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Eres Jugador",
                                  style: TextStyle(
                                    color: Color(0xFF448AFF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Tu futbolista asignado:",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FD),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFBBDEFB)),
                                  ),
                                  child: Text(
                                    _assignedWord,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                   padding: const EdgeInsets.all(16),
                                   width: double.infinity,
                                   decoration: BoxDecoration(
                                     color: const Color(0xFFE3F2FD),
                                     borderRadius: BorderRadius.circular(12),
                                     border: Border.all(color: const Color(0xFFBBDEFB)),
                                   ),
                                   child: Column(
                                     children: [
                                       const Text(
                                         "Tu objetivo:",
                                         style: TextStyle(
                                           fontWeight: FontWeight.bold,
                                           color: Color(0xFF1565C0),
                                         ),
                                       ),
                                       const SizedBox(height: 8),
                                       Text(
                                         "Da pistas relacionadas con $_assignedWord para que otros sepan que no eres el impostor.",
                                         textAlign: TextAlign.center,
                                         style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 13),
                                       ),
                                     ],
                                   ),
                                ),
                              ],
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _nextStep,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00C853),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "Siguiente Jugador",
                                    style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              if (widget.currentPlayerIndex < widget.players.length - 1)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    "Pasa el dispositivo a $nextPlayerName",
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
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
