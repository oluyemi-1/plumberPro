import 'dart:convert';
import 'dart:math' as math;

import 'schema_safe.dart';

class Customer {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String notes;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.notes,
    required this.createdAt,
  });

  factory Customer.create({
    required String name,
    String address = '',
    String phone = '',
    String email = '',
    String notes = '',
  }) =>
      Customer(
        id: _generateId(),
        name: name.trim(),
        address: address.trim(),
        phone: phone.trim(),
        email: email.trim(),
        notes: notes.trim(),
        createdAt: DateTime.now(),
      );

  Customer copyWith({
    String? name,
    String? address,
    String? phone,
    String? email,
    String? notes,
  }) =>
      Customer(
        id: id,
        name: name ?? this.name,
        address: address ?? this.address,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        address: j['address'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        email: j['email'] as String? ?? '',
        notes: j['notes'] as String? ?? '',
        createdAt: DateTime.parse(j['createdAt'] as String),
      );

  /// First letter for alphabetical grouping. Falls back to '#' for empty
  /// names or non-letter starts.
  String get firstLetter {
    if (name.isEmpty) return '#';
    final c = name.trim().substring(0, 1).toUpperCase();
    final code = c.codeUnitAt(0);
    if (code < 65 || code > 90) return '#';
    return c;
  }
}

String _generateId() {
  final ts = DateTime.now().millisecondsSinceEpoch;
  final r = math.Random().nextInt(1 << 32);
  return 'c-$ts-${r.toRadixString(36)}';
}

String encodeCustomers(List<Customer> list) =>
    jsonEncode(list.map((c) => c.toJson()).toList());

List<Customer> decodeCustomers(String? raw) =>
    SchemaSafe.decodeList<Customer>(
      key: 'customers_v1',
      raw: raw,
      fromJson: Customer.fromJson,
    );
