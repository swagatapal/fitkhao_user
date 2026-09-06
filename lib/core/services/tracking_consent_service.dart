import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/widgets.dart';

/// Bridges iOS App Tracking Transparency to the Meta SDK's advertiser-tracking
/// flag.
///
/// Meta attribution needs the IDFA, and iOS only hands it over once the user has
/// accepted the ATT prompt. Previously the app enabled advertiser tracking
/// unconditionally and never prompted, so the IDFA was always zeroed and the
/// `NSUserTrackingUsageDescription` string was never used — which is what App
/// Store Connect flagged.
///
/// Every method is fire-and-forget and never throws: consent plumbing must not
/// be able to stop the app from starting.
class TrackingConsentService {
  TrackingConsentService._();

  static final TrackingConsentService instance = TrackingConsentService._();

  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  bool _initialised = false;

  /// Whether the user allowed tracking. False on Android, where ATT has no
  /// equivalent and the advertising ID is governed by system settings instead.
  bool get isTrackingAuthorized => _isTrackingAuthorized;
  bool _isTrackingAuthorized = false;

  /// Resolve tracking consent and tell the Meta SDK what it may do.
  ///
  /// Must be called with the app already foregrounded and a frame on screen —
  /// iOS silently declines to show the ATT prompt otherwise. Safe to call more
  /// than once; only the first call prompts.
  Future<void> initialise() async {
    if (_initialised) return;
    _initialised = true;

    try {
      if (!Platform.isIOS) {
        // Android has no ATT gate; Meta may use the advertising ID directly.
        await _facebookAppEvents.setAdvertiserTracking(enabled: true);
        _isTrackingAuthorized = true;
        return;
      }

      var status = await AppTrackingTransparency.trackingAuthorizationStatus;

      // Only the first launch reaches notDetermined. Afterwards the answer is
      // fixed and can be changed only in iOS Settings.
      if (status == TrackingStatus.notDetermined) {
        // iOS returns `denied` *without showing the prompt* if the app is not
        // yet active, and that denial sticks until the user changes it in
        // Settings. Two ordinary situations hit this: a cold launch into the
        // background, and the notification permission dialog that main() puts
        // up first — a system alert leaves us `inactive`, not `resumed`.
        // So wait for the app to actually settle rather than asking blind.
        await _waitUntilResumed();
        status = await AppTrackingTransparency.requestTrackingAuthorization();
      }

      _isTrackingAuthorized = status == TrackingStatus.authorized;

      // Mirror the user's actual choice. Enabling this without consent would
      // claim a permission we do not have.
      await _facebookAppEvents.setAdvertiserTracking(
        enabled: _isTrackingAuthorized,
      );

      debugPrint('[TrackingConsent] ATT status: $status');
    } catch (e) {
      // Never let consent plumbing break startup.
      debugPrint('[TrackingConsent] Failed to resolve tracking consent: $e');
    }
  }

  /// Completes once the app is in the resumed state.
  ///
  /// Returns immediately if it already is. Otherwise it listens for the
  /// transition rather than polling against a deadline — the user may leave a
  /// system alert on screen for an arbitrarily long time, and giving up would
  /// cost us the ATT prompt for the whole session.
  Future<void> _waitUntilResumed() async {
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      return;
    }
    final completer = Completer<void>();
    late final AppLifecycleListener listener;
    listener = AppLifecycleListener(
      onStateChange: (state) {
        if (state == AppLifecycleState.resumed && !completer.isCompleted) {
          completer.complete();
        }
      },
    );
    try {
      await completer.future;
    } finally {
      listener.dispose();
    }
  }
}
