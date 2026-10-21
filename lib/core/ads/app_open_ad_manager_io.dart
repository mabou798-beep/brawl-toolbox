import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_ids.dart';

/// The "App Open" placement: a full-screen ad when the player comes back to
/// the app.
///
/// Three rules keep it from being the thing people remember about the app:
/// it never fires on the cold start (they opened it on purpose), it ignores a
/// quick trip out of the app — [_minBackgroundDuration], which is what a
/// player checking their tag in Brawl Stars and coming straight back looks
/// like — and it waits [_minIntervalBetweenShows] between any two showings.
class AppOpenAdManager with WidgetsBindingObserver {
  AppOpenAdManager._();
  static final AppOpenAdManager instance = AppOpenAdManager._();

  /// Away for less than this and the return isn't treated as a new session.
  static const Duration _minBackgroundDuration = Duration(seconds: 30);

  /// At most one app-open ad per this window, however often they switch back.
  static const Duration _minIntervalBetweenShows = Duration(hours: 4);

  /// How long a loaded ad stays usable — an AdMob requirement, unrelated to
  /// how often one is shown.
  static const Duration _maxCacheDuration = Duration(hours: 4);

  AppOpenAd? _ad;
  bool _isLoading = false;
  bool _isShowingAd = false;
  DateTime? _loadedAt;
  DateTime? _lastShownAt;
  DateTime? _backgroundedAt;
  bool _hadFirstResume = false;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _preload();
  }

  void _preload() {
    if (_isLoading || _isAdAvailable) return;
    _isLoading = true;
    AppOpenAd.load(
      adUnitId: AdIds.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loadedAt = DateTime.now();
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _ad = null;
        },
      ),
    );
  }

  bool get _isAdAvailable {
    if (_ad == null || _loadedAt == null) return false;
    return DateTime.now().difference(_loadedAt!) < _maxCacheDuration;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // An ad of our own covering the app also counts as "paused"; that is
      // not the player leaving, so don't restart the away-clock for it.
      if (!_isShowingAd) _backgroundedAt = DateTime.now();
      return;
    }
    if (state != AppLifecycleState.resumed) return;

    if (!_hadFirstResume) {
      // Cold start: they just launched the app deliberately.
      _hadFirstResume = true;
      return;
    }

    final now = DateTime.now();
    final awayFor = _backgroundedAt == null
        ? Duration.zero
        : now.difference(_backgroundedAt!);
    if (awayFor < _minBackgroundDuration) {
      _preload();
      return;
    }

    final last = _lastShownAt;
    if (last != null && now.difference(last) < _minIntervalBetweenShows) {
      _preload();
      return;
    }

    _showIfAvailable();
  }

  void _showIfAvailable() {
    if (_isShowingAd || !_isAdAvailable) {
      _preload();
      return;
    }
    final ad = _ad!;
    _ad = null;
    _isShowingAd = true;
    _lastShownAt = DateTime.now();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        _lastShownAt = null; // never seen, so it shouldn't start the clock
        ad.dispose();
        _preload();
      },
    );
    ad.show();
  }
}
