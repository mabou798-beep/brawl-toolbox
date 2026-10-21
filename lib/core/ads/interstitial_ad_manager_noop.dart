/// Web build: every entry point is a no-op so call sites need no guards.
class InterstitialAdManager {
  InterstitialAdManager._();
  static final InterstitialAdManager instance = InterstitialAdManager._();

  bool get canShow => false;
  void preload() {}
  bool showIfAvailable() => false;
}
