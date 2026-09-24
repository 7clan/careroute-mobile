import 'package:flutter_test/flutter_test.dart';

import 'package:careroute_mobile/core/errors/app_exception.dart';
import 'package:careroute_mobile/core/network/mock_backend/mock_database.dart';
import 'package:careroute_mobile/presentation/providers/infrastructure_providers.dart';
import 'package:careroute_mobile/presentation/providers/session_providers.dart';

import '../helpers/test_container.dart';

void main() {
  group('SessionController', () {
    test('restores to signed-out when nothing is stored', () async {
      final container = createTestContainer();
      final session = await container.read(sessionProvider.future);
      expect(session, isNull);
    });

    test('login updates state to a session', () async {
      final container = createTestContainer();

      await container
          .read(sessionProvider.notifier)
          .login(
            email: MockDatabase.demoEmail,
            password: MockDatabase.demoPassword,
          );

      final session = container.read(sessionProvider).value;
      expect(session?.user.email, MockDatabase.demoEmail);
    });

    test('failed login resets state to signed-out and rethrows', () async {
      final container = createTestContainer();
      // Prime the provider first so the notifier exists.
      await container.read(sessionProvider.future);

      await expectLater(
        () => container
            .read(sessionProvider.notifier)
            .login(email: MockDatabase.demoEmail, password: 'nope'),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(container.read(sessionProvider).value, isNull);
    });

    test('logout returns to signed-out state', () async {
      final container = createTestContainer();
      await container
          .read(sessionProvider.notifier)
          .login(
            email: MockDatabase.demoEmail,
            password: MockDatabase.demoPassword,
          );
      expect(container.read(sessionProvider).value, isNotNull);

      await container.read(sessionProvider.notifier).logout();
      expect(container.read(sessionProvider).value, isNull);
    });

    test('register signs the new user in', () async {
      final container = createTestContainer();

      await container
          .read(sessionProvider.notifier)
          .register(
            name: 'Widget Tester',
            email: 'widget.tester@mail.com',
            password: 'Password1',
            passwordConfirmation: 'Password1',
          );

      expect(container.read(sessionProvider).value?.user.name, 'Widget Tester');
    });

    test('a session-expired event signs the user out and notifies', () async {
      final container = createTestContainer();
      await container
          .read(sessionProvider.notifier)
          .login(
            email: MockDatabase.demoEmail,
            password: MockDatabase.demoPassword,
          );
      expect(container.read(sessionProvider).value, isNotNull);

      // Simulate what AuthInterceptor does when a protected call answers 401.
      container.read(sessionEventsProvider).notifySessionExpired();
      // The event is delivered asynchronously.
      await Future<void>.delayed(Duration.zero);

      expect(container.read(sessionProvider).value, isNull);
      expect(container.read(authNoticeProvider), isNotNull);
      expect(container.read(authNoticeProvider), contains('expired'));
    });
  });
}
