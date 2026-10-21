/// Platform facade for interstitials. See banner_ad_widget.dart for why the
/// conditional export is required.
library;

export 'interstitial_ad_manager_noop.dart'
    if (dart.library.io) 'interstitial_ad_manager_io.dart';
