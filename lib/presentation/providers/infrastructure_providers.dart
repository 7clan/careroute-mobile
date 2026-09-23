import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/auth_interceptor.dart';
import '../../core/network/mock_backend/backend_conditions.dart';
import '../../core/network/mock_backend/mock_backend_adapter.dart';
import '../../core/network/mock_backend/mock_database.dart';
import '../../core/network/session_events.dart';
import '../../core/storage/key_value_store.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/doctor_repository_impl.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../../domain/repositories/favorites_repository.dart';

/// Overridden in `main()` after `SharedPreferences.getInstance()`.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  );
});

final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => SharedPreferencesKeyValueStore(ref.watch(sharedPreferencesProvider)),
);

/// Deterministic API state. Overridden per test for isolation.
final mockDatabaseProvider = Provider<MockDatabase>(
  (ref) => MockDatabase.seeded(),
);

/// Mutable runtime conditions read by the mock backend adapter.
final backendConditionsProvider =
    NotifierProvider<BackendConditionsController, BackendConditions>(
      BackendConditionsController.new,
    );

class BackendConditionsController extends Notifier<BackendConditions> {
  @override
  BackendConditions build() => const BackendConditions();

  void setOffline(bool value) => state = state.copyWith(offline: value);

  void setMalformed(bool value) =>
      state = state.copyWith(malformedResponse: value);

  void setForceServerError(bool value) =>
      state = state.copyWith(forceStatus: value ? 500 : null);

  void setSimulatedTimeout(bool value) => state = state.copyWith(
    timeoutAfter: value ? const Duration(seconds: 15) : null,
  );

  void setLatency(Duration latency) => state = state.copyWith(latency: latency);

  void reset() => state = const BackendConditions();
}

final sessionEventsProvider = Provider<SessionEvents>((ref) {
  final events = SessionEvents();
  ref.onDispose(events.dispose);
  return events;
});

/// Session storage — swap with [InMemoryAuthLocalDataSource] in tests.
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => SecureAuthLocalDataSource(),
);

/// The app's single configured Dio instance.
///
/// Pointing `httpClientAdapter` at the in-process [MockDatabase] keeps the
/// whole REST pipeline (interceptors, status codes, JSON decoding, timeouts)
/// real while remaining runnable without infrastructure. Replacing the
/// adapter line with the default one is all it takes to talk to a live
/// backend — no repository changes required.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.careroute.local/v1',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 8),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.httpClientAdapter = MockBackendAdapter(
    readConditions: () => ref.read(backendConditionsProvider),
    database: ref.watch(mockDatabaseProvider),
  );
  dio.interceptors.add(
    AuthInterceptor(
      tokenReader: () async =>
          (await ref.read(authLocalDataSourceProvider).read())?.token,
      sessionEvents: ref.watch(sessionEventsProvider),
    ),
  );
  ref.onDispose(dio.close);
  return dio;
});

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    dio: ref.watch(dioProvider),
    local: ref.watch(authLocalDataSourceProvider),
  ),
);

final doctorRepositoryProvider = Provider<DoctorRepository>(
  (ref) => DoctorRepositoryImpl(dio: ref.watch(dioProvider)),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepositoryImpl(store: ref.watch(keyValueStoreProvider)),
);

final appointmentRepositoryProvider = Provider<AppointmentRepository>(
  (ref) => AppointmentRepositoryImpl(dio: ref.watch(dioProvider)),
);
