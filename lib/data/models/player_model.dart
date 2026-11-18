/// Represents a single player in the game.
class Player {
  final String id;
  final String name;
  final bool isHost;
  final bool isAlive;

  Player({
    required this.id,
    required this.name,
    required this.isHost,
    required this.isAlive,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Desconocido',
      isHost: map['isHost'] ?? false,
      isAlive: map['isAlive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isHost': isHost,
      'isAlive': isAlive,
    };
  }
}
