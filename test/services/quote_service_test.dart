import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/data/quote_data.dart';
import 'package:plumbing_and_heating/services/job_log_service.dart';
import 'package:plumbing_and_heating/services/quote_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(const {});
    await QuoteService.instance.reload();
    await JobLogService.instance.reload();
  });

  group('QuoteService status transitions', () {
    test('markSent moves draft → sent and stamps sentAt', () async {
      final q = await QuoteService.instance.create(
        Quote.create(customer: 'A', hourlyRateGbp: 50),
      );
      await QuoteService.instance.markSent(q.id);
      final back = QuoteService.instance.findById(q.id)!;
      expect(back.status, QuoteStatus.sent);
      expect(back.sentAt, isNotNull);
    });

    test('markAccepted stamps respondedAt', () async {
      final q = await QuoteService.instance.create(
        Quote.create(customer: 'A', hourlyRateGbp: 50),
      );
      await QuoteService.instance.markAccepted(q.id);
      final back = QuoteService.instance.findById(q.id)!;
      expect(back.status, QuoteStatus.accepted);
      expect(back.respondedAt, isNotNull);
    });

    test('reopen on a converted quote is a no-op', () async {
      final q = await QuoteService.instance.create(
        Quote.create(customer: 'A', hourlyRateGbp: 50),
      );
      await QuoteService.instance.convertToJob(q.id);
      await QuoteService.instance.reopen(q.id);
      final back = QuoteService.instance.findById(q.id)!;
      // Should still be accepted + linked, not flipped back to draft.
      expect(back.status, QuoteStatus.accepted);
      expect(back.convertedJobId, isNotNull);
    });

    test('reopen on a rejected quote moves it back to draft', () async {
      final q = await QuoteService.instance.create(
        Quote.create(customer: 'A', hourlyRateGbp: 50),
      );
      await QuoteService.instance.markRejected(q.id);
      await QuoteService.instance.reopen(q.id);
      final back = QuoteService.instance.findById(q.id)!;
      expect(back.status, QuoteStatus.draft);
      expect(back.respondedAt, isNull);
    });
  });

  group('QuoteService.openCount', () {
    test('counts only draft + sent', () async {
      final svc = QuoteService.instance;
      final a = await svc.create(
          Quote.create(customer: 'A', hourlyRateGbp: 50));
      final b = await svc.create(
          Quote.create(customer: 'B', hourlyRateGbp: 50));
      final c = await svc.create(
          Quote.create(customer: 'C', hourlyRateGbp: 50));
      await svc.markSent(b.id);
      await svc.markAccepted(c.id);
      // a = draft, b = sent, c = accepted.
      expect(svc.openCount, 2);
      // Discard unused locals to avoid unused-variable warnings.
      expect(a.id, isNotEmpty);
    });
  });

  group('QuoteService.convertToJob', () {
    test('spawns a job pre-filled with the quote contents', () async {
      final q = await QuoteService.instance.create(Quote.create(
        customer: 'Mrs Brown',
        customerId: 'c-1',
        address: '5 Main St',
        description: 'Boiler swap',
        estimatedHours: 6,
        hourlyRateGbp: 55,
        lines: const [
          QuoteLineItem(
              id: 'l1',
              description: 'Combi 24kW',
              quantity: 1,
              unitPriceGbp: 950),
        ],
        notes: 'Loft access required.',
      ));

      final job = await QuoteService.instance.convertToJob(q.id);
      expect(job, isNotNull);
      expect(job!.customer, 'Mrs Brown');
      expect(job.customerId, 'c-1');
      expect(job.address, '5 Main St');
      expect(job.description, 'Boiler swap');
      expect(job.hourlyRateGbp, 55);
      expect(job.materials.length, 1);
      expect(job.materials.first.description, 'Combi 24kW');
      expect(job.materials.first.unitPriceGbp, 950);
      expect(job.notes, 'Loft access required.');

      // The quote is now accepted and linked.
      final back = QuoteService.instance.findById(q.id)!;
      expect(back.status, QuoteStatus.accepted);
      expect(back.convertedJobId, job.id);
      expect(back.respondedAt, isNotNull);
    });

    test('calling twice returns the same job — no duplicate', () async {
      final q = await QuoteService.instance.create(
          Quote.create(customer: 'A', hourlyRateGbp: 50));
      final first = await QuoteService.instance.convertToJob(q.id);
      final second = await QuoteService.instance.convertToJob(q.id);
      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(first!.id, second!.id);
      // And there's only one job in the log.
      expect(JobLogService.instance.jobs.length, 1);
    });
  });

  group('QuoteService persistence', () {
    test('items survive a reload', () async {
      final q = await QuoteService.instance.create(
          Quote.create(customer: 'Persist Test', hourlyRateGbp: 50));
      await QuoteService.instance.reload();
      expect(QuoteService.instance.findById(q.id), isNotNull);
    });

    test('delete removes the quote from disk', () async {
      final q = await QuoteService.instance.create(
          Quote.create(customer: 'X', hourlyRateGbp: 50));
      await QuoteService.instance.delete(q.id);
      await QuoteService.instance.reload();
      expect(QuoteService.instance.findById(q.id), isNull);
    });
  });
}
