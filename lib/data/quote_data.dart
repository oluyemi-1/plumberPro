import 'dart:convert';
import 'dart:math' as math;

import 'schema_safe.dart';

/// One predicted line on a quote — description, quantity, unit price. Becomes
/// a real `MaterialLine` when the quote is converted to an active job.
class QuoteLineItem {
  final String id;
  final String description;
  final double quantity;
  final double unitPriceGbp;

  const QuoteLineItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPriceGbp,
  });

  double get totalGbp => quantity * unitPriceGbp;

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPriceGbp,
      };

  factory QuoteLineItem.fromJson(Map<String, dynamic> j) => QuoteLineItem(
        id: j['id'] as String,
        description: j['description'] as String? ?? '',
        quantity: (j['quantity'] as num?)?.toDouble() ?? 1,
        unitPriceGbp: (j['unitPrice'] as num?)?.toDouble() ?? 0,
      );
}

enum QuoteStatus { draft, sent, accepted, rejected }

QuoteStatus _decodeStatus(String? raw) {
  for (final s in QuoteStatus.values) {
    if (s.name == raw) return s;
  }
  return QuoteStatus.draft;
}

extension QuoteStatusX on QuoteStatus {
  String get label {
    switch (this) {
      case QuoteStatus.draft:
        return 'Draft';
      case QuoteStatus.sent:
        return 'Sent';
      case QuoteStatus.accepted:
        return 'Accepted';
      case QuoteStatus.rejected:
        return 'Rejected';
    }
  }

  /// True for statuses that still represent open business — i.e. the quote
  /// hasn't been turned into a job or written off yet.
  bool get isOpen =>
      this == QuoteStatus.draft || this == QuoteStatus.sent;
}

/// A pre-job estimate. Distinct from `Job`: a quote tracks *predicted* hours
/// and materials before any work is done; a job tracks *actual* time on the
/// clock and materials used. When accepted, a quote spawns a fresh `Job`
/// pre-filled with the quote's contents — see `QuoteService.convertToJob`.
class Quote {
  final String id;
  final String quoteRef; // user-visible reference, e.g. "Q-2026-051"
  final String customer;
  final String customerId;
  final String address;
  final String description;
  final double estimatedHours;
  final double hourlyRateGbp;
  final List<QuoteLineItem> lines;
  final String notes;

  /// How long the quote price stays valid from `createdAt`. Null = no
  /// expiry shown on the PDF. Default is 30 days.
  final int? validForDays;

  final QuoteStatus status;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? respondedAt;

  /// When the quote has been turned into a real Job, this links to that
  /// Job's id so the user can jump from quote → job and the dashboard
  /// doesn't double-count revenue.
  final String? convertedJobId;

  const Quote({
    required this.id,
    required this.quoteRef,
    required this.customer,
    required this.customerId,
    required this.address,
    required this.description,
    required this.estimatedHours,
    required this.hourlyRateGbp,
    required this.lines,
    required this.notes,
    required this.validForDays,
    required this.status,
    required this.createdAt,
    required this.sentAt,
    required this.respondedAt,
    required this.convertedJobId,
  });

  factory Quote.create({
    required String customer,
    String customerId = '',
    String address = '',
    String description = '',
    double estimatedHours = 0,
    required double hourlyRateGbp,
    List<QuoteLineItem> lines = const [],
    String notes = '',
    int? validForDays = 30,
  }) {
    final now = DateTime.now();
    return Quote(
      id: _generateId(),
      quoteRef: _generateRef(now),
      customer: customer.trim(),
      customerId: customerId,
      address: address.trim(),
      description: description.trim(),
      estimatedHours: estimatedHours,
      hourlyRateGbp: hourlyRateGbp,
      lines: lines,
      notes: notes,
      validForDays: validForDays,
      status: QuoteStatus.draft,
      createdAt: now,
      sentAt: null,
      respondedAt: null,
      convertedJobId: null,
    );
  }

  double get labourCost => estimatedHours * hourlyRateGbp;
  double get materialsCost => lines.fold(0.0, (a, l) => a + l.totalGbp);
  double get subtotalGbp => labourCost + materialsCost;

