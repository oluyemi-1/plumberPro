import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/user_role_data.dart';

/// Stores the user's chosen role and goals across launches.
class UserProfileService extends ChangeNotifier {
  UserProfileService._();
  static final UserProfileService instance = UserProfileService._();

  static const _kOnboarded = 'profile_onboarded';
  static const _kRole = 'profile_role';
  static const _kGoals = 'profile_goals';
  static const _kDisplayName = 'profile_name';

  UserRole? _role;
  Set<String> _goals = const {};
  String _displayName = '';
  bool _onboarded = false;
  bool _loaded = false;

  UserRole? get role => _role;
  Set<String> get goals => _goals;
  String get displayName => _displayName;
  bool get onboarded => _onboarded;
  bool get loaded => _loaded;

  UserRoleInfo? get roleInfo =>
      _role == null ? null : userRoleInfo[_role];

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _onboarded = prefs.getBool(_kOnboarded) ?? false;
    final roleId = prefs.getString(_kRole);
    if (roleId != null) {
      _role = UserRole.values.firstWhere(
        (r) => r.name == roleId,
        orElse: () => UserRole.domestic,
      );
    }
    _goals = (prefs.getStringList(_kGoals) ?? const []).toSet();
    _displayName = prefs.getString(_kDisplayName) ?? '';
    _loaded = true;
    notifyListeners();
  }

  Future<void> saveRole(UserRole role) async {
    _role = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRole, role.name);
    notifyListeners();
  }

  Future<void> saveGoals(Set<String> goals) async {
    _goals = goals;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kGoals, goals.toList());
    notifyListeners();
  }

  Future<void> saveDisplayName(String name) async {
    _displayName = name.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDisplayName, _displayName);
    notifyListeners();
  }

  Future<void> markOnboarded() async {
    _onboarded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarded, true);
    notifyListeners();
  }

  /// Re-read all values from disk and notify listeners. Used after a
  /// backup restore to refresh in-memory state.
  Future<void> reload() async {
    _loaded = false;
    _role = null;
    _goals = const {};
    _displayName = '';
    _onboarded = false;
    await ensureLoaded();
  }

  Future<void> resetOnboarding() async {
    _onboarded = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarded, false);
    notifyListeners();
  }
}
