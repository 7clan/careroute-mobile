import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:careroute_mobile/core/errors/app_exception.dart';
import 'package:careroute_mobile/data/repositories/favorites_repository_impl.dart';
import 'package:careroute_mobile/core/network/mock_backend/backend_conditions.dart';
import 'package:careroute_mobile/core/network/mock_backend/mock_database.dart';
import 'package:careroute_mobile/core/storage/key_value_store.dart';
import 'package:careroute_mobile/data/datasources/auth_local_data_source.dart';
import 'package:careroute_mobile/domain/repositories/favorites_repository.dart';
import 'package:careroute_mobile/presentation/providers/infrastructure_providers.dart';
import 'package:careroute_mobile/presentation/providers/favorites_providers.dart';

import '../helpers/test_container.dart';

class _FailingFavoritesRepository implements FavoritesRepository {
  @override
  Future<Set<String>> loadFavoriteIds() async => const {};

  @override
  Future<void> saveFavoriteIds(Set<String> ids) async {
    throw const NoNetworkException();
  }
}

void main() {
  group('FavoritesController', () {
    test('loads persisted favorites on build', () async {
      final store = InMemoryKeyValueStore();
      final repository = FavoritesRepositoryImpl(store: store);
      await repository.saveFavoriteIds({'d1', 'd4'});

      final container = createTestContainer(keyValueStore: store);
      final favorites = await container.read(favoritesProvider.future);
      expect(favorites, {'d1', 'd4'});
    });

    test('toggle adds optimistically and persists', () async {
      final container = createTestContainer();

      await container.read(favoritesProvider.future);
      await container.read(favoritesProvider.notifier).toggle('d3');

      expect(container.read(favoritesProvider).value, {'d3'});
      final store = container.read(keyValueStoreProvider);
      expect(await store.read('careroute.favorites'), isNotNull);
    });

    test('toggle removes an existing favorite', () async {
      final store = InMemoryKeyValueStore();
      final repository = FavoritesRepositoryImpl(store: store);
      await repository.saveFavoriteIds({'d3'});

      final container = createTestContainer(keyValueStore: store);
      await container.read(favoritesProvider.future);
      await container.read(favoritesProvider.notifier).toggle('d3');

      expect(container.read(favoritesProvider).value, isEmpty);
    });

    test('failed persistence rolls back and rethrows', () async {
      final container = ProviderContainer(
        overrides: [
          mockDatabaseProvider.overrideWithValue(MockDatabase.seeded()),
          keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore()),
          authLocalDataSourceProvider.overrideWithValue(
            InMemoryAuthLocalDataSource(),
          ),
          backendConditionsProvider.overrideWith(
            () => FixedConditionsController(
              const BackendConditions(latency: Duration.zero),
            ),
          ),
          favoritesRepositoryProvider.overrideWithValue(
            _FailingFavoritesRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(favoritesProvider.future);
      await expectLater(
        () => container.read(favoritesProvider.notifier).toggle('d9'),
        throwsA(isA<NoNetworkException>()),
      );
      expect(
        container.read(favoritesProvider).value,
        isEmpty,
        reason: 'optimistic change must be rolled back',
      );
    });

    test('isFavoriteProvider exposes per-doctor flags', () async {
      final container = createTestContainer();
      await container.read(favoritesProvider.future);
      await container.read(favoritesProvider.notifier).toggle('d5');

      expect(container.read(isFavoriteProvider('d5')), isTrue);
      expect(container.read(isFavoriteProvider('d6')), isFalse);
    });
  });
}
