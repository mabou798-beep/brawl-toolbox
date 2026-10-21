import 'package:flutter/foundation.dart';
import '../core/api/brawl_api_service.dart';
import '../models/brawler.dart';

enum LoadStatus { idle, loading, loaded, error }

class BrawlersProvider extends ChangeNotifier {
  final BrawlApiService _api;

  BrawlersProvider(this._api);

  LoadStatus status = LoadStatus.idle;
  String? errorMessage;
  List<Brawler> brawlers = [];

  Future<void> load() async {
    if (status == LoadStatus.loading) return;
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _api.fetchBrawlers();
      result.sort((a, b) => a.name.compareTo(b.name));
      brawlers = result;
      status = LoadStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// The full-body model render for every brawler — the highest-resolution
  /// official art available, one per brawler (100+ once the roster loads).
  List<String> get wallpaperUrls => brawlers.map((b) => b.wallpaperUrl).toList();
}
