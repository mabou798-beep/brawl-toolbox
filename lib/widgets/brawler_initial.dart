import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Stand-in for a brawler whose art the CDN doesn't have yet: their initial,
/// in their rarity colour, so the tile still reads as that brawler.
class BrawlerInitial extends StatelessWidget {
  final String name;
  final Color color;
  final double size;

  const BrawlerInitial({
    super.key,
    required this.name,
    required this.color,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withValues(alpha: 0.14),
      alignment: Alignment.center,
      child: Text(
        name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
        style: AppTheme.display(size, color: color.withValues(alpha: 0.85)),
      ),
    );
  }
}
