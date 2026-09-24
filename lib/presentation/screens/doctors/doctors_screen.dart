import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../domain/entities/doctor_query.dart';
import '../../providers/doctors_providers.dart';
import '../../widgets/app_empty_view.dart';
import '../../widgets/app_error_view.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/skeleton_tile.dart';

/// Provider discovery: debounced search, specialty + city filters,
/// infinite pagination, pull-to-refresh and every list state
/// (loading / empty / error / load-more retry).
class DoctorsScreen extends ConsumerStatefulWidget {
  const DoctorsScreen({super.key});

  @override
  ConsumerState<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends ConsumerState<DoctorsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      // Restores the committed query when returning to this tab.
      text: ref.read(doctorFiltersProvider).search,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    ref.read(doctorFiltersProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(doctorFiltersProvider);
    final doctors = ref.watch(doctorsProvider);
    final hasActiveFilters =
        filters.search.isNotEmpty ||
        filters.specialtyId != null ||
        filters.city != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Discover providers',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _searchController,
                      builder: (context, _) => TextField(
                        controller: _searchController,
                        onChanged: (value) => ref
                            .read(doctorFiltersProvider.notifier)
                            .updateSearch(value),
                        decoration: InputDecoration(
                          hintText: 'Search name, specialty or city',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? Semantics(
                                  label: 'Clear search',
                                  button: true,
                                  child: IconButton(
                                    tooltip: 'Clear search',
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref
                                          .read(doctorFiltersProvider.notifier)
                                          .clearSearch();
                                    },
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  if (hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    Semantics(
                      label: 'Clear all filters',
                      button: true,
                      child: IconButton(
                        tooltip: 'Clear filters',
                        icon: const Icon(Icons.filter_alt_off_outlined),
                        onPressed: _clearFilters,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _FilterBar(filters: filters),
            Expanded(
              child: doctors.when(
                // Show skeletons (not stale data) whenever the query itself
                // changes — the user must see that a *new* search started.
                skipLoadingOnReload: false,
                skipLoadingOnRefresh: true,
                data: (state) => _DoctorList(
                  state: state,
                  searchController: _searchController,
                ),
                error: (error, _) => AppErrorView(
                  message: error is AppException
                      ? error.userMessage
                      : 'Something went wrong while loading providers.',
                  onRetry: () => ref.invalidate(doctorsProvider),
                ),
                loading: () => const DoctorListSkeleton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Filter bar: specialty chips + city picker
// -----------------------------------------------------------------------------

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filters});

  final DoctorQuery filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialties = ref.watch(specialtiesProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: specialties.maybeWhen(
            data: (items) => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final specialty = items[index];
                final selected = filters.specialtyId == specialty.id;
                return Semantics(
                  label:
                      'Filter by ${specialty.name}, ${specialty.doctorCount} providers',
                  button: true,
                  child: FilterChip(
                    selected: selected,
                    label: Text(specialty.name),
                    onSelected: (_) => ref
                        .read(doctorFiltersProvider.notifier)
                        .setSpecialty(selected ? null : specialty.id),
                  ),
                );
              },
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(child: _CityPicker(selected: filters.city)),
              const Spacer(),
              _ResultCount(filters: filters),
            ],
          ),
        ),
      ],
    );
  }
}

class _CityPicker extends ConsumerWidget {
  const _CityPicker({required this.selected});

  final String? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(citiesProvider);
    final theme = Theme.of(context);

    return Semantics(
      label: selected == null
          ? 'Filter by city, all cities selected'
          : 'Filter by city, $selected selected',
      button: true,
      child: PopupMenuButton<String?>(
        tooltip: 'Choose city',
        initialValue: selected,
        onSelected: (city) => ref
            .read(doctorFiltersProvider.notifier)
            .setCity(city == selected ? null : city),
        itemBuilder: (context) => [
          const PopupMenuItem(value: null, child: Text('All cities')),
          ...cities.maybeWhen(
            data: (items) => [
              for (final city in items)
                PopupMenuItem(value: city, child: Text(city)),
            ],
            orElse: () => const <PopupMenuEntry<String?>>[],
          ),
        ],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                selected ?? 'All cities',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCount extends ConsumerWidget {
  const _ResultCount({required this.filters});

  final DoctorQuery filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctors = ref.watch(doctorsProvider);
    final theme = Theme.of(context);
    final count = doctors.value?.totalCount;
    if (count == null) return const SizedBox.shrink();
    return Text(
      '$count found',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// The list itself
// -----------------------------------------------------------------------------

class _DoctorList extends ConsumerWidget {
  const _DoctorList({required this.state, required this.searchController});

  final DoctorsState state;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.doctors.isEmpty) {
      return AppEmptyView(
        icon: Icons.manage_search,
        title: 'No providers found',
        message: state.query.search.isEmpty && state.query.specialtyId == null
            ? 'No providers are available right now. Pull to refresh.'
            : 'Try a different search, specialty or city.',
        actionLabel: 'Clear filters',
        onAction: () {
          searchController.clear();
          ref.read(doctorFiltersProvider.notifier).clearFilters();
        },
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Trigger the next page before the user reaches the very bottom.
        if (notification.metrics.pixels >
            notification.metrics.maxScrollExtent - 320) {
          ref.read(doctorsProvider.notifier).loadNextPage();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => ref.read(doctorsProvider.notifier).refresh(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: state.doctors.length + 1, // + footer
          itemBuilder: (context, index) {
            if (index < state.doctors.length) {
              final doctor = state.doctors[index];
              return DoctorCard(
                doctor: doctor,
                onTap: () => context.go('/doctors/${doctor.id}'),
              );
            }
            return _LoadMoreFooter(state: state);
          },
        ),
      ),
    );
  }
}

class _LoadMoreFooter extends ConsumerWidget {
  const _LoadMoreFooter({required this.state});

  final DoctorsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              state.loadMoreError!.userMessage,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            TextButton.icon(
              onPressed: () =>
                  ref.read(doctorsProvider.notifier).loadNextPage(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state.loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }
    if (!state.hasMore) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'You reached the end',
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
