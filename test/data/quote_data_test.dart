import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/data/quote_data.dart';

void main() {
  group('QuoteLineItem', () {
    test('totalGbp = quantity × unit price', () {
      const l = QuoteLineItem(
        id: 'l1',
        description: 'Combi boiler',
        quantity: 1,
        unitPriceGbp: 950,
      );
      expect(l.totalGbp, 950);
    });

    test('JSON round-trip preserves every field', () {
      const l = QuoteLineItem(
        id: 'l2',
        description: 'TRV',
        quantity: 8,
        unitPriceGbp: 22.50,
      );
      final back = QuoteLineItem.fromJson(l.toJson());
      expect(back.id, l.id);
      expect(back.description, l.description);
      expect(back.quantity, l.quantity);
      expect(back.unitPriceGbp, l.unitPriceGbp);
    });

    test('fromJson tolerates missing fields', () {
      final back = QuoteLineItem.fromJson({'id': 'lx'});
      expect(back.description, '');
      expect(back.quantity, 1.0);
      expect(back.unitPriceGbp, 0.0);
    });
  });

  group('Quote math', () {
    Quote build({
      double hours = 0,
      double rate = 0,
      List<QuoteLineItem> lines = const [],
    }) =>
        Quote(
          id: 'q1',
          quoteRef: 'Q-2026-001',
          customer: 'Test',
          customerId: '',
          address: '',
          description: '',
          estimatedHours: hours,
          hourlyRateGbp: rate,
          lines: lines,
          notes: '',
          validForDays: 30,
          status: QuoteStatus.draft,
          createdAt: DateTime.utc(2026, 5, 6),
          sentAt: null,
          respondedAt: null,
          convertedJobId: null,
        );

    test('labourCost = hours × rate', () {
      final q = build(hours: 4, rate: 60);
      expect(q.labourCost, closeTo(240, 1e-9));
    });

    test('materialsCost sums every line', () {
      final q = build(lines: const [
        QuoteLineItem(
            id: 'a', description: 'A', quantity: 2, unitPriceGbp: 10),
        QuoteLineItem(
            id: 'b', description: 'B', quantity: 1, unitPriceGbp: 25),
      ]);
      expect(q.materialsCost, 45);
    });

    test('subtotalGbp = labour + materials', () {
      final q = build(
        hours: 3,
        rate: 50,
        lines: const [
          QuoteLineItem(
              id: 'a', description: 'A', quantity: 1, unitPriceGbp: 80),
        ],
      );
      expect(q.subtotalGbp, closeTo(150 + 80, 1e-9));
    });
  });

  group('Quote.expiresAt / isExpired', () {
    Quote q({int? validForDays, DateTime? created}) => Quote(
          id: 'qexp',
          quoteRef: 'Q-x',
          customer: 'C',
          customerId: '',
          address: '',
          description: '',
          estimatedHours: 0,
          hourlyRateGbp: 0,
          lines: const [],
          notes: '',
          validForDays: validForDays,
          status: QuoteStatus.sent,
          createdAt: created ?? DateTime(2026, 5, 6),
          sentAt: null,
          respondedAt: null,
          convertedJobId: null,
        );

    test('null validForDays ⇒ no expiry, never expired', () {
      expect(q(validForDays: null).expiresAt, isNull);
      expect(q(validForDays: null).isExpired(now: DateTime(2030, 1, 1)),
          false);
    });

    test('expiresAt = createdAt + validForDays', () {
      final quote = q(
        validForDays: 14,
        created: DateTime(2026, 5, 1),
      );
      expect(quote.expiresAt, DateTime(2026, 5, 15));
    });

    test('isExpired flips after expiry date', () {
      final quote = q(validForDays: 30, created: DateTime(2026, 1, 1));
      expect(quote.isExpired(now: DateTime(2026, 1, 15)), false);
      expect(quote.isExpired(now: DateTime(2026, 6, 1)), true);
    });
  });

  group('QuoteStatus', () {
    test('isOpen covers draft + sent only', () {
      expect(QuoteStatus.draft.isOpen, true);
      expect(QuoteStatus.sent.isOpen, true);
      expect(QuoteStatus.accepted.isOpen, false);
      expect(QuoteStatus.rejected.isOpen, false);
    });

    test('label is human-readable for each status', () {
      expect(QuoteStatus.draft.label, 'Draft');
      expect(QuoteStatus.sent.label, 'Sent');
      expect(QuoteStatus.accepted.label, 'Accepted');
      expect(QuoteStatus.rejected.label, 'Rejected');
    });
  });

  group('Quote JSON', () {
    test('round-trip preserves a fully-populated quote', () {
      final q = Quote(
        id: 'q-1',
        quoteRef: 'Q-2026-042',
        customer: 'Mrs Brown',
        customerId: 'c-1',
        address: '5 Main St',
        description: 'Bathroom rough first-fix',
        estimatedHours: 12,
        hourlyRateGbp: 55,
        lines: const [
          QuoteLineItem(
              id: 'l1',
              description: 'Pipework',
              quantity: 1,
              unitPriceGbp: 180),
        ],
        notes: 'Customer to clear loft access.',
        validForDays: 21,
        status: QuoteStatus.sent,
        createdAt: DateTime.utc(2026, 5, 6),
        sentAt: DateTime.utc(2026, 5, 6, 14, 30),
        respondedAt: null,
        convertedJobId: null,
      );
      final back = Quote.fromJson(q.toJson());
      expect(back.id, q.id);
      expect(back.quoteRef, q.quoteRef);
      expect(back.customer, q.customer);
      expect(back.estimatedHours, q.estimatedHours);
      expect(back.hourlyRateGbp, q.hourlyRateGbp);
      expect(back.lines.length, 1);
      expect(back.lines.first.description, 'Pipework');
      expect(back.notes, q.notes);
      expect(back.validForDays, 21);
      expect(back.status, QuoteStatus.sent);
      expect(back.sentAt, q.sentAt);
      expect(back.convertedJobId, isNull);
    });

    test('round-trip preserves an accepted, converted quote', () {
      final q = Quote(
        id: 'q-2',
        quoteRef: 'Q-2026-043',
        customer: 'Mr Brown',
        customerId: '',
        address: '',
        description: '',
        estimatedHours: 0,
        hourlyRateGbp: 50,
        lines: const [],
        notes: '',
        validForDays: null,
        status: QuoteStatus.accepted,
        createdAt: DateTime.utc(2026, 5, 6),
        sentAt: DateTime.utc(2026, 5, 6),
        respondedAt: DateTime.utc(2026, 5, 7),
        convertedJobId: 'job-99',
      );
      final back = Quote.fromJson(q.toJson());
      expect(back.status, QuoteStatus.accepted);
      expect(back.convertedJobId, 'job-99');
      expect(back.respondedAt, q.respondedAt);
      expect(back.validForDays, isNull);
    });

    test('list encode/decode round-trip', () {
      final list = [
        Quote.create(customer: 'A', hourlyRateGbp: 50),
        Quote.create(customer: 'B', hourlyRateGbp: 60),
      ];
      final back = decodeQuotes(encodeQuotes(list));
      expect(back.length, 2);
      expect(back[0].customer, 'A');
      expect(back[1].hourlyRateGbp, 60);
    });

    test('decode is null/corrupt-safe', () {
      expect(decodeQuotes(null), isEmpty);
      expect(decodeQuotes(''), isEmpty);
      expect(decodeQuotes('not-json'), isEmpty);
    });

    test('Quote.create stamps a draft with a quote ref containing the year',
        () {
      final q = Quote.create(customer: 'C', hourlyRateGbp: 50);
      expect(q.status, QuoteStatus.draft);
      expect(q.quoteRef, contains(DateTime.now().year.toString()));
      expect(q.validForDays, 30);
      expect(q.convertedJobId, isNull);
    });
  });

  group('Quote.copyWith', () {
    final q = Quote.create(customer: 'A', hourlyRateGbp: 50);

    test('clearValidFor wipes the expiry', () {
      final cleared = q.copyWith(clearValidFor: true);
      expect(cleared.validForDays, isNull);
    });

    test('clearConvertedJobId removes a job link', () {
      final linked = q.copyWith(convertedJobId: 'job-1');
      final unlinked = linked.copyWith(clearConvertedJobId: true);
      expect(unlinked.convertedJobId, isNull);
    });

    test('clearRespondedAt removes the response date', () {
      final responded =
          q.copyWith(respondedAt: DateTime.utc(2026, 6, 1));
      final reset = responded.copyWith(clearRespondedAt: true);
      expect(reset.respondedAt, isNull);
    });
  });
}
