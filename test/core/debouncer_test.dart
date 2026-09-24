import 'package:flutter_test/flutter_test.dart';

import 'package:careroute_mobile/core/utils/debouncer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Debouncer', () {
    test('does not run the callback before the delay', () async {
      var ran = false;
      final debouncer = Debouncer(delay: const Duration(milliseconds: 60));
      addTearDown(debouncer.dispose);

      debouncer(() => ran = true);
      expect(ran, isFalse, reason: 'must wait for the quiet window');

      await Future<void>.delayed(const Duration(milliseconds: 90));
      expect(ran, isTrue);
    });

    test('reschedules when a new event arrives during the window', () async {
      var calls = 0;
      var latestArg = '';
      final debouncer = Debouncer(delay: const Duration(milliseconds: 80));
      addTearDown(debouncer.dispose);

      debouncer(() => latestArg = 'first');
      await Future<void>.delayed(const Duration(milliseconds: 35));
      debouncer(() {
        calls++;
        latestArg = 'second';
      });

      // The first callback's original deadline (80ms) has passed —
      // it must have been rescheduled by the second event.
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(calls, 0, reason: 'rescheduling must push the deadline back');

      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(calls, 1);
      expect(latestArg, 'second');
    });

    test('cancel() prevents the pending callback', () async {
      var ran = false;
      final debouncer = Debouncer(delay: const Duration(milliseconds: 40));
      addTearDown(debouncer.dispose);

      debouncer(() => ran = true);
      debouncer.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 70));

      expect(ran, isFalse);
    });
  });
}
