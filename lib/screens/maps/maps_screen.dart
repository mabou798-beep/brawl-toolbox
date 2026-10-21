import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/ads/native_ad_tile.dart';
import '../../core/theme/app_theme.dart';
import '../../models/map_info.dart';
import '../../providers/brawlers_provider.dart';
import '../../providers/maps_provider.dart';
import '../../widgets/filter_pill.dart';
import '../../widgets/state_views.dart';

/// Every map in the game, searchable and filtered by mode. Modes are ordered
/// by how many maps they have rather than alphabetically, so the modes people
/// actually play sit at the front instead of "5 Player Void Boss".
class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _mode = 'All';

  static const _adAfter = 12;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MapsProvider>();

    if (provider.status == LoadStatus.loading ||
        provider.status == LoadStatus.idle) {
      return const SafeArea(child: LoadingView(message: 'Loading maps'));
    }
    if (provider.status == LoadStatus.error) {
      return SafeArea(
        child: ErrorView(
          message: provider.errorMessage ?? 'Unknown error',
          onRetry: provider.load,
        ),
      );
    }

    // Retired maps stay out of the browser — they can't be played.
    final live = provider.maps.where((m) => !m.disabled).toList();
    final modes = _modesByPopularity(live);
    final results = _filter(live);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header(live.length)),
          SliverToBoxAdapter(child: _search()),
          SliverToBoxAdapter(child: _modeChips(modes)),
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
            if (results.length > _adAfter) _grid(results.skip(_adAfter).toList()),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  List<String> _modesByPopularity(List<MapInfo> maps) {
    final counts = <String, int>{};
    for (final m in maps) {
      counts[m.gameModeName] = (counts[m.gameModeName] ?? 0) + 1;
    }
    final names = counts.keys.toList()
      ..sort((a, b) {
        final byCount = counts[b]!.compareTo(counts[a]!);
        return byCount != 0 ? byCount : a.compareTo(b);
      });
    return names;
  }

  List<MapInfo> _filter(List<MapInfo> maps) {
    return maps.where((m) {
      final matchesMode = _mode == 'All' || m.gameModeName == _mode;
      final matchesQuery =
          _query.isEmpty || m.name.toLowerCase().contains(_query);
      return matchesMode && matchesQuery;
    }).toList();
  }

  Widget _header(int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 14, AppSizes.gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Maps', style: AppTheme.display(30)),
          const SizedBox(height: 2),
          Text(
            '$total playable maps',
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
          hintText: 'Search a map',
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

  Widget _modeChips(List<String> modes) {
    final options = ['All', ...modes];
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
            selected: label == _mode,
            onTap: () => setState(() => _mode = label),
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
            FontAwesomeIcons.mapLocationDot,
            size: 32,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 14),
          Text('No map matches', style: AppTheme.display(19)),
          const SizedBox(height: 6),
          Text(
            'Try another spelling, or switch the mode back to All.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _grid(List<MapInfo> items) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 14, AppSizes.gutter, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.74,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => _MapCard(map: items[i]),
          childCount: items.length,
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final MapInfo map;
  const _MapCard({required this.map});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(
          color: map.gameModeColor.withValues(alpha: 0.7),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: map.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              placeholder: (_, _) => Container(color: AppColors.surfaceAlt),
              errorWidget: (_, _, _) => Container(
                color: AppColors.surfaceAlt,
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.map,
                    color: AppColors.textMuted,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColors.edge.withValues(alpha: 0.5),
            padding: const EdgeInsets.fromLTRB(11, 8, 11, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  map.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.display(16),
                ),
                Text(
                  map.gameModeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: map.gameModeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
