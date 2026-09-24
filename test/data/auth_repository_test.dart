import 'package:flutter_test/flutter_test.dart';

import 'package:careroute_mobile/core/errors/app_exception.dart';
import 'package:careroute_mobile/core/network/mock_backend/backend_conditions.dart';
import 'package:careroute_mobile/core/network/mock_backend/mock_database.dart';
import 'package:careroute_mobile/data/datasources/auth_local_data_source.dart';
import 'package:careroute_mobile/data/repositories/auth_repository_impl.dart';
import 'package:careroute_mobile/domain/entities/auth_session.dart';

import '../helpers/test_container.dart';

void main() {
  late InMemoryAuthLocalDataSource storage;
  late AuthRepositoryImpl repository;

  setUp(() {
    storage = InMemoryAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      dio: createTestDio(
        conditions: const BackendConditions(latency: Duration.zero),
        authStorage: storage,
      ),
      local: storage,
    );
  });

  group('AuthRepositoryImpl', () {
    test('login stores and returns the session', () async {
      final session = await repository.login(
        email: MockDatabase.demoEmail,
        password: MockDatabase.demoPassword,
      );

      expect(session.user.email, MockDatabase.demoEmail);
      expect(session.token, isNotEmpty);
      expect(session.isExpired, isFalse);

      final stored = await storage.read();
      expect(stored?.token, session.token);
    });

    test('login failure surfaces as UnauthorizedException', () async {
      expect(
        () => repository.login(
          email: MockDatabase.demoEmail,
          password: 'wrong-password',
        ),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(
        await storage.read(),
        isNull,
        reason: 'failed logins must not store anything',
      );
    });

    test('register validation errors carry field messages', () async {
      await expectLater(
        () => repository.register(
          name: 'A',
          email: 'bad',
          password: 'short',
          passwordConfirmation: 'mismatch',
        ),
        throwsA(
          isA<ValidationException>().having(
            (error) => error.fieldErrors.keys.toSet(),
            'fields',
            containsAll(['name', 'email', 'password', 'passwordConfirmation']),
          ),
        ),
      );
    });

    test('register creates a usable session', () async {
      final session = await repository.register(
        name: 'Test Patient',
        email: 'test.patient@mail.com',
        password: 'Password1',
        passwordConfirmation: 'Password1',
      );
      expect(session.user.name, 'Test Patient');
      expect(await storage.read(), isNotNull);
    });

    test('restoreSession returns null when signed out', () async {
      expect(await repository.restoreSession(), isNull);
    });

    test('restoreSession validates a stored token against /auth/me', () async {
      await repository.login(
        email: MockDatabase.demoEmail,
        password: MockDatabase.demoPassword,
      );
      final restored = await repository.restoreSession();
      expect(restored?.user.email, MockDatabase.demoEmail);
    });

    test('restoreSession drops an expired stored session', () async {
      final user = (await repository.login(
        email: MockDatabase.demoEmail,
        password: MockDatabase.demoPassword,
      )).user;
      await storage.save(
        AuthSession(
          token:
              'mt_u0_${DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch}',
          expiresAt: DateTime.now().subtract(const Duration(hours: 2)),
          user: user,
        ),
      );
      expect(await repository.restoreSession(), isNull);
      expect(
        await storage.read(),
        isNull,
        reason: 'expired sessions must be cleared',
      );
    });

    test('logout clears local state even when the API call fails', () async {
      await repository.login(
        email: MockDatabase.demoEmail,
        password: MockDatabase.demoPassword,
      );

      final failingRepository = AuthRepositoryImpl(
        dio: createTestDio(
          conditions: const BackendConditions(
            latency: Duration.zero,
            offline: true,
          ),
          authStorage: storage,
        ),
        local: storage,
      );

      await failingRepository.logout();
      expect(await storage.read(), isNull);
    });

    test('offline mode surfaces as NoNetworkException', () async {
      final offlineRepository = AuthRepositoryImpl(
        dio: createTestDio(
          conditions: const BackendConditions(
            latency: Duration.zero,
            offline: true,
          ),
          authStorage: storage,
        ),
        local: storage,
      );

      await expectLater(
        () => offlineRepository.login(
          email: MockDatabase.demoEmail,
          password: MockDatabase.demoPassword,
        ),
        throwsA(isA<NoNetworkException>()),
      );
    });

    test('server errors surface as ServerException', () async {
      final failingRepository = AuthRepositoryImpl(
        dio: createTestDio(
          conditions: const BackendConditions(
            latency: Duration.zero,
            forceStatus: 500,
          ),
          authStorage: storage,
        ),
        local: storage,
      );

      await expectLater(
        () => failingRepository.login(
          email: MockDatabase.demoEmail,
          password: MockDatabase.demoPassword,
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('malformed responses surface as ParsingException', () async {
      final malformedRepository = AuthRepositoryImpl(
        dio: createTestDio(
          conditions: const BackendConditions(
            latency: Duration.zero,
            malformedResponse: true,
          ),
          authStorage: storage,
        ),
        local: storage,
      );

      await expectLater(
        () => malformedRepository.login(
          email: MockDatabase.demoEmail,
          password: MockDatabase.demoPassword,
        ),
        throwsA(isA<ParsingException>()),
      );
    });

    test('hanging requests surface as TimeoutException', () async {
      final hangingRepository = AuthRepositoryImpl(
        dio: createTestDio(
          conditions: const BackendConditions(
            latency: Duration.zero,
            timeoutAfter: Duration(seconds: 2),
          ),
          authStorage: storage,
          timeout: const Duration(milliseconds: 150),
        ),
        local: storage,
      );

      await expectLater(
        () => hangingRepository.login(
          email: MockDatabase.demoEmail,
          password: MockDatabase.demoPassword,
        ),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
