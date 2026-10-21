import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app_open_ad_manager.dart';
import 'interstitial_ad_manager.dart';

/// Starts the ad SDK and warms up the placements that are shown later.
Future<void> initializeAds() async {
  await MobileAds.instance.initialize();
  AppOpenAdManager.instance.start();
  InterstitialAdManager.instance.preload();
}
