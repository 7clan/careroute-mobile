import 'package:flutter_test/flutter_test.dart';

import 'package:careroute_mobile/core/utils/validators.dart';

void main() {
  group('Validators.name', () {
    test('rejects empty and short names', () {
      expect(Validators.name(''), isNotNull);
      expect(Validators.name('  '), isNotNull);
      expect(Validators.name('A'), isNotNull);
    });

    test('accepts ordinary names', () {
      expect(Validators.name('Maya Haddad'), isNull);
      expect(Validators.name('Jo'), isNull);
    });

    test('rejects overly long names', () {
      expect(Validators.name('a' * 61), isNotNull);
    });
  });

  group('Validators.email', () {
    test('rejects empty and malformed addresses', () {
      for (final input in ['', 'plain', 'a@b', 'a b@c.com', 'a@b.c']) {
        expect(Validators.email(input), isNotNull, reason: '"$input"');
      }
    });

    test('accepts well-formed addresses', () {
      expect(Validators.email('demo@careroute.app'), isNull);
      expect(Validators.email(' first.last+tag@mail.co.uk '), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects empty, short, letter-only and digit-only passwords', () {
      for (final input in ['', 'Ab1', 'abcdefgh', '12345678']) {
        expect(Validators.password(input), isNotNull, reason: '"$input"');
      }
    });

    test('accepts mixed passwords of sufficient length', () {
      expect(Validators.password('Demo1234'), isNull);
      expect(Validators.password('correct horse9'), isNull);
    });
  });

  group('Validators.passwordConfirmation', () {
    test('requires an exact match', () {
      expect(Validators.passwordConfirmation('Demo1234', 'Demo1234'), isNull);
      expect(
        Validators.passwordConfirmation('Demo1234', 'Demo12345'),
        isNotNull,
      );
      expect(Validators.passwordConfirmation('', 'Demo1234'), isNotNull);
    });
  });

  group('Validators.reason', () {
    test('optional but bounded', () {
      expect(Validators.reason(null), isNull);
      expect(Validators.reason(''), isNull);
      expect(Validators.reason('a' * 401), isNotNull);
    });
  });
}
