import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careroute_mobile/core/network/mock_backend/backend_conditions.dart';
import 'package:careroute_mobile/core/network/auth_interceptor.dart';
import 'package:careroute_mobile/core/network/mock_backend/mock_backend_adapter.dart';
import 'package:careroute_mobile/core/network/mock_backend/mock_database.dart';
import 'package:careroute_mobile/core/network/session_events.dart';
import 'package:careroute_mobile/core/storage/key_value_store.dart';
import 'package:careroute_mobile/data/datasources/auth_local_data_source.dart';
import 'package:careroute_mobile/presentation/providers/infrastructure_providers.dart';

/// Creates an isolated [ProviderContainer] for provider/state tests.
///
/// Every test gets:
/// * a freshly seeded [MockDatabase] (no shared mutable state),
/// * an in-memory key/value store (no SharedPreferences plugin needed),
/// * an in-memory session storage (no flutter_secure_storage plugin),
/// * optional [conditions] (zero latency by default).
ProviderContainer createTestContainer({
  MockDatabase? database,
  KeyValueStore? keyValueStore,
  AuthLocalDataSource? authStorage,
  BackendConditions conditions = const BackendConditions(
    latency: Duration.zero,
  ),
}) {
  final container = ProviderContainer(
    // Same retry policy as the app (see lib/main.dart): erroring providers
    // must surface their error immediately in tests.
    retry: (retryCount, error) => null,
    overrides: [
      mockDatabaseProvider.overrideWithValue(database ?? MockDatabase.seeded()),
      keyValueStoreProvider.overrideWithValue(
        keyValueStore ?? InMemoryKeyValueStore(),
      ),
      authLocalDataSourceProvider.overrideWithValue(
        authStorage ?? InMemoryAuthLocalDataSource(),
      ),
      backendConditionsProvider.overrideWith(
        () => FixedConditionsController(conditions),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// A Dio wired exactly like the production one, but against a fresh
/// [MockDatabase] with [conditions] — used by repository tests that need
/// custom timeouts.
Dio createTestDio({
  required BackendConditions conditions,
  MockDatabase? database,
  AuthLocalDataSource? authStorage,
  Duration timeout = const Duration(seconds: 8),
}) {
  final local = authStorage ?? InMemoryAuthLocalDataSource();
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.careroute.local/v1',
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
    ),
  );
  dio.httpClientAdapter = MockBackendAdapter(
    readConditions: () => conditions,
    database: database ?? MockDatabase.seeded(),
  );
  dio.interceptors.add(
    AuthInterceptor(
      tokenReader: () async => (await local.read())?.token,
      sessionEvents: SessionEvents(),
    ),
  );
  return dio;
}

class FixedConditionsController extends BackendConditionsController {
  FixedConditionsController(this._initial);

  final BackendConditions _initial;

  @override
  BackendConditions build() => _initial;
}
