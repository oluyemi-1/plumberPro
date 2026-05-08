import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/customer_data.dart';

/// Singleton CRUD store for customers, persisted as JSON in
/// shared_preferences. Listeners are notified on every mutation.
class CustomerService extends ChangeNotifier {
  CustomerService._();
  static final CustomerService instance = CustomerService._();

  static const _kKey = 'customers_v1';

  final List<Customer> _customers = [];
  bool _loaded = false;

  List<Customer> get customers {
    final list = [..._customers];
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return List.unmodifiable(list);
  }

  bool get loaded => _loaded;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _customers.addAll(decodeCustomers(prefs.getString(_kKey)));
    _loaded = true;
    notifyListeners();
  }

  /// Re-read all state from disk after a restore.
  Future<void> reload() async {
    _customers.clear();
    _loaded = false;
    await ensureLoaded();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, encodeCustomers(_customers));
  }

  Customer? findById(String id) {
    for (final c in _customers) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Find an existing customer with the same name (case-insensitive). Useful
  /// for de-duplication when a user types a name that already exists.
  Customer? findByName(String name) {
    final n = name.trim().toLowerCase();
    if (n.isEmpty) return null;
    for (final c in _customers) {
      if (c.name.trim().toLowerCase() == n) return c;
    }
    return null;
  }

  Future<Customer> create({
    required String name,
    String address = '',
    String phone = '',
    String email = '',
    String notes = '',
  }) async {
    final existing = findByName(name);
    if (existing != null) return existing;
    final c = Customer.create(
      name: name,
      address: address,
      phone: phone,
      email: email,
      notes: notes,
    );
    _customers.add(c);
    await _save();
    notifyListeners();
    return c;
  }

  Future<void> update(Customer updated) async {
    final i = _customers.indexWhere((c) => c.id == updated.id);
    if (i == -1) return;
    _customers[i] = updated;
    await _save();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _customers.removeWhere((c) => c.id == id);
    await _save();
    notifyListeners();
  }
}