  /// Date the quoted price expires (createdAt + validForDays), or null if
  /// the user opted out of an expiry.
  DateTime? get expiresAt => validForDays == null
      ? null
      : createdAt.add(Duration(days: validForDays!));

  bool isExpired({DateTime? now}) {
    final exp = expiresAt;
    if (exp == null) return false;
    return (now ?? DateTime.now()).isAfter(exp);
  }

  Quote copyWith({
    String? quoteRef,
    String? customer,
    String? customerId,
    String? address,
    String? description,
    double? estimatedHours,
    double? hourlyRateGbp,
    List<QuoteLineItem>? lines,
    String? notes,
    int? validForDays,
    bool clearValidFor = false,
    QuoteStatus? status,
    DateTime? sentAt,
    DateTime? respondedAt,
    String? convertedJobId,
    bool clearSentAt = false,
    bool clearRespondedAt = false,
    bool clearConvertedJobId = false,
  }) =>
      Quote(
        id: id,
        quoteRef: quoteRef ?? this.quoteRef,
        customer: customer ?? this.customer,
        customerId: customerId ?? this.customerId,
        address: address ?? this.address,
        description: description ?? this.description,
        estimatedHours: estimatedHours ?? this.estimatedHours,
        hourlyRateGbp: hourlyRateGbp ?? this.hourlyRateGbp,
        lines: lines ?? this.lines,
        notes: notes ?? this.notes,
        validForDays:
            clearValidFor ? null : (validForDays ?? this.validForDays),
        status: status ?? this.status,
        createdAt: createdAt,
        sentAt: clearSentAt ? null : (sentAt ?? this.sentAt),
        respondedAt:
            clearRespondedAt ? null : (respondedAt ?? this.respondedAt),
        convertedJobId: clearConvertedJobId
            ? null
            : (convertedJobId ?? this.convertedJobId),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ref': quoteRef,
        'customer': customer,
        'customerId': customerId,
        'address': address,
        'description': description,
        'estimatedHours': estimatedHours,
        'hourlyRate': hourlyRateGbp,
        'lines': lines.map((l) => l.toJson()).toList(),
        'notes': notes,
        'validForDays': validForDays,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'sentAt': sentAt?.toIso8601String(),
        'respondedAt': respondedAt?.toIso8601String(),
        'convertedJobId': convertedJobId,
      };

  factory Quote.fromJson(Map<String, dynamic> j) => Quote(
        id: j['id'] as String,
        quoteRef: j['ref'] as String? ?? '',
        customer: j['customer'] as String? ?? '',
        customerId: j['customerId'] as String? ?? '',
        address: j['address'] as String? ?? '',
        description: j['description'] as String? ?? '',
        estimatedHours: (j['estimatedHours'] as num?)?.toDouble() ?? 0,
        hourlyRateGbp: (j['hourlyRate'] as num?)?.toDouble() ?? 0,
        lines: ((j['lines'] as List?) ?? const [])
            .map((e) =>
                QuoteLineItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        notes: j['notes'] as String? ?? '',
        validForDays: j['validForDays'] as int?,
        status: _decodeStatus(j['status'] as String?),
        createdAt:
            DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
        sentAt: j['sentAt'] == null
            ? null
            : DateTime.tryParse(j['sentAt'] as String),
        respondedAt: j['respondedAt'] == null
            ? null
            : DateTime.tryParse(j['respondedAt'] as String),
        convertedJobId: j['convertedJobId'] as String?,
      );
}

String _generateId() {
  final ts = DateTime.now().millisecondsSinceEpoch;
  final r = math.Random().nextInt(1 << 32);
  return 'q-$ts-${r.toRadixString(36)}';
}

/// User-visible reference like "Q-2026-051" — short, customer-friendly,
/// includes year so it doesn't reset confusingly.
String _generateRef(DateTime when) {
  final year = when.year.toString();
  final r = math.Random().nextInt(900) + 100; // 100-999
  return 'Q-$year-$r';
}

String encodeQuotes(List<Quote> list) =>
    jsonEncode(list.map((q) => q.toJson()).toList());

List<Quote> decodeQuotes(String? raw) =>
    SchemaSafe.decodeList<Quote>(
      key: 'quotes_v1',
      raw: raw,
      fromJson: Quote.fromJson,
    );
