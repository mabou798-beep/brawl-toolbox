import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/ads/native_ad_tile.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_news.dart';
import '../../models/news_post.dart';
import 'news_detail_screen.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  // One native ad slot after every 4 posts.
  static const _adInterval = 4;

  @override
  Widget build(BuildContext context) {
    final posts = mockNewsPosts;
    final totalItems = posts.length + (posts.length ~/ _adInterval);

    return Scaffold(
      appBar: AppBar(title: const Text('Community News')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: totalItems,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final isAdSlot = (i + 1) % (_adInterval + 1) == 0;
            if (isAdSlot) return const NativeAdTile();
            final adsBefore = (i + 1) ~/ (_adInterval + 1);
            return _NewsCard(post: posts[i - adsBefore]);
          },
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsPost post;
  const _NewsCard({required this.post});

  Color _categoryColor() {
    switch (post.category) {
      case 'Guide':
        return AppColors.accentBlue;
      case 'Fan Art':
        return AppColors.accentPink;
      case 'Esports':
        return AppColors.secondary;
      case 'Tips':
        return AppColors.accentGreen;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor();
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NewsDetailScreen(post: post)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      post.category,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
                    ),
                  ),
                  const Spacer(),
                  Text(post.timeAgo, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),
              Text(post.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                post.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const FaIcon(FontAwesomeIcons.solidHeart, size: 13, color: AppColors.accentPink),
                  const SizedBox(width: 4),
                  Text('${post.upvotes}', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(width: 16),
                  const FaIcon(FontAwesomeIcons.comment, size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text('${post.comments}', style: Theme.of(context).textTheme.bodyMedium),
                  const Spacer(),
                  Text(post.author, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
