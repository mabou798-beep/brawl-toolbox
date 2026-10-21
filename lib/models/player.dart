/// Models for the official Supercell data, reached through our Cloudflare
/// Worker. Only the fields the app actually shows are parsed.
class PlayerProfile {
  final String tag;
  final String name;
  final String? clubName;
  final int trophies;
  final int highestTrophies;
  final int wins3v3;
  final int soloWins;
  final int duoWins;
  final int expLevel;
  final String? rankedRankName;
  final int? rankedElo;
  final List<PlayerBrawler> brawlers;

  PlayerProfile({
    required this.tag,
    required this.name,
    required this.clubName,
    required this.trophies,
    required this.highestTrophies,
    required this.wins3v3,
    required this.soloWins,
    required this.duoWins,
    required this.expLevel,
    required this.rankedRankName,
    required this.rankedElo,
    required this.brawlers,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final club = json['club'] as Map<String, dynamic>?;
    final clubName = (club?['name'] as String?)?.trim();

    return PlayerProfile(
      tag: json['tag'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      clubName: (clubName == null || clubName.isEmpty) ? null : clubName,
      trophies: json['trophies'] as int? ?? 0,
      highestTrophies: json['highestTrophies'] as int? ?? 0,
      wins3v3: json['3vs3Victories'] as int? ?? 0,
      soloWins: json['soloVictories'] as int? ?? 0,
      duoWins: json['duoVictories'] as int? ?? 0,
      expLevel: json['expLevel'] as int? ?? 0,
      rankedRankName: json['rankedRankName'] as String?,
      rankedElo: json['rankedElo'] as int?,
      brawlers: (json['brawlers'] as List<dynamic>? ?? [])
          .map((e) => PlayerBrawler.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PlayerBrawler {
  final int id;
  final String name;
  final int power;
  final int rank;
  final int trophies;
  final int highestTrophies;
  final int currentWinStreak;
  final int maxWinStreak;

  PlayerBrawler({
    required this.id,
    required this.name,
    required this.power,
    required this.rank,
    required this.trophies,
    required this.highestTrophies,
    required this.currentWinStreak,
    required this.maxWinStreak,
  });

  factory PlayerBrawler.fromJson(Map<String, dynamic> json) {
    return PlayerBrawler(
      id: json['id'] as int? ?? 0,
      // The API shouts brawler names ("SHELLY"); title case reads better.
      name: _titleCase(json['name'] as String? ?? ''),
      power: json['power'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      trophies: json['trophies'] as int? ?? 0,
      highestTrophies: json['highestTrophies'] as int? ?? 0,
      currentWinStreak: json['currentWinStreak'] as int? ?? 0,
      maxWinStreak: json['maxWinStreak'] as int? ?? 0,
    );
  }

  String get portraitUrl =>
      'https://cdn.brawlify.com/brawlers/borderless/$id.png';

  static String _titleCase(String raw) {
    return raw
        .toLowerCase()
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class Battle {
  final DateTime? time;
  final String mode;
  final String map;
  final String type;
  final String result;
  final int trophyChange;

  Battle({
    required this.time,
    required this.mode,
    required this.map,
    required this.type,
    required this.result,
    required this.trophyChange,
  });

  factory Battle.fromJson(Map<String, dynamic> json) {
    final event = json['event'] as Map<String, dynamic>?;
    final battle = json['battle'] as Map<String, dynamic>?;

    // Showdown reports a placement instead of a win/loss.
    final rank = battle?['rank'] as int?;
    final result = battle?['result'] as String? ??
        (rank != null ? 'rank $rank' : 'unknown');

    return Battle(
      time: _parseTime(json['battleTime'] as String?),
      mode: prettify(event?['mode'] as String? ?? battle?['mode'] as String? ?? ''),
      map: event?['map'] as String? ?? 'Unknown map',
      type: battle?['type'] as String? ?? '',
      result: result,
      trophyChange: battle?['trophyChange'] as int? ?? 0,
    );
  }

  bool get isWin => result == 'victory';
  bool get isLoss => result == 'defeat';

  /// "20261020T125833.000Z" is not ISO-8601, so it is rebuilt by hand.
  static DateTime? _parseTime(String? raw) {
    if (raw == null || raw.length < 15) return null;
    try {
      final iso = '${raw.substring(0, 4)}-${raw.substring(4, 6)}-'
          '${raw.substring(6, 8)}T${raw.substring(9, 11)}:'
          '${raw.substring(11, 13)}:${raw.substring(13, 15)}Z';
      return DateTime.parse(iso).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// "brawlBall5V5" -> "Brawl Ball 5V5"
  static String prettify(String raw) {
    if (raw.isEmpty) return raw;
    final spaced = raw.replaceAllMapped(
      RegExp(r'(?<=[a-z])(?=[A-Z0-9])'),
      (_) => ' ',
    );
    return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
  }
}
