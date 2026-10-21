import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_ids.dart';

/// Loads interstitials ahead of time and shows them only at a natural break
/// in what the player is doing — in practice, the end of a quiz round.
///
/// The frequency rules below are the whole point of this class. An
/// interstitial that fires whenever one happens to be loaded is what gets a
/// companion app uninstalled, and what Apple reads as an app built around its
/// ads rather than its content, so a show has to clear three gates: a real
/// break in the flow (the call site's job), [_minInterval] since the last one,
/// and [_maxPerSession] not yet reached.
class InterstitialAdManager {
  InterstitialAdManager._();
  static final InterstitialAdManager instance = InterstitialAdManager._();

  /// Quiet period after any interstitial. A player who finishes two quick
  /// rounds back to back sees one ad, not two.
  static const Duration _minInterval = Duration(minutes: 3);

  /// Ceiling for one run of the app, however long the session lasts.
  static const int _maxPerSession = 3;

  InterstitialAd? _ad;
  bool _isLoading = false;
  DateTime? _lastShownAt;
  int _shownThisSession = 0;

  /// True when an interstitial is allowed right now — exposed so a call site
  /// can decide what to do instead (e.g. go straight to the results screen).
  bool get canShow {
    if (_shownThisSession >= _maxPerSession) return false;
    final last = _lastShownAt;
    if (last != null && DateTime.now().difference(last) < _minInterval) {
      return false;
    }
    return true;
  }

  void preload() {
    if (_isLoading || _ad != null) return;
    _isLoading = true;
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _ad = null;
        },
      ),
    );
  }

  /// Shows the preloaded interstitial if the frequency rules allow it and one
  /// is ready. Returns whether an ad was actually shown.
  bool showIfAvailable() {
    if (!canShow) return false;
    if (_ad == null) {
      preload();
      return false;
    }

    final ad = _ad!;
    _ad = null;
    _lastShownAt = DateTime.now();
    _shownThisSession++;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        // Never shown, so it shouldn't count against the session budget.
        _shownThisSession--;
        _lastShownAt = null;
        preload();
      },
    );
    ad.show();
    return true;
  }
}
