import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/brawlers_provider.dart';
import '../../widgets/state_views.dart';
import 'wallpaper_viewer_screen.dart';

class WallpapersScreen extends StatelessWidget {
  const WallpapersScreen({super.key});

  // No interstitial here on purpose: opening a piece of artwork is the thing
  // the screen exists for, not a break in the flow. The only full-screen ad
  // in the app sits at the end of a quiz round.

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrawlersProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Wallpapers')),
      body: SafeArea(child: _buildBody(context, provider)),
    );
  }

  Widget _buildBody(BuildContext context, BrawlersProvider provider) {
    if (provider.status == LoadStatus.loading || provider.status == LoadStatus.idle) {
      return const LoadingView(message: 'Fetching hi-res artwork...');
    }
    if (provider.status == LoadStatus.error) {
      return ErrorView(
        message: provider.errorMessage ?? 'Unknown error',
        onRetry: () => provider.load(),
      );
    }

    final urls = provider.wallpaperUrls;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '${urls.length} wallpapers • hi-res model art, live from BrawlAPI',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.6,
            ),
            itemCount: urls.length,
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WallpaperViewerScreen(urls: urls, initialIndex: i),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: urls[i],
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(color: AppColors.surfaceAlt),
                    errorWidget: (_, _, _) => Container(
                      color: AppColors.surfaceAlt,
                      child: const FaIcon(FontAwesomeIcons.image, color: AppColors.textMuted),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
