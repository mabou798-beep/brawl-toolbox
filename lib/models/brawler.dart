import 'dart:ui';

class BrawlerAbility {
  final String name;
  final String description;
  final String imageUrl;

  BrawlerAbility({
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory BrawlerAbility.fromJson(Map<String, dynamic> json) {
    return BrawlerAbility(
      name: json['name'] as String? ?? 'Unknown',
      description: (json['description'] as String? ?? '').replaceAll(
        RegExp(r'<[^>]*>'),
        '',
      ),
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}

class Brawler {
  final int id;
  final String name;
  final String portraitUrl;
  final String borderlessUrl;
  final String emojiUrl;
  final String className;
  final String rarityName;
  final Color rarityColor;
  final String description;
  final List<BrawlerAbility> starPowers;
  final List<BrawlerAbility> gadgets;

  Brawler({
    required this.id,
    required this.name,
    required this.portraitUrl,
    required this.borderlessUrl,
    required this.emojiUrl,
    required this.className,
    required this.rarityName,
    required this.rarityColor,
    required this.description,
    required this.starPowers,
    required this.gadgets,
  });

  factory Brawler.fromJson(Map<String, dynamic> json) {
    final rarity = json['rarity'] as Map<String, dynamic>?;
    final rarityColorHex = rarity?['color'] as String? ?? '#FFFFFF';
    final brawlerClass = json['class'] as Map<String, dynamic>?;

    return Brawler(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      portraitUrl: json['imageUrl'] as String? ?? '',
      borderlessUrl:
          json['imageUrl2'] as String? ?? json['imageUrl'] as String? ?? '',
      emojiUrl: json['imageUrl3'] as String? ?? '',
      className: brawlerClass?['name'] as String? ?? 'Unknown',
      rarityName: rarity?['name'] as String? ?? 'Common',
      rarityColor: _colorFromHex(rarityColorHex),
      description: (json['description'] as String? ?? '').replaceAll(
        RegExp(r'<[^>]*>'),
        '',
      ),
      starPowers: (json['starPowers'] as List<dynamic>? ?? [])
          .map((e) => BrawlerAbility.fromJson(e as Map<String, dynamic>))
          .toList(),
      gadgets: (json['gadgets'] as List<dynamic>? ?? [])
          .map((e) => BrawlerAbility.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static Color _colorFromHex(String hex) {
    var value = hex.replaceAll('#', '');
    if (value.length == 6) value = 'FF$value';
    try {
      return Color(int.parse(value, radix: 16));
    } catch (_) {
      return const Color(0xFFFFC72C);
    }
  }

  List<String> get galleryImages => [
    if (portraitUrl.isNotEmpty) portraitUrl,
    if (borderlessUrl.isNotEmpty && borderlessUrl != portraitUrl)
      borderlessUrl,
  ];

  /// Full-body render at 476x1007 — the highest-resolution official art
  /// exposed by BrawlAPI, and the only one actually suited to a phone
  /// wallpaper. [portraitUrl]/[borderlessUrl] are tiny (170-200px) UI icons
  /// meant for avatars, not full-screen viewing.
  String get wallpaperUrl => 'https://cdn.brawlify.com/brawlers/model/$id.png';

  /// Largest official art first, then progressively smaller images. The CDN
  /// has no model render for the four newest brawlers, so callers walk this
  /// list instead of relying on one URL.
  List<String> get artCandidates =>
      [wallpaperUrl, borderlessUrl, portraitUrl, emojiUrl];

  /// Tile art: the square portrait reads better at grid size than a full body.
  List<String> get tileCandidates =>
      [borderlessUrl, portraitUrl, wallpaperUrl, emojiUrl];

}
