import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists a flat set of bookmark identifiers across launches.
///
/// IDs are opaque strings of the form `<type>:<localId>` — see
/// [content_index.dart] for the canonical IDs.
class BookmarksService extends ChangeNotifier {
  BookmarksService._();
  static final BookmarksService instance = BookmarksService._();

  static const _kBookmarks = 'bookmarks_v1';

  final Set<String> _ids = <String>{};
  bool _loaded = false;

  Set<String> get ids => Set.unmodifiable(_ids);
  bool get loaded => _loaded;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _ids.addAll(prefs.getStringList(_kBookmarks) ?? const []);
    _loaded = true;
    notifyListeners();
  }

  bool contains(String id) => _ids.contains(id);

  Future<void> toggle(String id) async {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kBookmarks, _ids.toList());
    notifyListeners();
  }

  /// Re-read all state from disk after a restore.
  Future<void> reload() async {
    _ids.clear();
    _loaded = false;
    await ensureLoaded();
  }

  Future<void> clearAll() async {
    _ids.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kBookmarks);
    notifyListeners();
  }
}
