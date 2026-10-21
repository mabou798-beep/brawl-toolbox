/// Web build: every entry point is a no-op so call sites need no guards.
class AppOpenAdManager {
  AppOpenAdManager._();
  static final AppOpenAdManager instance = AppOpenAdManager._();

  void start() {}
}
