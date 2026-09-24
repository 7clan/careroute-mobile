import 'package:flutter_test/flutter_test.dart';

import 'package:careroute_mobile/core/errors/app_exception.dart';
import 'package:careroute_mobile/core/network/mock_backend/backend_conditions.dart';
import 'package:careroute_mobile/data/repositories/doctor_repository_impl.dart';
import 'package:careroute_mobile/domain/entities/doctor_query.dart';

import '../helpers/test_container.dart';

void main() {
  DoctorRepositoryImpl createRepository(BackendConditions conditions) {
    return DoctorRepositoryImpl(dio: createTestDio(conditions: conditions));
  }

  group('DoctorRepositoryImpl', () {
    late DoctorRepositoryImpl repository;

    setUp(() {
      repository = createRepository(
        const BackendConditions(latency: Duration.zero),
      );
    });

    test('fetches the first page with pagination metadata', () async {
      final page = await repository.fetchDoctors(const DoctorQuery());
      expect(page.items, hasLength(10));
      expect(page.totalCount, 72);
      expect(page.totalPages, 8);
      expect(page.hasMore, isTrue);
      // Ratings sorted descending by default.
      final ratings = page.items.map((doctor) => doctor.rating).toList();
      expect(ratings, equals([...ratings]..sort((a, b) => b.compareTo(a))));
    });

    test('the last page has no more items', () async {
      final page = await repository.fetchDoctors(const DoctorQuery(page: 8));
      expect(page.items, hasLength(2));
      expect(page.hasMore, isFalse);
    });

    test('search narrows results across name, specialty and city', () async {
      final page = await repository.fetchDoctors(
        const DoctorQuery(search: 'cardiology'),
      );
      expect(page.totalCount, 6);
      expect(
        page.items.every(
          (doctor) => doctor.specialtyName.toLowerCase().contains('cardiol'),
        ),
        isTrue,
      );
    });

    test('specialty and city filters compose', () async {
      final page = await repository.fetchDoctors(
        const DoctorQuery(specialtyId: 'dermatology'),
      );
      expect(
        page.items.every((doctor) => doctor.specialtyId == 'dermatology'),
        isTrue,
      );
      expect(page.totalCount, 6);
    });

    test('fetchDoctorDetail returns sessions; unknown ids throw 404', () async {
      final detail = await repository.fetchDoctorDetail('d1');
      expect(detail.sessions, isNotEmpty);
      expect(detail.bio, isNotEmpty);

      await expectLater(
        () => repository.fetchDoctorDetail('does-not-exist'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test(
      'fetchAvailability returns bookable days with 30-minute slots',
      () async {
        final days = await repository.fetchAvailability('d1', days: 21);
        expect(days, isNotEmpty);
        for (final day in days) {
          expect(day.slots, isNotEmpty);
          for (final slot in day.slots) {
            expect(int.parse(slot.split(':')[1]) % 30, 0);
          }
        }
      },
    );

    test('fetchDoctorsByIds returns the exact providers', () async {
      final doctors = await repository.fetchDoctorsByIds(['d2', 'd9']);
      expect(doctors.map((doctor) => doctor.id), unorderedEquals(['d2', 'd9']));
      expect(await repository.fetchDoctorsByIds([]), isEmpty);
    });

    test('fetchSpecialties and fetchCities return filter options', () async {
      final specialties = await repository.fetchSpecialties();
      expect(specialties, hasLength(12));
      expect(specialties.first.doctorCount, 6);

      final cities = await repository.fetchCities();
      expect(cities.toSet().length, cities.length);
    });

    test('offline conditions surface as NoNetworkException', () async {
      final offline = createRepository(
        const BackendConditions(latency: Duration.zero, offline: true),
      );
      await expectLater(
        () => offline.fetchDoctors(const DoctorQuery()),
        throwsA(isA<NoNetworkException>()),
      );
    });

    test('forced 500 surfaces as ServerException', () async {
      final failing = createRepository(
        const BackendConditions(latency: Duration.zero, forceStatus: 500),
      );
      await expectLater(
        () => failing.fetchSpecialties(),
        throwsA(isA<ServerException>()),
      );
    });

    test('malformed responses surface as ParsingException', () async {
      final malformed = createRepository(
        const BackendConditions(
          latency: Duration.zero,
          malformedResponse: true,
        ),
      );
      await expectLater(
        () => malformed.fetchDoctors(const DoctorQuery()),
        throwsA(isA<ParsingException>()),
      );
    });

    test('hanging requests surface as TimeoutException', () async {
      // Short Dio timeouts: the hanging adapter outlives them.
      final repository = DoctorRepositoryImpl(
        dio: createTestDio(
          conditions: const BackendConditions(
            latency: Duration.zero,
            timeoutAfter: Duration(seconds: 2),
          ),
          timeout: const Duration(milliseconds: 150),
        ),
      );
      await expectLater(
        () => repository.fetchDoctors(const DoctorQuery()),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
