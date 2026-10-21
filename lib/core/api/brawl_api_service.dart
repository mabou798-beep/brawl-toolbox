import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/brawler.dart';
import '../../models/map_info.dart';

/// Talks to BrawlAPI (https://brawlapi.com) — a free, CORS-enabled community
/// wrapper around Supercell's game data. Supercell's official API requires a
/// server-side key locked to a single IP address, so it cannot be called
/// directly from a browser; this service is the practical substitute for a
/// client-only (web/mobile) app.
class BrawlApiService {
  static const String _baseUrl = 'https://api.brawlapi.com/v1';

  Future<List<Brawler>> fetchBrawlers() async {
    final response = await http.get(Uri.parse('$_baseUrl/brawlers'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load brawlers (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = body['list'] as List<dynamic>? ?? [];
    return list
        .map((e) => Brawler.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MapInfo>> fetchMaps() async {
    final response = await http.get(Uri.parse('$_baseUrl/maps'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load maps (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = body['list'] as List<dynamic>? ?? [];
    return list
        .map((e) => MapInfo.fromJson(e as Map<String, dynamic>))
        .where((m) => m.imageUrl.isNotEmpty)
        .toList();
  }

  Future<Map<String, List<MapInfo>>> fetchActiveEvents() async {
    final response = await http.get(Uri.parse('$_baseUrl/events'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load events (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    List<MapInfo> parse(String key) {
      final list = body[key] as List<dynamic>? ?? [];
      return list
          .map((e) {
            final map = e['map'] as Map<String, dynamic>?;
            return map != null ? MapInfo.fromJson(map) : null;
          })
          .whereType<MapInfo>()
          .toList();
    }

    return {'active': parse('active'), 'upcoming': parse('upcoming')};
  }
}
