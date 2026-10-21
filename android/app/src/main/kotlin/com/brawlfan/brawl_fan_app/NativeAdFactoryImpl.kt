package com.brawlfan.brawl_fan_app

import android.content.Context
import android.view.LayoutInflater
import android.widget.Button
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.NativeAdFactory

/**
 * Renders native ads using list_tile_native_ad.xml so they can sit inline
 * inside the News feed list. Registered under factory id
 * "listTileNativeAd" — must match NativeAdTile._factoryId in
 * lib/core/ads/native_ad_tile.dart.
 */
class NativeAdFactoryImpl(private val context: Context) : NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?,
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.list_tile_native_ad, null) as NativeAdView

        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        val mediaView = adView.findViewById<MediaView>(R.id.ad_media)
        val ctaView = adView.findViewById<Button>(R.id.ad_call_to_action)

        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        if (nativeAd.body != null) {
            bodyView.text = nativeAd.body
            bodyView.visibility = android.view.View.VISIBLE
        } else {
            bodyView.visibility = android.view.View.GONE
        }
        adView.bodyView = bodyView

        // MediaView is required — Google's ad servers can return video/image
        // creatives (its own test native ad unit always does), and the SDK
        // rejects the ad ("Click actions were not properly specified") unless
        // the view is both registered AND given the actual media content.
        mediaView.setImageScaleType(android.widget.ImageView.ScaleType.CENTER_CROP)
        mediaView.mediaContent = nativeAd.mediaContent
        adView.mediaView = mediaView

        if (nativeAd.callToAction != null) {
            ctaView.text = nativeAd.callToAction
            ctaView.visibility = android.view.View.VISIBLE
        } else {
            ctaView.visibility = android.view.View.GONE
        }
        adView.callToActionView = ctaView

        adView.setNativeAd(nativeAd)
        return adView
    }
}
