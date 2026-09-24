import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careroute_mobile/core/errors/app_exception.dart';
import 'package:careroute_mobile/core/network/mock_backend/backend_conditions.dart';
import 'package:careroute_mobile/domain/entities/doctor_query.dart';
import 'package:careroute_mobile/presentation/providers/doctors_providers.dart';
import 'package:careroute_mobile/presentation/providers/infrastructure_providers.dart';

import '../helpers/test_container.dart';

void main() {
  group('DoctorFiltersController', () {
    test('search commits only after the debounce window', () async {
      final container = createTestContainer();
      final controller = container.read(doctorFiltersProvider.notifier);

      controller.updateSearch('card');
      expect(
        container.read(doctorFiltersProvider).search,
        '',
        reason: 'must not commit mid-typing',
      );

      await Future<void>.delayed(const Duration(milliseconds: 450));
      expect(container.read(doctorFiltersProvider).search, 'card');
    });

    test('a second keystroke during the window cancels the first', () async {
      final container = createTestContainer();
      final controller = container.read(doctorFiltersProvider.notifier);

      controller.updateSearch('card');
      await Future<void>.delayed(const Duration(milliseconds: 150));
      controller.updateSearch('cardiology');

      await Future<void>.delayed(const Duration(milliseconds: 450));
      expect(container.read(doctorFiltersProvider).search, 'cardiology');
    });

    test('clearSearch commits immediately', () async {
      final container = createTestContainer();
      final controller = container.read(doctorFiltersProvider.notifier);

      controller.updateSearch('card');
      controller.clearSearch();

      // No debounce waiting: state is already clean.
      expect(container.read(doctorFiltersProvider).search, '');
      await Future<void>.delayed(const Duration(milliseconds: 450));
      expect(
        container.read(doctorFiltersProvider).search,
        '',
        reason: 'the cancelled keystroke must not resurrect',
      );
    });

    test('changing a filter resets pagination to page 1', () async {
      final container = createTestContainer();
      final controller = container.read(doctorFiltersProvider.notifier);

      controller.setSpecialty('cardiology');
      expect(container.read(doctorFiltersProvider).specialtyId, 'cardiology');
      expect(container.read(doctorFiltersProvider).page, 1);
    });

    test('clearFilters restores the default query', () async {
      final container = createTestContainer();
      final controller = container.read(doctorFiltersProvider.notifier);

      controller.setSpecialty('cardiology');
      controller.setCity('Beirut');
      controller.updateSearch('dr');
      await Future<void>.delayed(const Duration(milliseconds: 450));

      controller.clearFilters();
      expect(container.read(doctorFiltersProvider), const DoctorQuery());
    });
  });

  group('DoctorsController', () {
    test('loads the first page with hasMore', () async {
      final container = createTestContainer();
      final state = await container.read(doctorsProvider.future);

      expect(state.doctors, hasLength(10));
      expect(state.totalCount, 72);
      expect(state.hasMore, isTrue);
      expect(state.loadMoreError, isNull);
    });

    test('loadNextPage appends the next page', () async {
      final container = createTestContainer();

      await container.read(doctorsProvider.future);
      await container.read(doctorsProvider.notifier).loadNextPage();

      final state = container.read(doctorsProvider).value!;
      expect(state.doctors, hasLength(20));
      expect(state.query.page, 2);
      expect(state.loadingMore, isFalse);
    });

    test('reaching the end stops pagination', () async {
      final container = createTestContainer();

      // Jump straight to a tiny result set via search.
      final controller = container.read(doctorFiltersProvider.notifier);
      controller.updateSearch('zzz-no-match');
      await Future<void>.delayed(const Duration(milliseconds: 450));

      final state = await container.read(doctorsProvider.future);
      expect(state.doctors, isEmpty);
      expect(state.hasMore, isFalse);
      expect(state.totalCount, 0);
    });

    test('filter changes restart the feed from page 1', () async {
      final container = createTestContainer();

      await container.read(doctorsProvider.future);
      await container.read(doctorsProvider.notifier).loadNextPage();
      expect(container.read(doctorsProvider).value!.doctors, hasLength(20));

      container.read(doctorFiltersProvider.notifier).setSpecialty('cardiology');
      final state = await container.read(doctorsProvider.future);

      expect(state.doctors, hasLength(6));
      expect(state.totalCount, 6);
      expect(state.doctors.every((d) => d.specialtyId == 'cardiology'), isTrue);
    });

    test('load-more failure keeps the list and records the error', () async {
      final container = createTestContainer();
      await container.read(doctorsProvider.future);

      // Break the backend between page 1 and page 2.
      container
          .read(backendConditionsProvider.notifier)
          .setForceServerError(true);
      await container.read(doctorsProvider.notifier).loadNextPage();

      final state = container.read(doctorsProvider).value!;
      expect(state.doctors, hasLength(10), reason: 'list stays visible');
      expect(state.loadMoreError, isA<ServerException>());
      expect(state.loadingMore, isFalse);

      // Fixing the backend and retrying appends the page.
      container.read(backendConditionsProvider.notifier).reset();
      await container.read(doctorsProvider.notifier).loadNextPage();
      expect(
        container.read(doctorsProvider).value!.doctors,
        hasLength(20),
        reason: 'retry after fixing conditions appends the page',
      );
    });

    test('refresh() restarts from page 1', () async {
      final container = createTestContainer();
      await container.read(doctorsProvider.future);
      await container.read(doctorsProvider.notifier).loadNextPage();
      expect(container.read(doctorsProvider).value!.doctors, hasLength(20));

      await container.read(doctorsProvider.notifier).refresh();
      expect(container.read(doctorsProvider).value!.doctors, hasLength(10));
    });

    test('initial load failures surface as provider errors', () async {
      final container = createTestContainer(
        conditions: const BackendConditions(
          latency: Duration.zero,
          offline: true,
        ),
      );

      await expectLater(
        container.read(doctorsProvider.future),
        throwsA(isA<NoNetworkException>()),
      );
      expect(container.read(doctorsProvider), isA<AsyncError>());
    });
  });
}
