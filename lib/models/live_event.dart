import 'player.dart' show Battle;

/// One slot of the official event rotation, as reported by Supercell's
/// `/events/rotation`. This is the only part of the app that knows what is
/// playable *right now* — everything else (maps, brawlers) is a catalogue.
class LiveEvent {
  final int slotId;
  final DateTime? startTime;
  final DateTime? endTime;

  /// Raw mode key, e.g. `gemGrab`. Kept for matching against other sources.
  final String modeKey;

  /// Display form of [modeKey], e.g. `Gem Grab`.
  final String modeLabel;

  final String mapName;
  final List<String> modifiers;

  LiveEvent({
    required this.slotId,
    required this.startTime,
    required this.endTime,
    required this.modeKey,
    required this.modeLabel,
    required this.mapName,
    required this.modifiers,
  });

  factory LiveEvent.fromJson(Map<String, dynamic> json) {
    final event = json['event'] as Map<String, dynamic>? ?? const {};
    final mode = event['mode'] as String? ?? '';

    return LiveEvent(
      slotId: json['slotId'] as int? ?? 0,
      startTime: parseBrawlTime(json['startTime'] as String?),
      endTime: parseBrawlTime(json['endTime'] as String?),
      modeKey: mode,
      modeLabel: mode.isEmpty ? 'Event' : Battle.prettify(mode),
      mapName: event['map'] as String? ?? 'Unknown map',
      modifiers: ((event['modifiers'] as List<dynamic>?) ?? const [])
          .map((e) => Battle.prettify(e.toString()))
          .where((e) => e.isNotEmpty && e.toLowerCase() != 'none')
          .toList(),
    );
  }

  /// Already running — the API also returns slots that start later today.
  bool get isLive {
    final start = startTime;
    if (start == null) return true;
    return !start.isAfter(DateTime.now());
  }

  Duration? get remaining {
    final end = endTime;
    if (end == null) return null;
    final left = end.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  /// "2h 14m", "41m", "Ending" — short enough for a badge.
  String? get remainingLabel {
    final left = remaining;
    if (left == null) return null;
    if (left.inMinutes < 1) return 'Ending';
    if (left.inHours < 1) return '${left.inMinutes}m';
    if (left.inHours < 24) return '${left.inHours}h ${left.inMinutes % 60}m';
    return '${left.inDays}d ${left.inHours % 24}h';
  }

  /// "Starts in 3h" for a slot that has not opened yet.
  String? get startsInLabel {
    final start = startTime;
    if (start == null || !start.isAfter(DateTime.now())) return null;
    final until = start.difference(DateTime.now());
    if (until.inHours < 1) return 'Starts in ${until.inMinutes}m';
    if (until.inHours < 24) return 'Starts in ${until.inHours}h';
    return 'Starts in ${until.inDays}d';
  }
}

/// `20261020T110000.000Z` is not ISO-8601, so it is rebuilt by hand.
DateTime? parseBrawlTime(String? raw) {
  if (raw == null || raw.length < 15) return null;
  try {
    final iso =
        '${raw.substring(0, 4)}-${raw.substring(4, 6)}-'
        '${raw.substring(6, 8)}T${raw.substring(9, 11)}:'
        '${raw.substring(11, 13)}:${raw.substring(13, 15)}Z';
    return DateTime.parse(iso).toLocal();
  } catch (_) {
    return null;
  }
}
