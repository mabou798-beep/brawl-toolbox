import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/player_api_service.dart';
import '../models/player.dart';
import 'brawlers_provider.dart';

/// Holds the signed-in player tag and everything fetched for it. The tag is
/// kept on the device so the stats tab opens straight to the profile.
class PlayerProvider extends ChangeNotifier {
  static const _tagKey = 'player_tag';

  final PlayerApiService _api;

  PlayerProvider(this._api);

  LoadStatus status = LoadStatus.idle;
  String? errorMessage;
  String? tag;
  PlayerProfile? profile;
  List<Battle> battles = [];

  bool get hasTag => tag != null && tag!.isNotEmpty;

  Future<void> restore() async {
    String? saved;
    try {
      final prefs = await SharedPreferences.getInstance();
      saved = prefs.getString(_tagKey);
    } catch (_) {
      // No device storage (it is unavailable on some web builds). The tab
      // still works, the player just types the tag again.
      return;
    }
    if (saved == null || saved.isEmpty) return;
    tag = saved;
    await refresh();
  }

  Future<void> lookup(String input) async {
    final cleaned = input.trim().toUpperCase().replaceAll('#', '');
    if (cleaned.length < 3) {
      errorMessage = 'That tag looks too short.';
      status = LoadStatus.error;
      notifyListeners();
      return;
    }
    tag = cleaned;
    await refresh(persistOnSuccess: true);
  }

  Future<void> refresh({bool persistOnSuccess = false}) async {
    if (!hasTag) return;
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.fetchPlayer(tag!),
        _api.fetchBattlelog(tag!),
      ]);
      profile = results[0] as PlayerProfile;
      battles = results[1] as List<Battle>;
      status = LoadStatus.loaded;
      if (persistOnSuccess) await _remember(tag!);
    } on PlayerApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    } catch (_) {
      errorMessage = 'Something went wrong. Try again.';
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Saving the tag is a convenience, never a reason to tell the player their
  /// lookup failed — the profile on screen is already loaded and correct.
  Future<void> _remember(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tagKey, value);
    } catch (_) {
      // Storage unavailable; nothing the player can act on.
    }
  }

  Future<void> forget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tagKey);
    } catch (_) {
      // Nothing was stored, so nothing to clear.
    }
    tag = null;
    profile = null;
    battles = [];
    errorMessage = null;
    status = LoadStatus.idle;
    notifyListeners();
  }
}
