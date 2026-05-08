import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/job_template_data.dart';

/// Singleton CRUD store for job templates. On first launch the list is
/// seeded with `defaultBuiltInTemplates()`. Users can then customise or add
/// their own.
class JobTemplateService extends ChangeNotifier {
  JobTemplateService._();
  static final JobTemplateService instance = JobTemplateService._();

  static const _kKey = 'job_templates_v1';
  static const _kSeeded = 'job_templates_seeded_v1';

  final List<JobTemplate> _templates = [];
  bool _loaded = false;

  List<JobTemplate> get templates => List.unmodifiable(_templates);
  bool get loaded => _loaded;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = decodeTemplates(prefs.getString(_kKey));
    final seeded = prefs.getBool(_kSeeded) ?? false;
    if (stored.isEmpty && !seeded) {
      _templates.addAll(defaultBuiltInTemplates());
      await prefs.setString(_kKey, encodeTemplates(_templates));
      await prefs.setBool(_kSeeded, true);
    } else {
      _templates.addAll(stored);
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, encodeTemplates(_templates));
  }

  JobTemplate? findById(String id) {
    for (final t in _templates) {
      if (t.id == id) return t;
    }
    return null;
  }

  Future<JobTemplate> create(JobTemplate template) async {
    _templates.add(template);
    await _save();
    notifyListeners();
    return template;
  }

  Future<void> update(JobTemplate updated) async {
    final i = _templates.indexWhere((t) => t.id == updated.id);
    if (i == -1) return;
    _templates[i] = updated;
    await _save();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _templates.removeWhere((t) => t.id == id);
    await _save();
    notifyListeners();
  }

  /// Restore the built-in templates (handy after a user has deleted some
  /// and wants them back).
  Future<void> restoreBuiltIns() async {
    final defaults = defaultBuiltInTemplates();
    final existingIds = _templates.map((t) => t.id).toSet();
    for (final d in defaults) {
      if (!existingIds.contains(d.id)) _templates.add(d);
    }
    await _save();
    notifyListeners();
  }

  /// Re-read all state from disk after a restore.
  Future<void> reload() async {
    _templates.clear();
    _loaded = false;
    await ensureLoaded();
  }
}
