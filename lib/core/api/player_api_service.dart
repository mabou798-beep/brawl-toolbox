import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/player.dart';

/// Thrown with a message the UI can show as-is.
class PlayerApiException implements Exception {
  final String message;
  PlayerApiException(this.message);
  @override
  String toString() => message;
}

/// Talks to our Cloudflare Worker, which holds the Supercell key and forwards
/// to the official API. The key is never in the app.
class PlayerApiService {
  static const String baseUrl =
      'https://brawl-toolbox-api.terravisioncontractors.workers.dev';

  /// "#2pp0gl9", "2PP0GL9" and " #2PP0GL9 " all become "%232PP0GL9".
  static String normalizeTag(String input) {
    final cleaned = input.trim().toUpperCase().replaceAll('#', '');
    return '%23$cleaned';
  }

  static String displayTag(String input) =>
      '#${input.trim().toUpperCase().replaceAll('#', '')}';

  Future<PlayerProfile> fetchPlayer(String tag) async {
    final body = await _get('/players/${normalizeTag(tag)}');
    return PlayerProfile.fromJson(body as Map<String, dynamic>);
  }

  Future<List<Battle>> fetchBattlelog(String tag) async {
    final body = await _get('/players/${normalizeTag(tag)}/battlelog');
    final items = (body as Map<String, dynamic>)['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => Battle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<dynamic> _get(String path) async {
    http.Response response;
    try {
      response = await http
          .get(Uri.parse('$baseUrl$path'))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw PlayerApiException('No connection. Check your network and retry.');
    }

    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body);
      case 404:
        throw PlayerApiException(
          'No player with that tag. Check it in the game, under your name.',
        );
      case 429:
        throw PlayerApiException('Too many lookups right now. Try again in a minute.');
      case 503:
        throw PlayerApiException('Brawl Stars is in maintenance. Try again later.');
      default:
        throw PlayerApiException('Lookup failed (${response.statusCode}).');
    }
  }
}
