/// Favorites are stored on-device: they must survive app restarts, load
/// instantly on the discovery screen and keep working while offline.
abstract interface class FavoritesRepository {
  /// Reads the persisted set of favorite provider ids.
  Future<Set<String>> loadFavoriteIds();

  /// Persists the full set of favorite provider ids.
  Future<void> saveFavoriteIds(Set<String> ids);
}
