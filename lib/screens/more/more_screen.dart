import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../quiz/quiz_screen.dart';
import '../wallpapers/wallpapers_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_MoreItem>[
      _MoreItem(
        title: 'Quiz',
        subtitle: 'Name the brawler from the artwork',
        icon: FontAwesomeIcons.circleQuestion,
        color: AppColors.accentBlue,
        open: (_) => const QuizScreen(),
      ),
      _MoreItem(
        title: 'Brawler art',
        subtitle: 'Full-size artwork for all 109 brawlers',
        icon: FontAwesomeIcons.image,
        color: AppColors.accentPink,
        open: (_) => const WallpapersScreen(),
      ),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.gutter,
          14,
          AppSizes.gutter,
          28,
        ),
        children: [
          Text('More', style: AppTheme.display(30)),
          const SizedBox(height: 2),
          Text(
            'Everything outside the roster',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          for (final item in items) ...[
            _MoreTile(item: item),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 22),
          const _FanContentNotice(),
        ],
      ),
    );
  }
}

/// The wording here is the disclaimer Supercell's Fan Content Policy requires
/// verbatim — it is what makes this app's use of their names and artwork
/// permitted, so do not reword it.
class _FanContentNotice extends StatelessWidget {
  const _FanContentNotice();

  static const _policyUrl = 'https://www.supercell.com/fan-content-policy';

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontSize: 11.5, height: 1.45);

    return Column(
      children: [
        Text(
          'This content is not affiliated with, endorsed, sponsored, or '
          'specifically approved by Supercell and Supercell is not responsible '
          'for it.',
          textAlign: TextAlign.center,
          style: style,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => launchUrl(
            Uri.parse(_policyUrl),
            mode: LaunchMode.externalApplication,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              "Supercell's Fan Content Policy",
              textAlign: TextAlign.center,
              style: style?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Player and event data from the official Brawl Stars API. '
          'Brawler, map and game mode data from BrawlAPI.',
          textAlign: TextAlign.center,
          style: style,
        ),
      ],
    );
  }
}

class _MoreItem {
  final String title;
  final String subtitle;
  final FaIconData icon;
  final Color color;
  final WidgetBuilder open;

  _MoreItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.open,
  });
}

class _MoreTile extends StatelessWidget {
  final _MoreItem item;
  const _MoreTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: item.open)),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: FaIcon(item.icon, color: item.color, size: 19),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: AppTheme.display(17)),
                    const SizedBox(height: 1),
                    Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 13,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
