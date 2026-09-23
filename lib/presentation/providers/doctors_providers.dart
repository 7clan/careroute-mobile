import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/debouncer.dart';
import '../../domain/entities/availability.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/doctor_query.dart';
import '../../domain/entities/specialty.dart';
import 'infrastructure_providers.dart';

/// Search / filter criteria chosen on the discovery screen.
final doctorFiltersProvider =
    NotifierProvider<DoctorFiltersController, DoctorQuery>(
      DoctorFiltersController.new,
    );

class DoctorFiltersController extends Notifier<DoctorQuery> {
  // 350ms of typing quiet before the search actually fires — the network
  // and list must not thrash on every keystroke. One instance per
  // ProviderScope (important for test isolation).
  late final _searchDebouncer = Debouncer(
    delay: const Duration(milliseconds: 350),
  );

  @override
  DoctorQuery build() {
    ref.onDispose(_searchDebouncer.dispose);
    return const DoctorQuery();
  }

  /// Called on every keystroke; commits after the debounce window.
  void updateSearch(String text) {
    _searchDebouncer(() => _commitSearch(text));
  }

  void clearSearch() {
    _searchDebouncer.cancel();
    _commitSearch('');
  }

  void _commitSearch(String text) {
    if (text == state.search) return;
    state = state.copyWith(search: text).firstPage;
  }

  void setSpecialty(String? specialtyId) {
    if (specialtyId == state.specialtyId) return;
    state = state.copyWith(specialtyId: specialtyId).firstPage;
  }

  void setCity(String? city) {
    if (city == state.city) return;
    state = state.copyWith(city: city).firstPage;
  }

  void clearFilters() {
    _searchDebouncer.cancel();
    state = const DoctorQuery();
  }
}

/// Rendered state of the discovery feed.
class DoctorsState {
  const DoctorsState({
    required this.doctors,
    required this.query,
    required this.totalCount,
    required this.hasMore,
    this.loadingMore = false,
    this.loadMoreError,
  });

  final List<Doctor> doctors;

  /// The query the loaded pages belong to (filters + page number).
  final DoctorQuery query;
  final int totalCount;
  final bool hasMore;

  /// True while the next page is being appended.
  final bool loadingMore;

  /// Error of the *last* load-more attempt — the list stays visible with a
  /// retry footer instead of being replaced by a full-screen error.
  final AppException? loadMoreError;

  DoctorsState copyWith({
    List<Doctor>? doctors,
    DoctorQuery? query,
    int? totalCount,
    bool? hasMore,
    bool? loadingMore,
    AppException? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return DoctorsState(
      doctors: doctors ?? this.doctors,
      query: query ?? this.query,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      loadMoreError: clearLoadMoreError
          ? null
          : loadMoreError ?? this.loadMoreError,
    );
  }

  static DoctorsState fromPage(
    List<Doctor> items,
    DoctorQuery query, {
    required int totalCount,
    required bool hasMore,
  }) {
    return DoctorsState(
      doctors: items,
      query: query,
      totalCount: totalCount,
      hasMore: hasMore,
    );
  }
}

/// The discovery feed: first page + appended pages + retry states.
final doctorsProvider = AsyncNotifierProvider<DoctorsController, DoctorsState>(
  DoctorsController.new,
);

class DoctorsController extends AsyncNotifier<DoctorsState> {
  /// Incremented whenever the feed restarts; lets in-flight "load more"
  /// responses detect that they belong to an outdated query and drop
  /// themselves instead of corrupting the new results.
  int _requestSeq = 0;

  @override
  Future<DoctorsState> build() async {
    _requestSeq++;
    final query = ref.watch(doctorFiltersProvider).firstPage;
    final repository = ref.read(doctorRepositoryProvider);
    final page = await repository.fetchDoctors(query);
    return DoctorsState.fromPage(
      page.items,
      query,
      totalCount: page.totalCount,
      hasMore: page.hasMore,
    );
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;

    final seq = _requestSeq;
    final repository = ref.read(doctorRepositoryProvider);
    final nextQuery = current.query.copyWith(page: current.query.page + 1);

    state = AsyncData(
      current.copyWith(loadingMore: true, clearLoadMoreError: true),
    );
    try {
      final page = await repository.fetchDoctors(nextQuery);
      if (seq != _requestSeq) return; // filters changed mid-flight
      state = AsyncData(
        current.copyWith(
          doctors: [...current.doctors, ...page.items],
          query: nextQuery,
          totalCount: page.totalCount,
          hasMore: page.hasMore,
          loadingMore: false,
        ),
      );
    } on AppException catch (error) {
      if (seq != _requestSeq) return;
      state = AsyncData(
        current.copyWith(loadingMore: false, loadMoreError: error),
      );
    }
  }

  /// Pull-to-refresh: restart from page 1.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Specialty chips data (cached for the session).
final specialtiesProvider = FutureProvider<List<Specialty>>(
  (ref) => ref.watch(doctorRepositoryProvider).fetchSpecialties(),
);

/// City filter options.
final citiesProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(doctorRepositoryProvider).fetchCities(),
);

/// Full profile of a single provider.
final doctorDetailProvider = FutureProvider.family<Doctor, String>((
  ref,
  id,
) async {
  return ref.watch(doctorRepositoryProvider).fetchDoctorDetail(id);
});

/// Bookable calendar of a single provider (next 3 weeks).
final availabilityProvider =
    FutureProvider.family<List<AvailabilityDay>, String>((ref, id) async {
      return ref
          .watch(doctorRepositoryProvider)
          .fetchAvailability(id, days: 21);
    });
