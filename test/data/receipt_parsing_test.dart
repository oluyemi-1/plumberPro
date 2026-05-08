import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/data/receipt_parsing.dart';

/// Tests for the pure receipt-text parser. Each fixture is a realistic
/// fragment of a UK receipt — kept short on purpose so a regression in the
/// regex / keyword logic points at exactly which feature broke.
void main() {
  group('parseReceiptText: empty + nothing-found', () {
    test('empty string returns empty result', () {
      expect(parseReceiptText('').foundAnything, false);
      expect(parseReceiptText('   \n  ').foundAnything, false);
    });

    test('text with no recognisable patterns returns empty', () {
      final r = parseReceiptText('Hello world\nGoodbye');
      expect(r.amountGbp, isNull);
      expect(r.date, isNull);
      // Merchant might come back as "Hello world" — that's expected,
      // since it's the first non-junk line. Don't assert about it.
    });
  });

  group('parseReceiptText: amount', () {
    test('uses TOTAL line over a SUBTOTAL line', () {
      final r = parseReceiptText('''
Plumb Center
Subtotal     £40.00
VAT 20%       £8.00
TOTAL        £48.00
''');
      expect(r.amountGbp, 48.00);
    });

    test('keeps the latest TOTAL when several appear', () {
      final r = parseReceiptText('''
Subtotal £20.00
Total £20.00
VAT £4.00
GRAND TOTAL £24.00
''');
      expect(r.amountGbp, 24.00);
    });

    test('falls back to the largest £-prefixed number when no TOTAL', () {
      final r = parseReceiptText('''
Plumb Center
15mm copper £8.49
Solder £4.99
Receipt: £13.48
''');
      expect(r.amountGbp, 13.48);
    });

    test('handles GBP prefix in addition to the £ symbol', () {
      final r = parseReceiptText('''
SHELL FORECOURT
Diesel
TO PAY GBP 92.50
''');
      expect(r.amountGbp, 92.50);
    });

    test('handles thousand-separator amounts', () {
      final r = parseReceiptText('''
Boiler
TOTAL DUE £1,234.56
''');
      expect(r.amountGbp, 1234.56);
    });

    test('AMOUNT DUE wins over an isolated number further down', () {
      final r = parseReceiptText('''
HOWDENS
Cabinet
£950.00
AMOUNT DUE £500.00
''');
      expect(r.amountGbp, 500.00);
    });
  });

  group('parseReceiptText: date', () {
    test('parses dd/mm/yyyy', () {
      final r = parseReceiptText('Plumb Center\n12/05/2026\n');
      expect(r.date, DateTime(2026, 5, 12));
    });

    test('parses dd-mm-yy with 2-digit year', () {
      final r = parseReceiptText('Receipt 06-05-26 14:30');
      expect(r.date, DateTime(2026, 5, 6));
    });

    test('parses dd MMM yyyy in mixed case', () {
      final r = parseReceiptText('Date: 06 May 2026');
      expect(r.date, DateTime(2026, 5, 6));
    });

    test('rejects an impossible date (31 Feb)', () {
      final r = parseReceiptText('31/02/2026');
      expect(r.date, isNull);
    });

    test('rejects unrealistic years', () {
      // Year 1999 falls outside the 2000-2099 window we accept.
      final r = parseReceiptText('12/05/1999');
      expect(r.date, isNull);
    });
  });

  group('parseReceiptText: merchant', () {
    test('picks the first plausible top line', () {
      final r = parseReceiptText('''
Plumb Center
12 Pipe Road
London SW1A 1AA
Tel 020 7946 0000
Receipt 12/05/2026
TOTAL £48.00
''');
      expect(r.merchant, 'Plumb Center');
    });

    test('skips an address-like leading line and picks the next', () {
      final r = parseReceiptText('''
12 Pipe Road
WICKES
Branch SE1
TOTAL £88.00
''');
      expect(r.merchant, 'WICKES');
    });

    test('skips lines with a UK postcode', () {
      final r = parseReceiptText('''
SW1A 1AA
TOOLSTATION
TOTAL £12.00
''');
      expect(r.merchant, 'TOOLSTATION');
    });

    test('skips a phone number line', () {
      final r = parseReceiptText('''
0207 946 0123
SCREWFIX KINGSTON
TOTAL £7.49
''');
      expect(r.merchant, 'SCREWFIX KINGSTON');
    });
  });

  group('parseReceiptText: category guess', () {
    test('detects fuel from forecourt / petrol / diesel keywords', () {
      expect(
        parseReceiptText('SHELL FORECOURT\nDIESEL 30L\nTOTAL £42.00')
            .suggestedCategory,
        'Fuel',
      );
      expect(
        parseReceiptText('BP FUEL\nUNLEADED\nTOTAL £35.00')
            .suggestedCategory,
        'Fuel',
      );
    });

    test('detects parts & materials from trade-supplier names', () {
      for (final supplier in const [
        'PLUMB CENTER',
        'WOLSELEY UK',
        'TRAVIS PERKINS',
        'SCREWFIX KINGSTON',
        'TOOLSTATION SURBITON',
        'WICKES',
        'B&Q',
        'JEWSON',
      ]) {
        final r = parseReceiptText('$supplier\nTOTAL £10.00');
        expect(r.suggestedCategory, 'Parts & materials',
            reason: 'expected Parts & materials for $supplier');
      }
    });

    test('detects vehicle costs from MOT / tyres / Kwik Fit / Halfords', () {
      expect(
        parseReceiptText('KWIK FIT\nTYRE FITTING\nTOTAL £80.00')
            .suggestedCategory,
        'Vehicle (MOT, service, parking)',
      );
      expect(
        parseReceiptText('HALFORDS\nWiper blades\nTOTAL £18.99')
            .suggestedCategory,
        'Vehicle (MOT, service, parking)',
      );
    });

    test('detects training from "course" / ACS / CPD', () {
      expect(
        parseReceiptText('LOGIC TRAINING\nACS Renewal\nTOTAL £450.00')
            .suggestedCategory,
        'Training & qualifications',
      );
    });

    test('returns null for ambiguous text', () {
      expect(
        parseReceiptText('Random shop\nWhatever\nTOTAL £5.00')
            .suggestedCategory,
        isNull,
      );
    });
  });

  group('parseReceiptText: end-to-end realistic receipt', () {
    test('extracts amount, date, merchant and category for a Screwfix run',
        () {
      final r = parseReceiptText('''
SCREWFIX KINGSTON
Unit 4, Cambridge Road
KT1 3JU
12/05/2026 14:30

Compression elbow 15mm   £1.49
Pipe slice                £8.99
PTFE tape                 £0.99

SUBTOTAL                 £11.47
VAT 20%                   £2.29
TOTAL                    £13.76
''');
      expect(r.merchant, 'SCREWFIX KINGSTON');
      expect(r.amountGbp, 13.76);
      expect(r.date, DateTime(2026, 5, 12));
      expect(r.suggestedCategory, 'Parts & materials');
      expect(r.foundAnything, true);
    });

    test('extracts everything for a fuel receipt', () {
      final r = parseReceiptText('''
SHELL FORECOURT GUILDFORD
06 May 2026 09:14

Diesel 38.42L
GBP 65.99

TOTAL    £65.99
''');
      expect(r.merchant, 'SHELL FORECOURT GUILDFORD');
      expect(r.amountGbp, 65.99);
      expect(r.date, DateTime(2026, 5, 6));
      expect(r.suggestedCategory, 'Fuel');
    });
  });
}
