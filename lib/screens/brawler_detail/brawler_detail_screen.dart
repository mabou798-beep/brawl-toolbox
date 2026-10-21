import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../models/brawler.dart';
import '../../widgets/brawler_initial.dart';
import '../../widgets/fallback_image.dart';

/// One brawler, at full size. The model render is the hero because it is the
/// thing players recognise; everything below it is the detail they came for —
/// star powers and gadgets, with the game's own descriptions.
class BrawlerDetailScreen extends StatelessWidget {
  final Brawler brawler;

  const BrawlerDetailScreen({super.key, required this.brawler});

  @override
  Widget build(BuildContext context) {
    final rarity = brawler.rarityColor;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 330,
            pinned: true,
            backgroundColor: AppColors.background,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            title: Text(brawler.name, style: AppTheme.display(21)),
            flexibleSpace: FlexibleSpaceBar(
              background: _Hero(brawler: brawler),
              collapseMode: CollapseMode.parallax,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.gutter,
                18,
                AppSizes.gutter,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Pill(label: brawler.rarityName, color: rarity),
                      const SizedBox(width: 8),
                      _Pill(
                        label: brawler.className,
                        color: AppColors.textMuted,
                        outlined: true,
                      ),
                    ],
                  ),
                  if (brawler.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      brawler.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  if (brawler.starPowers.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    Text('Star powers', style: AppTheme.display(22)),
                    const SizedBox(height: 10),
                    for (final ability in brawler.starPowers)
                      _AbilityCard(
                        ability: ability,
                        accent: AppColors.primary,
                        icon: FontAwesomeIcons.star,
                      ),
                  ],
                  if (brawler.gadgets.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Text('Gadgets', style: AppTheme.display(22)),
                    const SizedBox(height: 10),
                    for (final ability in brawler.gadgets)
                      _AbilityCard(
                        ability: ability,
                        accent: AppColors.accentGreen,
                        icon: FontAwesomeIcons.bolt,
                      ),
                  ],
                  const SizedBox(height: 28),
                  Text(
                    'This material is unofficial and is not endorsed by Supercell.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final Brawler brawler;
  const _Hero({required this.brawler});

  @override
  Widget build(BuildContext context) {
    final rarity = brawler.rarityColor;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            rarity.withValues(alpha: 0.55),
            AppColors.background,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 54, bottom: 6),
            child: FallbackImage(
              candidates: brawler.artCandidates,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              placeholder: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              fallback: Center(
                child: BrawlerInitial(
                  name: brawler.name,
                  color: rarity,
                  size: 130,
                ),
              ),
            ),
          ),
          // Keeps the pinned title legible once the art scrolls behind it.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 90,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;

  const _Pill({
    required this.label,
    required this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color,
        border: outlined ? Border.all(color: color.withValues(alpha: 0.6)) : null,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: outlined ? AppColors.textMuted : const Color(0xFF1A0E38),
        ),
      ),
    );
  }
}

class _AbilityCard extends StatelessWidget {
  final BrawlerAbility ability;
  final Color accent;
  final FaIconData icon;

  const _AbilityCard({
    required this.ability,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: FallbackImage(
              candidates: [ability.imageUrl],
              fit: BoxFit.contain,
              fallback: Center(child: FaIcon(icon, color: accent, size: 17)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ability.name, style: AppTheme.display(16)),
                const SizedBox(height: 3),
                Text(
                  ability.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
