import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Tries each URL in turn and shows [fallback] only once every one has failed.
///
/// The CDN is missing art for the few newest brawlers (model renders for four
/// of them, ability icons for about one in ten), so a single URL leaves holes
/// in the grid. Walking a list keeps those cards looking finished.
class FallbackImage extends StatefulWidget {
  final List<String> candidates;
  final BoxFit fit;
  final Alignment alignment;
  final Widget fallback;
  final Widget? placeholder;

  const FallbackImage({
    super.key,
    required this.candidates,
    required this.fallback,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.placeholder,
  });

  @override
  State<FallbackImage> createState() => _FallbackImageState();
}

class _FallbackImageState extends State<FallbackImage> {
  int _index = 0;

  @override
  void didUpdateWidget(FallbackImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final was = oldWidget.candidates.isEmpty ? null : oldWidget.candidates.first;
    final now = widget.candidates.isEmpty ? null : widget.candidates.first;
    if (was != now) {
      _index = 0;
    }
  }

  void _next() {
    // errorWidget runs during build, so the move to the next URL has to wait
    // for the frame to finish.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _index < widget.candidates.length) {
        setState(() => _index++);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.candidates.where((u) => u.isNotEmpty).toList();
    if (_index >= urls.length) return widget.fallback;

    return CachedNetworkImage(
      imageUrl: urls[_index],
      fit: widget.fit,
      alignment: widget.alignment,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, _) => widget.placeholder ?? const SizedBox.shrink(),
      errorWidget: (_, _, _) {
        _next();
        return widget.placeholder ?? const SizedBox.shrink();
      },
    );
  }
}
