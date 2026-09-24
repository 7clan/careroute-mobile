import 'package:flutter_test/flutter_test.dart';

import 'package:careroute_mobile/core/storage/key_value_store.dart';
import 'package:careroute_mobile/data/repositories/favorites_repository_impl.dart';

void main() {
  late InMemoryKeyValueStore store;
  late FavoritesRepositoryImpl repository;

  setUp(() {
    store = InMemoryKeyValueStore();
    repository = FavoritesRepositoryImpl(store: store);
  });

  group('FavoritesRepositoryImpl', () {
    test('starts empty', () async {
      expect(await repository.loadFavoriteIds(), isEmpty);
    });

    test('save/load round-trips ids', () async {
      await repository.saveFavoriteIds({'d1', 'd7'});
      expect(await repository.loadFavoriteIds(), {'d1', 'd7'});
    });

    test('overwrites previous state', () async {
      await repository.saveFavoriteIds({'d1'});
      await repository.saveFavoriteIds({'d2'});
      expect(await repository.loadFavoriteIds(), {'d2'});
    });

    test('corrupt stored data degrades to empty instead of crashing', () async {
      await store.write('careroute.favorites', 'not json at all');
      expect(await repository.loadFavoriteIds(), isEmpty);
    });
  });
}
