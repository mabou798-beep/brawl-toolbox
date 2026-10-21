import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/live_event.dart';

class EventsApiException implements Exception {
  final String message;
  EventsApiException(this.message);
  @override
  String toString() => message;
}

/// The live rotation comes from Supercell's own API through our Cloudflare
/// Worker — BrawlAPI's `/events` endpoint returns an empty list, so this is
/// the only source that knows what is actually playable right now.
class EventsApiService {
  static const String baseUrl =
      'https://brawl-toolbox-api.terravisioncontractors.workers.dev';

  Future<List<LiveEvent>> fetchRotation() async {
    http.Response response;
    try {
      response = await http
          .get(Uri.parse('$baseUrl/events/rotation'))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw EventsApiException('No connection. Check your network and retry.');
    }

    if (response.statusCode != 200) {
      throw EventsApiException(
        'Could not load the rotation (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    final list = decoded is List
        ? decoded
        : (decoded as Map<String, dynamic>)['items'] as List<dynamic>? ??
              const [];

    final events = list
        .whereType<Map<String, dynamic>>()
        .map(LiveEvent.fromJson)
        .toList();

    // Running slots first, then the ones queued for later today.
    events.sort((a, b) {
      if (a.isLive != b.isLive) return a.isLive ? -1 : 1;
      final sa = a.startTime, sb = b.startTime;
      if (sa != null && sb != null) return sa.compareTo(sb);
      return a.slotId.compareTo(b.slotId);
    });
    return events;
  }
}
