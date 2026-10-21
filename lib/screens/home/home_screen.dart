import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/brawler.dart';
import '../../models/live_event.dart';
import '../../models/map_info.dart';
import '../../providers/brawlers_provider.dart';
import '../../providers/events_provider.dart';
import '../../providers/maps_provider.dart';
import '../../widgets/brawler_initial.dart';
import '../../widgets/fallback_image.dart';
import '../../widgets/state_views.dart';
import '../brawler_detail/brawler_detail_screen.dart';
import '../quiz/quiz_screen.dart';
import '../wallpapers/wallpapers_screen.dart';

/// Home is a front door, not a dashboard: one brawler to look at today, two
/// things to do, and a short path into the roster and the maps. Everything on
/// it is real data — nothing is sampled, invented or timestamped.
class HomeScreen extends StatelessWidget {
  /// Switches the bottom bar to another tab (1 = Brawlers, 2 = Maps).
  final ValueChanged<int> onOpenTab;

  const HomeScreen({super.key, required this.onOpenTab});

  @override
  Widget build(BuildContext context) {
    final brawlers = context.watch<BrawlersProvider>();
    final maps = context.watch<MapsProvider>();
    final events = context.watch<EventsProvider>();

    if (brawlers.status == LoadStatus.loading ||
        brawlers.status == LoadStatus.idle) {
      return const SafeArea(child: LoadingView(message: 'Waking up the hub'));
    }
    if (brawlers.status == LoadStatus.error) {
      return SafeArea(
        child: ErrorView(
          message: brawlers.errorMessage ?? 'Unknown error',
          onRetry: brawlers.load,
        ),
      );
    }

    final roster = brawlers.brawlers;
    final daily = _brawlerOfTheDay(roster);
    final newest = [...roster]..sort((a, b) => b.id.compareTo(a.id));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          _title(context),
          if (daily != null) _DailyHero(brawler: daily),
          _actions(context),
          ..._liveSection(context, events, maps),
          _sectionHeader(
            context,
            'Newest brawlers',
            'See all',
            () => onOpenTab(1),
          ),
          _newestRow(context, newest.take(10).toList()),
        ],
      ),
    );
  }

  /// Same brawler for everyone, all day, changing at midnight — a reason to
  /// open the app tomorrow without pretending anything is "live".
  Brawler? _brawlerOfTheDay(List<Brawler> roster) {
    if (roster.isEmpty) return null;
    final day = DateTime.now().toUtc();
    final index =
        DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    return roster[index % roster.length];
  }

  Widget _title(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 14, AppSizes.gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Brawl Toolbox', style: AppTheme.display(30)),
          const SizedBox(height: 2),
          Text(
            'An unofficial companion for Brawl Stars',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 14, AppSizes.gutter, 0),
      child: Row(
        children: [
          Expanded(
            child: _ActionCard(
              label: 'Daily quiz',
              hint: 'Name the brawler',
              icon: FontAwesomeIcons.circleQuestion,
              tint: AppColors.accentBlue,
              open: (_) => const QuizScreen(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionCard(
              label: 'Brawler art',
              hint: 'All 109 renders',
              icon: FontAwesomeIcons.image,
              tint: AppColors.accentPink,
              open: (_) => const WallpapersScreen(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    String title,
    String action,
    VoidCallback onAction,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 26, 8, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.display(22)),
          TextButton(
            onPressed: onAction,
            child: Text(
              action,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _newestRow(BuildContext context, List<Brawler> items) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _MiniBrawler(brawler: items[i]),
      ),
    );
  }

  /// What is actually playable right now, from Supercell's own rotation. If
  /// the rotation can't be reached the section degrades to the map catalogue
  /// rather than disappearing.
  List<Widget> _liveSection(
    BuildContext context,
    EventsProvider events,
    MapsProvider maps,
  ) {
    final running = events.live;

    if (events.status != LoadStatus.loaded || running.isEmpty) {
      return [
        _sectionHeader(context, 'Maps', 'Browse all', () => onOpenTab(2)),
        if (events.status == LoadStatus.loading)
          const SizedBox(
            height: 132,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ),
          )
        else
          _mapsPreview(context, maps),
      ];
    }

    // The rotation names a map; the catalogue has its art and mode colour.
    // The two sources punctuate differently ("Belle's Rock" vs "Belles Rock"),
    // and the catalogue keeps retired versions of a map under the same name,
    // so match on letters alone and prefer the version still in rotation.
    final art = <String, MapInfo>{};
    for (final m in maps.maps) {
      final key = _mapKey(m.name);
      final existing = art[key];
      if (existing == null || (existing.disabled && !m.disabled)) {
        art[key] = m;
      }
    }

    return [
      _sectionHeader(context, 'Live right now', 'All maps', () => onOpenTab(2)),
      SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
          itemCount: running.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, i) => _LiveEventCard(
            event: running[i],
            map: art[_mapKey(running[i].mapName)],
            onTap: () => onOpenTab(2),
          ),
        ),
      ),
    ];
  }

  /// Letters and digits only, lowercased — the one form both the official
  /// rotation and the BrawlAPI catalogue agree on.
  static String _mapKey(String raw) =>
      raw.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

  Widget _mapsPreview(BuildContext context, MapsProvider maps) {
    if (maps.status != LoadStatus.loaded || maps.maps.isEmpty) {
      return const SizedBox(height: 8);
    }
    final live = maps.maps.where((m) => !m.disabled).take(8).toList();

    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
        itemCount: live.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final map = live[i];
          return SizedBox(
            width: 186,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radius),
                border: Border.all(
                  color: map.gameModeColor.withValues(alpha: 0.75),
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
                      placeholder: (_, _) =>
                          Container(color: AppColors.surfaceAlt),
                      errorWidget: (_, _, _) =>
                          Container(color: AppColors.surfaceAlt),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 7, 10, 9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          map.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.display(15),
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
            ),
          );
        },
      ),
    );
  }
}

