/// Platform facade for the anchored banner ad.
///
/// `google_mobile_ads` has no web implementation at all, so importing it from
/// a web build fails at load time ("Library not defined") regardless of any
/// `kIsWeb` check inside the file. The conditional export below keeps the
/// package out of the web compilation entirely.
library;

export 'banner_ad_widget_noop.dart'
    if (dart.library.io) 'banner_ad_widget_io.dart';
