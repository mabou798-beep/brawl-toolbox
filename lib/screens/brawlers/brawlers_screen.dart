import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/ads/native_ad_tile.dart';
import '../../core/theme/app_theme.dart';
import '../../models/brawler.dart';
import '../../providers/brawlers_provider.dart';
import '../../widgets/brawler_initial.dart';
import '../../widgets/filter_pill.dart';
import '../../widgets/fallback_image.dart';
import '../../widgets/state_views.dart';
import '../brawler_detail/brawler_detail_screen.dart';

/// The full roster. Every card is framed in the rarity colour the API reports
/// for that brawler, so the grid reads as the game's own rarity ladder rather
/// than a wall of identical tiles.
class BrawlersScreen extends StatefulWidget {
  const BrawlersScreen({super.key});

  @override
  State<BrawlersScreen> createState() => _BrawlersScreenState();
}

class _BrawlersScreenState extends State<BrawlersScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _classFilter = 'All';

  /// One native ad after the first two rows, then none — enough to earn from
  /// a long scroll without turning the roster into a feed of ads.
  static const _adAfter = 12;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrawlersProvider>();

    if (provider.status == LoadStatus.loading ||
        provider.status == LoadStatus.idle) {
      return const SafeArea(child: LoadingView(message: 'Loading the roster'));
    }
    if (provider.status == LoadStatus.error) {
      return SafeArea(
        child: ErrorView(
          message: provider.errorMessage ?? 'Unknown error',
          onRetry: provider.load,
        ),
      );
    }

    final classes = <String>{for (final b in provider.brawlers) b.className}
        .toList()
      ..sort();
    final results = _filter(provider.brawlers);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header(provider.brawlers.length)),
          SliverToBoxAdapter(child: _search()),
          SliverToBoxAdapter(child: _classChips(classes)),
          if (results.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: _empty())
          else ...[
            _grid(results.take(_adAfter).toList()),
            if (results.length > _adAfter)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.gutter,
                    4,
                    AppSizes.gutter,
                    0,
                  ),
                  child: NativeAdTile(),
                ),
              ),
            if (results.length > _adAfter)
              _grid(results.skip(_adAfter).toList()),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  List<Brawler> _filter(List<Brawler> all) {
    return all.where((b) {
      final matchesClass = _classFilter == 'All' || b.className == _classFilter;
      final matchesQuery =
          _query.isEmpty || b.name.toLowerCase().contains(_query);
      return matchesClass && matchesQuery;
    }).toList();
  }

  Widget _header(int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 14, AppSizes.gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Brawlers', style: AppTheme.display(30)),
          const SizedBox(height: 2),
          Text(
            '$total in the game right now',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _search() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 14, AppSizes.gutter, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: 'Search a brawler',
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 10),
            child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 15),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const FaIcon(FontAwesomeIcons.xmark, size: 15),
                  color: AppColors.textMuted,
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
        ),
      ),
    );
  }

  Widget _classChips(List<String> classes) {
    final options = ['All', ...classes];
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 14, AppSizes.gutter, 0),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final label = options[i];
          return FilterPill(
            label: label,
            selected: label == _classFilter,
            onTap: () => setState(() => _classFilter = label),
          );
        },
      ),
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(
            FontAwesomeIcons.magnifyingGlass,
            size: 32,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 14),
          Text('No brawler by that name', style: AppTheme.display(19)),
          const SizedBox(height: 6),
          Text(
            'Check the spelling, or clear the class filter.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _grid(List<Brawler> items) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.gutter,
        14,
        AppSizes.gutter,
        0,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 190,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.80,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => _BrawlerCard(brawler: items[i]),
          childCount: items.length,
        ),
      ),
    );
  }
}

class _BrawlerCard extends StatelessWidget {
  final Brawler brawler;
  const _BrawlerCard({required this.brawler});

  @override
  Widget build(BuildContext context) {
    final rarity = brawler.rarityColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BrawlerDetailScreen(brawler: brawler),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(color: rarity.withValues(alpha: 0.9), width: 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                rarity.withValues(alpha: 0.34),
                AppColors.surface,
              ],
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: FallbackImage(
                        candidates: brawler.tileCandidates,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        fallback: BrawlerInitial(
                          name: brawler.name,
                          color: rarity,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: rarity,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          brawler.rarityName,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A0E38),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: AppColors.edge.withValues(alpha: 0.5),
                padding: const EdgeInsets.fromLTRB(9, 7, 9, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brawler.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.display(15),
                    ),
                    Text(
                      brawler.className,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
