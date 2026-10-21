import 'package:flutter/foundation.dart';
import '../core/api/brawl_api_service.dart';
import '../models/map_info.dart';
import 'brawlers_provider.dart';

class MapsProvider extends ChangeNotifier {
  final BrawlApiService _api;

  MapsProvider(this._api);

  LoadStatus status = LoadStatus.idle;
  String? errorMessage;
  List<MapInfo> maps = [];
  List<MapInfo> activeEvents = [];

  Future<void> load() async {
    if (status == LoadStatus.loading) return;
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([_api.fetchMaps(), _api.fetchActiveEvents()]);
      maps = results[0] as List<MapInfo>;
      final events = results[1] as Map<String, List<MapInfo>>;
      activeEvents = events['active'] ?? [];
      status = LoadStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  List<String> get gameModes {
    final modes = maps.map((m) => m.gameModeName).toSet().toList();
    modes.sort();
    return modes;
  }
}
