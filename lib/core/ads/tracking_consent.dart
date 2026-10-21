/// App Tracking Transparency, behind the same conditional-export seam as the
/// ad units: the plugin is iOS-only and has no web implementation, so the
/// import itself has to be kept out of a web build.
library;

export 'tracking_consent_noop.dart'
    if (dart.library.io) 'tracking_consent_io.dart';
