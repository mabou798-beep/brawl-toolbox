/// Platform facade for the App Open placement. See banner_ad_widget.dart for
/// why the conditional export is required.
library;

export 'app_open_ad_manager_noop.dart'
    if (dart.library.io) 'app_open_ad_manager_io.dart';
