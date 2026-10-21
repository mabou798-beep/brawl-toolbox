import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../models/news_post.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsPost post;
  const NewsDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                post.category,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(post.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(post.author, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 10),
                const Text('•', style: TextStyle(color: AppColors.textMuted)),
                const SizedBox(width: 10),
                Text(post.timeAgo, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              post.body,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.solidHeart, size: 16, color: AppColors.accentPink),
                const SizedBox(width: 6),
                Text('${post.upvotes} upvotes', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 20),
                const FaIcon(FontAwesomeIcons.comment, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text('${post.comments} comments', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
