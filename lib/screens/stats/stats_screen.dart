import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/player.dart';
import '../../providers/brawlers_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/fallback_image.dart';
import '../../widgets/state_views.dart';

/// The player's own profile. This is the reason to open the app on a day when
/// nothing else changed, so it gets its own tab rather than living under More.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    if (!player.hasTag) return SafeArea(child: _tagEntry(player));
    if (player.status == LoadStatus.loading && player.profile == null) {
      return const SafeArea(child: LoadingView(message: 'Reading your profile'));
    }
    if (player.profile == null) {
      return SafeArea(
        child: ErrorView(
          message: player.errorMessage ?? 'Unknown error',
          onRetry: player.refresh,
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: player.refresh,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.gutter,
            14,
            AppSizes.gutter,
            28,
          ),
          children: [
            _identity(player.profile!),
            const SizedBox(height: 16),
            _statGrid(player.profile!),
            const SizedBox(height: 26),
            Text('Top brawlers', style: AppTheme.display(22)),
            const SizedBox(height: 10),
            ..._topBrawlers(player.profile!),
            const SizedBox(height: 26),
            Text('Recent battles', style: AppTheme.display(22)),
            const SizedBox(height: 10),
            if (player.battles.isEmpty)
              Text(
                'No battles in the last 25 games.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...player.battles.take(12).map((b) => _BattleRow(battle: b)),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () async {
                  await player.forget();
                  _tagController.clear();
                },
                child: const Text(
                  'Use a different tag',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagEntry(PlayerProvider player) {
    final busy = player.status == LoadStatus.loading;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 40, AppSizes.gutter, 24),
      children: [
        Text('Your stats', style: AppTheme.display(30)),
        const SizedBox(height: 6),
        Text(
          'Enter your player tag to see your trophies, your brawlers and your '
          'last battles.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 22),
        TextField(
          controller: _tagController,
          textCapitalization: TextCapitalization.characters,
          autocorrect: false,
          enabled: !busy,
          onSubmitted: (v) => player.lookup(v),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
          decoration: const InputDecoration(
            hintText: '#2PP0GL9',
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 16, right: 10),
              child: FaIcon(FontAwesomeIcons.hashtag, size: 14),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 0),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: busy ? null : () => player.lookup(_tagController.text),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: const Color(0xFF2B1A00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Look me up', style: AppTheme.display(17,
                    color: const Color(0xFF2B1A00))),
          ),
        ),
        if (player.errorMessage != null) ...[
          const SizedBox(height: 14),
          Text(
            player.errorMessage!,
            style: const TextStyle(
              color: AppColors.accentPink,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Where is my tag?', style: AppTheme.display(16)),
              const SizedBox(height: 6),
              Text(
                'Open Brawl Stars and tap your name at the top left. The tag '
                'sits under it and starts with #.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _identity(PlayerProfile p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(p.name, style: AppTheme.display(30)),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              p.tag,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
            if (p.clubName != null) ...[
              const SizedBox(width: 10),
              const FaIcon(
                FontAwesomeIcons.shield,
                size: 11,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  p.clubName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
        if (p.rankedRankName != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.25),
              border: Border.all(color: AppColors.secondary),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(p.rankedRankName!, style: AppTheme.display(14)),
                if (p.rankedElo != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${p.rankedElo} elo',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _statGrid(PlayerProfile p) {
    final cells = <_Stat>[
      _Stat('Trophies', p.trophies, AppColors.primary, FontAwesomeIcons.trophy),
      _Stat('Personal best', p.highestTrophies, AppColors.accentBlue,
          FontAwesomeIcons.arrowTrendUp),
      _Stat('3v3 wins', p.wins3v3, AppColors.accentGreen,
          FontAwesomeIcons.usersLine),
      _Stat('Solo wins', p.soloWins, AppColors.accentPink,
          FontAwesomeIcons.user),
      _Stat('Duo wins', p.duoWins, AppColors.secondary,
          FontAwesomeIcons.userGroup),
      _Stat('Level', p.expLevel, AppColors.primary, FontAwesomeIcons.star),
    ];

    // Max-extent, not a fixed column count: on a phone this lands on two
    // columns, and on a wide window it adds columns instead of stretching
    // each tile into a near-empty panel.
    return GridView.extent(
      maxCrossAxisExtent: 210,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: [for (final c in cells) _StatTile(stat: c)],
    );
  }

  List<Widget> _topBrawlers(PlayerProfile p) {
    final sorted = [...p.brawlers]
      ..sort((a, b) => b.trophies.compareTo(a.trophies));
    return sorted.take(5).map((b) => _BrawlerRow(brawler: b)).toList();
  }
}

String formatNumber(int n) {
  return n.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]} ',
  );
}

class _Stat {
  final String label;
  final int value;
  final Color color;
  final FaIconData icon;
  _Stat(this.label, this.value, this.color, this.icon);
}

class _StatTile extends StatelessWidget {
  final _Stat stat;
  const _StatTile({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Row(
        children: [
          FaIcon(stat.icon, size: 15, color: stat.color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formatNumber(stat.value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.display(20),
                ),
                Text(
                  stat.label,
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
    );
  }
}

class _BrawlerRow extends StatelessWidget {
  final PlayerBrawler brawler;
  const _BrawlerRow({required this.brawler});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 42,
              height: 42,
              child: FallbackImage(
                candidates: [brawler.portraitUrl],
                fit: BoxFit.cover,
                fallback: Container(color: AppColors.surfaceAlt),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(brawler.name, style: AppTheme.display(16)),
                Text(
                  'Power ${brawler.power}   Rank ${brawler.rank}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatNumber(brawler.trophies), style: AppTheme.display(17)),
              Text(
                'best ${formatNumber(brawler.highestTrophies)}',
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BattleRow extends StatelessWidget {
  final Battle battle;
  const _BattleRow({required this.battle});

  @override
  Widget build(BuildContext context) {
    final color = battle.isWin
        ? AppColors.accentGreen
        : battle.isLoss
            ? AppColors.accentPink
            : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  battle.map,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.display(15),
                ),
                Text(
                  '${battle.mode}   ${_ago(battle.time)}',
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
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                battle.result,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              if (battle.trophyChange != 0)
                Text(
                  battle.trophyChange > 0
                      ? '+${battle.trophyChange}'
                      : '${battle.trophyChange}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _ago(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
