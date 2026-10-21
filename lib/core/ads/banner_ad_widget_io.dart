import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_ids.dart';

/// Adaptive anchored banner. Renders nothing while the ad is still loading,
/// so it never reserves layout space it isn't using.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _isLoaded = false;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery isn't safe to read in initState (dependency tracking isn't
    // set up yet); didChangeDependencies is the earliest safe point, and the
    // _requested guard keeps this a one-time load rather than reloading on
    // every dependency change (e.g. orientation).
    if (!_requested) {
      _requested = true;
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
      MediaQuery.sizeOf(context).width.truncate(),
    );
    if (size == null || !mounted) return;

    final ad = BannerAd(
      adUnitId: AdIds.banner,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _ad = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
