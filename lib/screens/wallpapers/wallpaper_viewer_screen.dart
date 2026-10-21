import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';

class WallpaperViewerScreen extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;

  const WallpaperViewerScreen({
    super.key,
    required this.urls,
    required this.initialIndex,
  });

  @override
  State<WallpaperViewerScreen> createState() => _WallpaperViewerScreenState();
}

class _WallpaperViewerScreenState extends State<WallpaperViewerScreen> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: _index);
  }

  Future<void> _openOriginal() async {
    final uri = Uri.parse(widget.urls[_index]);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('${_index + 1} / ${widget.urls.length}'),
        actions: [
          IconButton(
            onPressed: _openOriginal,
            icon: const FaIcon(FontAwesomeIcons.arrowUpRightFromSquare, size: 18),
            tooltip: 'Open full image',
          ),
        ],
      ),
      body: PhotoViewGallery.builder(
        pageController: _controller,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _index = i),
        builder: (context, i) => PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(widget.urls[i]),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 1.5,
          errorBuilder: (_, _, _) => const Center(
            child: FaIcon(FontAwesomeIcons.image, color: AppColors.textMuted, size: 48),
          ),
        ),
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(),
        ),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}
