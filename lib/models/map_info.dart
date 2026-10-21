import 'dart:ui';

class MapInfo {
  final int id;
  final String name;
  final String imageUrl;
  final String gameModeName;
  final Color gameModeColor;
  final bool disabled;

  MapInfo({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.gameModeName,
    required this.gameModeColor,
    required this.disabled,
  });

  factory MapInfo.fromJson(Map<String, dynamic> json) {
    final gameMode = json['gameMode'] as Map<String, dynamic>?;
    final colorHex = gameMode?['color'] as String? ?? '#FFC107';

    return MapInfo(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown Map',
      imageUrl: json['imageUrl'] as String? ?? '',
      gameModeName: gameMode?['name'] as String? ?? 'Unknown',
      gameModeColor: _colorFromHex(colorHex),
      disabled: json['disabled'] as bool? ?? false,
    );
  }

  static Color _colorFromHex(String hex) {
    var value = hex.replaceAll('#', '');
    if (value.length == 6) value = 'FF$value';
    try {
      return Color(int.parse(value, radix: 16));
    } catch (_) {
      return const Color(0xFFFFC107);
    }
  }
}
