import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/data/customer_data.dart';

void main() {
  group('Customer JSON', () {
    test('round-trip preserves every field', () {
      final c = Customer(
        id: 'c-1',
        name: 'A. Smith',
        address: '12 Plumber Lane, London',
        phone: '07700 900123',
        email: 'a@smith.example',
        notes: 'Has a black labrador, side gate code 1234.',
        createdAt: DateTime.utc(2026, 1, 15, 9, 30),
      );
      final j = c.toJson();
      final back = Customer.fromJson(j);
      expect(back.id, c.id);
      expect(back.name, c.name);
      expect(back.address, c.address);
      expect(back.phone, c.phone);
      expect(back.email, c.email);
      expect(back.notes, c.notes);
      expect(back.createdAt.toIso8601String(), c.createdAt.toIso8601String());
    });

    test('fromJson tolerates missing optional fields', () {
      final back = Customer.fromJson({
        'id': 'c-2',
        'name': 'B. Jones',
        'createdAt': '2026-02-01T00:00:00Z',
      });
      expect(back.address, '');
      expect(back.phone, '');
      expect(back.email, '');
      expect(back.notes, '');
    });

    test('encodeCustomers / decodeCustomers list round-trip', () {
      final list = [
        Customer.create(name: 'Aaron'),
        Customer.create(name: 'Brenda', phone: '01234'),
      ];
      final raw = encodeCustomers(list);
      final back = decodeCustomers(raw);
      expect(back.length, 2);
      expect(back[0].name, 'Aaron');
      expect(back[1].phone, '01234');
    });

    test('decodeCustomers returns empty list on null / empty / corrupt input',
        () {
      expect(decodeCustomers(null), isEmpty);
      expect(decodeCustomers(''), isEmpty);
      expect(decodeCustomers('not-json'), isEmpty);
      expect(decodeCustomers('{"id":"only-an-object"}'), isEmpty);
    });
  });

  group('Customer.firstLetter', () {
    test('returns uppercase first letter for normal names', () {
      expect(Customer.create(name: 'aaron').firstLetter, 'A');
      expect(Customer.create(name: 'Smith').firstLetter, 'S');
    });

    test('returns # for non-letter starts and empty names', () {
      expect(Customer.create(name: '').firstLetter, '#');
      expect(Customer.create(name: '12 Mr Smith').firstLetter, '#');
    });
  });
}
