import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../theme/app_theme.dart';
import 'ad_ids.dart';

/// In-feed native ad tile. Renders via the platform-native template
/// registered under factory id [_factoryId] (see
/// android/.../NativeAdFactoryImpl.kt and ios/Runner/NativeAdFactoryImpl.swift).
/// Renders nothing while the ad is loading, so it never disrupts the
/// surrounding list layout.
class NativeAdTile extends StatefulWidget {
  const NativeAdTile({super.key});

  static const _factoryId = 'listTileNativeAd';

  @override
  State<NativeAdTile> createState() => _NativeAdTileState();
}

class _NativeAdTileState extends State<NativeAdTile> {
  NativeAd? _ad;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final ad = NativeAd(
      adUnitId: AdIds.native,
      factoryId: NativeAdTile._factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _ad = ad as NativeAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _ad == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Said in the app's own voice, above the ad itself: a player should
          // never have to work out which part of a screen we were paid for.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Text(
              'Sponsored',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
                color: AppColors.textMuted.withValues(alpha: 0.9),
              ),
            ),
          ),
          SizedBox(height: 150, child: AdWidget(ad: _ad!)),
        ],
      ),
    );
  }
}
