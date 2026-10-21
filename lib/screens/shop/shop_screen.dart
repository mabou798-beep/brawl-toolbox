import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/brawler.dart';
import '../../providers/brawlers_provider.dart';
import '../../widgets/section_header.dart';
import '../../widgets/state_views.dart';

/// There is no public "live shop" API for Brawl Stars — Supercell's shop
/// rotation is server-authoritative and not exposed. This screen is a
/// concept/demo shop styled after the in-game store, built from real
/// brawler art so it looks authentic, but prices and bundles are static
/// placeholders rather than a live feed.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrawlersProvider>();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text('Shop', style: Theme.of(context).textTheme.headlineMedium),
                  const Spacer(),
                  _CurrencyPill(
                    icon: FontAwesomeIcons.gem,
                    color: AppColors.accentPink,
                    value: '2,450',
                  ),
                  const SizedBox(width: 8),
                  _CurrencyPill(
                    icon: FontAwesomeIcons.coins,
                    color: AppColors.primary,
                    value: '18.2k',
                  ),
                ],
              ),
            ),
          ),
          if (provider.status == LoadStatus.loading || provider.status == LoadStatus.idle)
            const SliverFillRemaining(child: LoadingView(message: 'Loading offers...')),
          if (provider.status == LoadStatus.error)
            SliverFillRemaining(
              child: ErrorView(
                message: provider.errorMessage ?? 'Unknown error',
                onRetry: () => provider.load(),
              ),
            ),
          if (provider.status == LoadStatus.loaded) ..._buildOfferSections(context, provider.brawlers),
        ],
      ),
    );
  }

  List<Widget> _buildOfferSections(BuildContext context, List<Brawler> brawlers) {
    if (brawlers.isEmpty) return [];
    final featured = brawlers[brawlers.length % brawlers.length];
    final skinPicks = brawlers.length > 6
        ? brawlers.sublist(0, 6)
        : brawlers;

    return [
      const SliverToBoxAdapter(child: SectionHeader(title: 'Featured Offer')),
      SliverToBoxAdapter(child: _FeaturedOfferCard(brawler: featured)),
      const SliverToBoxAdapter(child: SectionHeader(title: 'Skins')),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) => _SkinOfferCard(
              brawler: skinPicks[i],
              price: 29 + (i * 10),
            ),
            childCount: skinPicks.length,
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SectionHeader(title: 'Gem Bundles')),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 130,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            children: const [
              _GemBundleCard(gems: 30, price: '\$0.99'),
              SizedBox(width: 12),
              _GemBundleCard(gems: 80, price: '\$1.99', badge: 'POPULAR'),
              SizedBox(width: 12),
              _GemBundleCard(gems: 170, price: '\$3.99'),
              SizedBox(width: 12),
              _GemBundleCard(gems: 950, price: '\$19.99', badge: 'BEST VALUE'),
            ],
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ];
  }
}

class _CurrencyPill extends StatelessWidget {
  final FaIconData icon;
  final Color color;
  final String value;

  const _CurrencyPill({required this.icon, required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

class _FeaturedOfferCard extends StatelessWidget {
  final Brawler brawler;
  const _FeaturedOfferCard({required this.brawler});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.accentPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: CachedNetworkImage(
              imageUrl: brawler.portraitUrl,
              height: 190,
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'FEATURED BRAWLER',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  brawler.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${brawler.rarityName} • ${brawler.className}',
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkinOfferCard extends StatelessWidget {
  final Brawler brawler;
  final int price;

  const _SkinOfferCard({required this.brawler, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: brawler.portraitUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (_, _) => Container(color: AppColors.surfaceAlt),
              errorWidget: (_, _, _) => Container(color: AppColors.surfaceAlt),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: [
                const FaIcon(FontAwesomeIcons.gem, size: 11, color: AppColors.accentPink),
                const SizedBox(width: 4),
                Text('$price', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GemBundleCard extends StatelessWidget {
  final int gems;
  final String price;
  final String? badge;

  const _GemBundleCard({required this.gems, required this.price, this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: badge != null ? Border.all(color: AppColors.primary, width: 1.5) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (badge != null)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge!,
                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.black),
              ),
            ),
          const FaIcon(FontAwesomeIcons.gem, color: AppColors.accentPink, size: 22),
          const SizedBox(height: 6),
          Text('$gems', style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}
