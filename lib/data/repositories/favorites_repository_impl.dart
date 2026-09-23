import 'dart:convert';

import '../../core/storage/key_value_store.dart';
import '../../domain/repositories/favorites_repository.dart';

/// Persists favorite provider ids on the device.
///
/// Favorites are deliberately local: they must be available offline and
/// instantly on every launch. Swapping to a server-backed implementation
/// only means re-implementing this small class.
class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl({required this.store}) : _key = 'careroute.favorites';

  final KeyValueStore store;
  final String _key;

  @override
  Future<Set<String>> loadFavoriteIds() async {
    final raw = await store.read(_key);
    if (raw == null) return <String>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return {for (final id in decoded) id.toString()};
      }
    } on FormatException {
      // Corrupt data → start fresh rather than crash.
    }
    return <String>{};
  }

  @override
  Future<void> saveFavoriteIds(Set<String> ids) {
    return store.write(_key, jsonEncode(ids.toList()));
  }
}
