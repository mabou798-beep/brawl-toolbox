import 'package:flutter/foundation.dart';

/// Central place for AdMob identifiers.
///
/// Google's policy prohibits generating real ad requests/impressions from a
/// development build, so every ad unit here falls back to Google's official
/// public test IDs whenever the app is not a release build. Only a genuine
/// `flutter build ... --release` uses the real production IDs below.
/// See: https://developers.google.com/admob/flutter/test-ads
class AdIds {
  AdIds._();

  static const String appId = 'ca-app-pub-5482329013197519~7858236887';

  static const String _bannerProd = 'ca-app-pub-5482329013197519/3636609206';
  static const String _interstitialProd =
      'ca-app-pub-5482329013197519/1508450958';
  static const String _nativeProd = 'ca-app-pub-5482329013197519/2483309639';
  static const String _appOpenProd = 'ca-app-pub-5482329013197519/7384282522';

  // Google's official public test ad unit IDs (safe to request unlimited
  // impressions/clicks on, used automatically for every non-release build).
  static const String _bannerTest = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialTest =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _nativeTest = 'ca-app-pub-3940256099942544/2247696110';
  static const String _appOpenTest = 'ca-app-pub-3940256099942544/9257395921';

  static bool get _useRealIds => kReleaseMode;

  static String get banner => _useRealIds ? _bannerProd : _bannerTest;
  static String get interstitial =>
      _useRealIds ? _interstitialProd : _interstitialTest;
  static String get native => _useRealIds ? _nativeProd : _nativeTest;
  static String get appOpen => _useRealIds ? _appOpenProd : _appOpenTest;
}
