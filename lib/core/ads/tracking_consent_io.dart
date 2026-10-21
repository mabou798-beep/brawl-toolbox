import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

/// Shows Apple's tracking prompt once, the first time the app runs on iOS 14+.
///
/// Whatever the player answers is final as far as this app is concerned: iOS
/// only ever shows the dialog while the status is [TrackingStatus.notDetermined],
/// and asking again from here would do nothing. A refusal is not an error —
/// ads keep working, they are just not personalised.
Future<void> requestTrackingConsent() async {
  if (!Platform.isIOS) return;
  try {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status != TrackingStatus.notDetermined) return;
    await AppTrackingTransparency.requestTrackingAuthorization();
  } catch (_) {
    // Older iOS, or the plugin is unavailable: carry on without the prompt.
  }
}
