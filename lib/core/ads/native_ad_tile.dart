/// Platform facade for the in-feed native ad tile. See banner_ad_widget.dart
/// for why the conditional export is required.
library;

export 'native_ad_tile_noop.dart'
    if (dart.library.io) 'native_ad_tile_io.dart';
