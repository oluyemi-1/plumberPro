import 'dart:convert';
import 'dart:math' as math;

import 'schema_safe.dart';

/// A scheduled follow-up — typically an annual boiler service or landlord
/// gas safety renewal. Customer + address are snapshotted so the reminder
/// stays meaningful even if the customer record changes later.
class ServiceReminder {
  final String id;
  final String customerId; // links to Customer; '' for free-text
  final String customerName;
  final String address;
  final String description;
  final DateTime dueDate;
  final DateTime createdAt;
  final String? sourceJobId;
  final String? templateId;
  final bool completed;
  final DateTime? completedAt;

  const ServiceReminder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.address,
    required this.description,
    required this.dueDate,
    required this.createdAt,
    required this.sourceJobId,
    required this.templateId,
    required this.completed,
    required this.completedAt,
  });

  factory ServiceReminder.create({
    required String customerId,
    required String customerName,
    required String address,
    required String description,
    required DateTime dueDate,
    String? sourceJobId,
    String? templateId,
  }) =>
      ServiceReminder(
        id: _generateId(),
        customerId: customerId,
        customerName: customerName.trim(),
        address: address.trim(),
        description: description.trim(),
        dueDate: dueDate,
        createdAt: DateTime.now(),
        sourceJobId: sourceJobId,
        templateId: templateId,
        completed: false,
        completedAt: null,
      );

  /// Stable, positive int derived from [id] for the local-notification
  /// scheduler. Range is offset above the daily-reminder slot (1001).
  int get notificationId => 2000 + (id.hashCode & 0x7FFFFFF);

  bool isDueWithin(Duration window, {DateTime? now}) {
    if (completed) return false;
    final reference = now ?? DateTime.now();
    return dueDate.isBefore(reference.add(window));
  }

  bool isOverdue({DateTime? now}) {
    if (completed) return false;
    final reference = now ?? DateTime.now();
    return dueDate.isBefore(DateTime(reference.year, reference.month, reference.day));
  }

  ServiceReminder copyWith({
    String? customerId,
    String? customerName,
    String? address,
    String? description,
    DateTime? dueDate,
    String? sourceJobId,
    String? templateId,
    bool? completed,
    DateTime? completedAt,
    bool clearCompleted = false,
  }) =>
      ServiceReminder(
        id: id,
        customerId: customerId ?? this.customerId,
        customerName: customerName ?? this.customerName,
        address: address ?? this.address,
        description: description ?? this.description,
        dueDate: dueDate ?? this.dueDate,
        createdAt: createdAt,
        sourceJobId: sourceJobId ?? this.sourceJobId,
        templateId: templateId ?? this.templateId,
        completed: clearCompleted ? false : (completed ?? this.completed),
        completedAt: clearCompleted ? null : (completedAt ?? this.completedAt),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'customer': customerName,
        'address': address,
        'description': description,
        'due': dueDate.toIso8601String(),
        'created': createdAt.toIso8601String(),
        'sourceJob': sourceJobId,
        'template': templateId,
        'done': completed,
        'doneAt': completedAt?.toIso8601String(),
      };

  factory ServiceReminder.fromJson(Map<String, dynamic> j) => ServiceReminder(
        id: j['id'] as String,
        customerId: j['customerId'] as String? ?? '',
        customerName: j['customer'] as String? ?? '',
        address: j['address'] as String? ?? '',
        description: j['description'] as String? ?? '',
        dueDate: DateTime.tryParse(j['due'] as String? ?? '') ??
            DateTime.now().add(const Duration(days: 365)),
        createdAt: DateTime.tryParse(j['created'] as String? ?? '') ??
            DateTime.now(),
        sourceJobId: j['sourceJob'] as String?,
        templateId: j['template'] as String?,
        completed: j['done'] as bool? ?? false,
        completedAt: j['doneAt'] == null
            ? null
            : DateTime.tryParse(j['doneAt'] as String),
      );
}

String _generateId() {
  final ts = DateTime.now().millisecondsSinceEpoch;
  final r = math.Random().nextInt(1 << 32);
  return 'r-$ts-${r.toRadixString(36)}';
}

String encodeReminders(List<ServiceReminder> list) =>
    jsonEncode(list.map((r) => r.toJson()).toList());

List<ServiceReminder> decodeReminders(String? raw) =>
    SchemaSafe.decodeList<ServiceReminder>(
      key: 'reminders_v1',
      raw: raw,
      fromJson: ServiceReminder.fromJson,
    );
