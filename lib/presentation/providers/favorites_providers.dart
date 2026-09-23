import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/doctor.dart';
import 'infrastructure_providers.dart';

/// Persisted set of favorite provider ids.
final favoritesProvider =
    AsyncNotifierProvider<FavoritesController, Set<String>>(
      FavoritesController.new,
    );

class FavoritesController extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() =>
      ref.watch(favoritesRepositoryProvider).loadFavoriteIds();

  /// Optimistic toggle: the UI flips immediately; if persistence fails the
  /// previous set is restored and the error is rethrown for the caller to
  /// surface (snack bar).
  Future<void> toggle(String doctorId) async {
    final repository = ref.read(favoritesRepositoryProvider);
    final previous = state.value ?? const <String>{};
    final optimistic = <String>{...previous};
    optimistic.contains(doctorId)
        ? optimistic.remove(doctorId)
        : optimistic.add(doctorId);

    state = AsyncData(Set.unmodifiable(optimistic));
    try {
      await repository.saveFavoriteIds(optimistic);
    } catch (error) {
      state = AsyncData(Set.unmodifiable(previous));
      rethrow;
    }
  }
}

/// Per-provider favorite flag. Watching this (instead of the whole set)
/// means only the affected favorite buttons rebuild on a toggle — the
/// surrounding list stays untouched.
final isFavoriteProvider = Provider.family<bool, String>(
  (ref, doctorId) => (ref.watch(favoritesProvider).value ?? const <String>{})
      .contains(doctorId),
);

/// Full [Doctor] objects for the favorites screen.
final favoriteDoctorsProvider = FutureProvider<List<Doctor>>((ref) async {
  final ids = ref.watch(favoritesProvider).value ?? const <String>{};
  if (ids.isEmpty) return const <Doctor>[];
  final repository = ref.read(doctorRepositoryProvider);
  return repository.fetchDoctorsByIds(ids.toList());
});
