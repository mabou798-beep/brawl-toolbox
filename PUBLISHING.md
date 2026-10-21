# Brawl Toolbox — publishing status

Last updated: 21 October 2026, 02:30 (Africa/Casablanca)

This file replaces the earlier Mac/Xcode-centred version, which was written
before the Codemagic route was chosen and is no longer accurate.

---

## Where we stopped

Everything up to **starting the first Codemagic build** is done. The next
action is step 4 below.

## Key values (keep these together)

| | |
|---|---|
| App name (App Store) | `Brawl Toolbox for Brawl Stars` |
| Home-screen name | `Brawl Toolbox` |
| Bundle ID | `com.brawlfan.brawlFanApp` |
| Apple ID (App Store Connect) | `6825153847` |
| SKU | `brawltoolbox` |
| Apple Team ID | `K4PS39S352` |
| GitHub repo | `https://github.com/mabou798-beep/brawl-toolbox` (public) |
| Privacy Policy URL | `https://mabou798-beep.github.io/brawl-toolbox/privacy.html` |
| Support URL | `https://mabou798-beep.github.io/brawl-toolbox/` |
| Codemagic API key name | `Codemagic` (the one already used for TCG Companion) |
| Backend | Cloudflare Worker `brawl-toolbox-api.terravisioncontractors.workers.dev` |

---

## 1. Code — done

- Live event rotation from Supercell's official API, via the Cloudflare Worker
  (BrawlAPI's own `/events` endpoint returns an empty list, which is why the
  Worker exists at all).
- Player stats: profile, top brawlers, last battles, pull to refresh.
- Brawlers, maps, brawler detail, quiz (silhouettes fixed — they are drawn
  from the full-body model render, the only CDN image with a transparent
  background).
- Fake Shop and mock News are unreachable from the UI. **Their files still
  exist** (`lib/screens/shop/`, `lib/screens/news/`, `lib/data/mock_news.dart`,
  `lib/models/shop_offer.dart`, `lib/models/news_post.dart`) — nothing imports
  them, so they are not compiled in. Deleting them is housekeeping, but never
  wire them back up: fabricated shop and news data is a Guideline 4.1 risk.
- Supercell's required disclaimer is on the More tab, in the exact wording the
  Fan Content Policy asks for, with a link to the policy.
- `flutter analyze` → **No issues found!**

## 2. iOS configuration — done, and why

Each of these was a problem that cost a build or a rejection on the first app
(TCG Companion). They are all pre-empted here.

| Setting | Value | Reason |
|---|---|---|
| `AppDelegate.swift` native ad factory | `NativeAd` / `NativeAdView` / `MediaView` | GMA iOS SDK 12.0.0 dropped the `GAD` prefix in Swift; google_mobile_ads 9.0.0 pulls SDK 13.3.0 |
| `IPHONEOS_DEPLOYMENT_TARGET` | `15.5` | TCG Companion needed exactly this on the same toolchain |
| `SKAdNetworkItems` | 55 networks | Without it iOS 14+ ad attribution fails and iOS revenue drops |
| `ITSAppUsesNonExemptEncryption` | `false` | Without it every TestFlight build stalls on "Missing Compliance" |
| `.gitattributes` | `* text=auto` | Windows CRLF breaking scripts on the macOS builder |
| App Tracking Transparency | requested 600 ms after first frame | Apple only shows the prompt while the app is on screen and active; requesting it in `main()` means it never appears |

Build settings are now identical to TCG Companion's in every respect except
the bundle identifier.

## 3. App Store Connect — done

App record created, category **Reference** (deliberately not Games), privacy
policy URL set.

---

## 4. NEXT: first Codemagic build

1. codemagic.io → **Add application** → **GitHub** → grant access to
   `brawl-toolbox` → **Flutter App** → **codemagic.yaml**
2. Check **Teams → Integrations → Developer Portal** lists a key named exactly
   `Codemagic`
3. **Start new build** → branch `main` → workflow `ios-release`

`codemagic.yaml` is a copy of the workflow that already ships TCG Companion,
so the three failed `Update codemagic.yaml` commits from that app should not
repeat. It builds and uploads to TestFlight; it does **not** submit for
review.

## 5. After the build reaches TestFlight

Install on a real iPhone and check the four things that have never run on a
device:

- [ ] ATT prompt appears about a second after launch
- [ ] Banner ad shows above the tab bar
- [ ] **Native ad inside the Brawlers list** — the least certain of the four
- [ ] Player tag survives a full app restart (the web build cannot persist it;
      that is a web-platform quirk, not an app bug)

## 6. Then, before submitting

- [ ] App Privacy questionnaire — AdMob collects device identifiers and usage
      data **used for tracking**; the player tag is user content sent to
      Supercell. Do this one carefully, with the privacy policy open beside it.
- [ ] Content Rights: the app does contain third-party content, and you do
      hold the rights, through Supercell's Fan Content Policy. This is the
      question that had no good answer on the Pokémon app.
- [ ] Screenshots (iPhone 6.9" and 6.5" are the required sizes)
- [ ] Description — must contain the word **Unofficial** and Supercell's
      disclaimer sentence
- [ ] Decide iPhone-only vs iPhone+iPad. TCG Companion ended up iPhone-only,
      and that was done in App Store Connect, not in the Xcode project.
      iPad support means iPad screenshots and an iPad-worthy layout.

### Suggested store metadata

- **Subtitle** (30 max): `Unofficial stats, maps, events`
- **Keywords** (100 max, no spaces after commas):
  `brawl,stars,companion,stats,tracker,brawler,maps,events,rotation,quiz,guide,tier,unofficial`

---

## Standing constraints

- **The app icon must not contain** the star-skull emblem, the Brawl Stars
  logotype, or any Supercell character. Game artwork inside the app is
  permitted by the Fan Content Policy; the icon is the app's own identity, and
  putting their mark there is what Guideline 4.1 Copycats is about. Three
  candidate icons were rejected on this basis before the current one.
- The Supercell API token lives only in the Cloudflare Worker. It is not in
  this repository, and it must not be.
- Ad placement, as decided: anchored banner always; interstitial only at the
  end of a quiz round (3-minute cooldown, max 3 per session); App Open on
  every return to the foreground after the cold start; native tiles labelled
  "Sponsored".
