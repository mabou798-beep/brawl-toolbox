import Flutter
import UIKit
import google_mobile_ads
import GoogleMobileAds

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      engineBridge.pluginRegistry,
      factoryId: "listTileNativeAd",
      nativeAdFactory: ListTileNativeAdFactory()
    )
  }
}

/// Renders the in-feed native ads that appear inside the brawler and map
/// lists. Registered under factory id "listTileNativeAd" — must match
/// NativeAdTile._factoryId in lib/core/ads/native_ad_tile_io.dart.
///
/// Type names here have no `GAD` prefix on purpose: from Google Mobile Ads
/// iOS SDK 12.0.0 the Swift API dropped it (`GADNativeAdView` → `NativeAdView`
/// and so on), and google_mobile_ads 9.0.0 pulls SDK 13.3.0. The Objective-C
/// names were left unchanged, which is why older samples still show `GAD`.
class ListTileNativeAdFactory: NSObject, FLTNativeAdFactory {
  func createNativeAd(
    _ nativeAd: NativeAd,
    customOptions: [AnyHashable: Any]? = nil
  ) -> NativeAdView? {
    let adView = NativeAdView()

    let headlineLabel = UILabel()
    headlineLabel.text = nativeAd.headline
    headlineLabel.font = UIFont.boldSystemFont(ofSize: 14)
    headlineLabel.textColor = UIColor.white
    adView.headlineView = headlineLabel

    let bodyLabel = UILabel()
    bodyLabel.text = nativeAd.body
    bodyLabel.font = UIFont.systemFont(ofSize: 12)
    // AppColors.textMuted (#B3A6DC)
    bodyLabel.textColor = UIColor(red: 0.70, green: 0.65, blue: 0.86, alpha: 1)
    bodyLabel.numberOfLines = 2
    bodyLabel.isHidden = nativeAd.body == nil
    adView.bodyView = bodyLabel

    // A MediaView is required — Google's ad servers can return video/image
    // creatives (its own test native ad unit always does), and the SDK
    // rejects the ad ("Click actions were not properly specified") unless
    // the view is both registered AND given the actual media content.
    let mediaView = MediaView()
    mediaView.mediaContent = nativeAd.mediaContent
    mediaView.contentMode = .scaleAspectFill
    mediaView.clipsToBounds = true
    adView.mediaView = mediaView

    let ctaButton = UIButton(type: .system)
    ctaButton.setTitle(nativeAd.callToAction, for: .normal)
    ctaButton.isUserInteractionEnabled = false
    // AppColors.primary (#FFC83C) on AppColors.edge (#130931)
    ctaButton.backgroundColor = UIColor(red: 1, green: 0.78, blue: 0.24, alpha: 1)
    ctaButton.setTitleColor(
      UIColor(red: 0.07, green: 0.04, blue: 0.19, alpha: 1), for: .normal)
    ctaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
    ctaButton.layer.cornerRadius = 6
    ctaButton.isHidden = nativeAd.callToAction == nil
    adView.callToActionView = ctaButton

    let textColumn = UIStackView(arrangedSubviews: [headlineLabel, bodyLabel])
    textColumn.axis = .vertical
    textColumn.spacing = 2

    let row = UIStackView(arrangedSubviews: [mediaView, textColumn, ctaButton])
    row.axis = .horizontal
    row.spacing = 12
    row.alignment = .center
    row.translatesAutoresizingMaskIntoConstraints = false

    mediaView.translatesAutoresizingMaskIntoConstraints = false
    mediaView.widthAnchor.constraint(equalToConstant: 56).isActive = true
    mediaView.heightAnchor.constraint(equalToConstant: 56).isActive = true

    // AppColors.surface (#241452)
    adView.backgroundColor = UIColor(red: 0.14, green: 0.08, blue: 0.32, alpha: 1)
    adView.addSubview(row)
    NSLayoutConstraint.activate([
      row.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
      row.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
      row.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
      row.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12),
    ])

    adView.nativeAd = nativeAd
    return adView
  }
}
