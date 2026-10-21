import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/api/events_api_service.dart';
import '../models/live_event.dart';
import 'brawlers_provider.dart';

/// Holds the official event rotation and keeps its countdowns honest: a
/// one-minute tick refreshes the "2h 14m" labels, and when a slot actually
/// expires the rotation is refetched instead of showing a stale map.
class EventsProvider extends ChangeNotifier {
  final EventsApiService _api;
  Timer? _ticker;

  EventsProvider(this._api);

  LoadStatus status = LoadStatus.idle;
  String? errorMessage;
  List<LiveEvent> events = [];

  List<LiveEvent> get live => events.where((e) => e.isLive).toList();
  List<LiveEvent> get upcoming => events.where((e) => !e.isLive).toList();

  Future<void> load() async {
    if (status == LoadStatus.loading) return;
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      events = await _api.fetchRotation();
      status = LoadStatus.loaded;
      _startTicker();
    } catch (e) {
      errorMessage = e.toString();
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      final expired = events.any(
        (e) => e.isLive && (e.remaining ?? Duration.zero) <= Duration.zero,
      );
      if (expired) {
        status = LoadStatus.idle;
        load();
      } else {
        notifyListeners(); // redraw the countdown badges
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
