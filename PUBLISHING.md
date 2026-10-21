# Publishing Brawl Toolbox to the App Store

This project was built and tested on Windows (Chrome for UI testing, an Android
emulator for the AdMob integration). iOS can only be compiled on a Mac with
Xcode, so the steps below pick up from there. The iOS-side AdMob native ad
code has **never been compiled** — this is the first thing that will actually
build it.

## 1. Prerequisites on the Mac

- Xcode (latest stable from the App Store)
- Flutter SDK installed (`flutter doctor` should show no blockers for iOS)
- An active **Apple Developer Program** membership ($99/year) — required to
  submit to the App Store, and to get real device signing working
- CocoaPods is **not** needed — this Flutter version resolves iOS packages via
  Swift Package Manager automatically

## 2. First build

```
cd BrawlToolbox-iOS-project
flutter pub get
open ios/Runner.xcworkspace
```

Always open the **`.xcworkspace`**, not `.xcodeproj`.

In Xcode:
1. Select the `Runner` target → **Signing & Capabilities**
2. Choose your Apple Developer **Team** and let Xcode auto-manage signing
3. Confirm the **Bundle Identifier** (`com.brawlfan.brawlFanApp`). Change it
   now if you'd rather use your own — it's much harder to change after you've
   registered it in App Store Connect
4. Build once for a simulator (`Cmd+R`) to confirm everything compiles,
   including the native ad factory in `AppDelegate.swift`

## 3. If the native ad code doesn't compile

`ListTileNativeAdFactory` in `ios/Runner/AppDelegate.swift` was written against
the documented `FLTNativeAdFactory` API but never compiled (no Mac was
available while building this). If Xcode reports type errors there, it's
almost always the `GAD`-prefixed type names (`GADNativeAd`, `GADNativeAdView`,
`GADMediaView`) — some SDK versions dropped that prefix. Try removing it if
the current names don't resolve.

If you'd rather not deal with it, you can delete the
`registerNativeAdFactory(...)` call and the `ListTileNativeAdFactory` class —
the in-feed native ad in the News screen will just quietly not appear
(`NativeAdTile` already renders nothing if the ad fails to load), everything
else is unaffected.

## 4. Known ad-integration status (tested on Android; see the conversation this
came from for details)

- ✅ Banner ad — confirmed working live
- ✅ Interstitial ad — confirmed working live (fires after a quiz round, and
  every 3rd wallpaper opened)
- ✅ App Open ad — code correct, preloads without errors
- ⚠️ Native ad (in-feed, News screen) — failed to load in one Android emulator
  test with a server-reported error, most likely tied to that emulator's
  outdated Google Play Services rather than an app bug (three real bugs along
  the way — missing `MediaView`, missing `mediaContent`, undersized media —
  were found and fixed). **Verify this specifically on a real device before
  relying on it**; the Dart layer already fails gracefully if it doesn't load.

All ad unit IDs automatically use Google's official test IDs in debug builds
and only switch to the real production IDs in a genuine `--release` build
(see `lib/core/ads/ad_ids.dart`). This protects the AdMob account from being
flagged for invalid traffic during testing — don't hardcode the real IDs
elsewhere.

## 5. Before submitting: things only you can decide/do

- **Privacy Policy URL** — required by App Store Connect for any app using
  ads/analytics. You'll need to host one (a simple static page is enough) that
  discloses AdMob's data collection.
- **App Privacy questionnaire** (App Store Connect → App Privacy) — declare
  the data AdMob collects (device identifiers, usage/diagnostics data). Google
  publishes exact wording for this in their AdMob docs.
- **Trademark/IP risk** — this is an unofficial fan app using "Brawl" in the
  name and Brawl Stars-adjacent branding/artwork sourced from a community API
  (not Supercell). Apple review or Supercell could object. Nothing here
  changes that risk calculus — it's worth a final look before you submit.
- **App Store Connect listing** — register the app (My Apps → New App),
  matching the bundle identifier from step 2, write the description, and
  prepare screenshots (Xcode Simulator → Cmd+S captures correctly-sized ones).

## 6. Archive & upload

```
flutter build ipa
```

Then open `build/ios/archive/Runner.xcarchive` in Xcode Organizer (or drag the
generated `.ipa` into the **Transporter** app) → **Distribute App** →
**App Store Connect**.
