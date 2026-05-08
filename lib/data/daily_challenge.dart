import 'content_index.dart';

/// Returns today's "fault-of-the-day" — a single content item picked
/// deterministically from a curated subset of the content index based on
/// today's date, so every device shows the same challenge on the same day
/// and a different challenge each day.
SearchEntry? todaysChallenge(List<SearchEntry> all, {DateTime? now}) {
  final pool = _challengePool(all);
  if (pool.isEmpty) return null;
  final today = now ?? DateTime.now();
  // Deterministic seed: days since 1 Jan 2026.
  final epoch = DateTime(2026, 1, 1);
  final daysSince = today.difference(epoch).inDays.abs();
  final pick = daysSince % pool.length;
  return pool[pick];
}

/// Items considered "challenge-worthy" — fault-finding scenarios, common
/// faults from the troubleshooter, fault-code style sims and a sprinkling of
/// safety topics that warrant frequent revisiting.
List<SearchEntry> _challengePool(List<SearchEntry> all) {
  bool isChallenge(SearchEntry e) {
    if (e.type == 'Scenario') return true;
    if (e.type == 'Troubleshooter') return true;
    final lt = e.title.toLowerCase();
    if (e.type == 'Simulation') {
      return lt.contains('fault') ||
          lt.contains('diagnos') ||
          lt.contains('blocked') ||
          lt.contains('leak') ||
          lt.contains('frozen') ||
          lt.contains('kettling') ||
          lt.contains('hammer') ||
          lt.contains('safe isolation') ||
          lt.contains('bleed');
    }
    return false;
  }

  return all.where(isChallenge).toList();
}