class _LiveEventCard extends StatelessWidget {
  final LiveEvent event;

  /// Catalogue entry for [LiveEvent.mapName], when BrawlAPI has one — it
  /// carries the map art and the mode's own colour.
  final MapInfo? map;
  final VoidCallback onTap;

  const _LiveEventCard({required this.event, required this.map, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tint = map?.gameModeColor ?? AppColors.secondary;
    final left = event.remainingLabel;

    return SizedBox(
      width: 200,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radius),
              border: Border.all(color: tint.withValues(alpha: 0.75), width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (map != null && map!.imageUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: map!.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: AppColors.surfaceAlt),
                          errorWidget: (_, _, _) =>
                              Container(color: AppColors.surfaceAlt),
                        )
                      else
                        Container(color: AppColors.surfaceAlt),
                      if (left != null)
                        Positioned(
                          top: 7,
                          right: 7,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.edge.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              left,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.mapName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.display(15),
                      ),
                      Text(
                        event.modeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: tint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyHero extends StatelessWidget {
  final Brawler brawler;
  const _DailyHero({required this.brawler});

  @override
  Widget build(BuildContext context) {
    final rarity = brawler.rarityColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 16, AppSizes.gutter, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BrawlerDetailScreen(brawler: brawler),
            ),
          ),
          child: Container(
            height: 208,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: rarity.withValues(alpha: 0.9), width: 2),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.surface,
                  rarity.withValues(alpha: 0.45),
                ],
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned(
                  right: 4,
                  bottom: 0,
                  top: 10,
                  width: 190,
                  child: FallbackImage(
                    candidates: brawler.artCandidates,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomRight,
                    fallback: const SizedBox.shrink(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Brawler of the day',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2B1A00),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(brawler.name, style: AppTheme.display(38)),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _HeroTag(label: brawler.rarityName, color: rarity),
                          const SizedBox(width: 7),
                          _HeroTag(
                            label: brawler.className,
                            color: AppColors.textMuted,
                            outlined: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Star powers and gadgets',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontSize: 12.5),
                          ),
                          const SizedBox(width: 6),
                          const FaIcon(
                            FontAwesomeIcons.chevronRight,
                            size: 10,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final String hint;
  final FaIconData icon;
  final Color tint;
  final WidgetBuilder open;

  const _ActionCard({
    required this.label,
    required this.hint,
    required this.icon,
    required this.tint,
    required this.open,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: open)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(icon, color: tint, size: 17),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.display(16),
                    ),
                    Text(
                      hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
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

class _MiniBrawler extends StatelessWidget {
  final Brawler brawler;
  const _MiniBrawler({required this.brawler});

  @override
  Widget build(BuildContext context) {
    final rarity = brawler.rarityColor;

    return SizedBox(
      width: 108,
      child: Material(
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
              border: Border.all(color: rarity.withValues(alpha: 0.85), width: 2),
              color: AppColors.surface,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: FallbackImage(
                    candidates: brawler.tileCandidates,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    fallback: BrawlerInitial(
                      name: brawler.name,
                      color: rarity,
                      size: 26,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: AppColors.edge.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 7),
                  child: Text(
                    brawler.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTheme.display(13.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;

  const _HeroTag({
    required this.label,
    required this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color,
        border: outlined
            ? Border.all(color: color.withValues(alpha: 0.55))
            : null,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: outlined ? AppColors.textMuted : const Color(0xFF1A0E38),
        ),
      ),
    );
  }
}
