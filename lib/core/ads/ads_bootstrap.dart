/// Platform facade for ad SDK start-up. See banner_ad_widget.dart for why the
/// conditional export is required.
library;

export 'ads_bootstrap_noop.dart'
    if (dart.library.io) 'ads_bootstrap_io.dart';
