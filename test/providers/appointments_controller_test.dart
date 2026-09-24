import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careroute_mobile/core/errors/app_exception.dart';
import 'package:careroute_mobile/core/network/mock_backend/mock_database.dart';
import 'package:careroute_mobile/domain/entities/appointment.dart';
import 'package:careroute_mobile/presentation/providers/appointments_providers.dart';
import 'package:careroute_mobile/presentation/providers/infrastructure_providers.dart';
import 'package:careroute_mobile/presentation/providers/session_providers.dart';

import '../helpers/test_container.dart';

/// Appointments are a protected resource: sign the demo user in first so
/// the auth interceptor actually attaches a token.
Future<ProviderContainer> createSignedInContainer() async {
  final container = createTestContainer();
  await container
      .read(sessionProvider.notifier)
      .login(
        email: MockDatabase.demoEmail,
        password: MockDatabase.demoPassword,
      );
  return container;
}

void main() {
  group('AppointmentsController', () {
    test('starts empty for a fresh demo user', () async {
      final container = await createSignedInContainer();
      final appointments = await container.read(appointmentsProvider.future);
      expect(appointments, isEmpty);
    });

    test('request() inserts the new appointment at the top', () async {
      final container = await createSignedInContainer();
      await container.read(appointmentsProvider.future);

      // Use the first bookable day of doctor d1 via the availability API.
      final repository = container.read(doctorRepositoryProvider);
      final days = await repository.fetchAvailability('d1', days: 7);

      final created = await container
          .read(appointmentsProvider.notifier)
          .request(
            doctorId: 'd1',
            date: days.first.date,
            time: days.first.slots.first,
            reason: 'Persistent cough',
          );

      expect(created.status, AppointmentStatus.pending);
      final appointments = container.read(appointmentsProvider).value!;
      expect(appointments, hasLength(1));
      expect(appointments.first.id, created.id);
    });

    test('cancel() updates the status in place', () async {
      final container = await createSignedInContainer();
      await container.read(appointmentsProvider.future);

      final repository = container.read(doctorRepositoryProvider);
      final days = await repository.fetchAvailability('d1', days: 7);
      final created = await container
          .read(appointmentsProvider.notifier)
          .request(
            doctorId: 'd1',
            date: days.first.date,
            time: days.first.slots.first,
          );

      final cancelled = await container
          .read(appointmentsProvider.notifier)
          .cancel(created.id);

      expect(cancelled.status, AppointmentStatus.cancelled);
      final appointments = container.read(appointmentsProvider).value!;
      expect(appointments, hasLength(1));
      expect(appointments.first.status, AppointmentStatus.cancelled);
    });

    test('duplicate slot requests fail with validation errors', () async {
      final container = await createSignedInContainer();
      await container.read(appointmentsProvider.future);

      final repository = container.read(doctorRepositoryProvider);
      final days = await repository.fetchAvailability('d1', days: 7);

      Future<Appointment> requestAgain() => container
          .read(appointmentsProvider.notifier)
          .request(
            doctorId: 'd1',
            date: days.first.date,
            time: days.first.slots.first,
          );

      await requestAgain();
      await expectLater(
        () => requestAgain(),
        throwsA(isA<ValidationException>()),
      );
    });

    test('refresh() re-reads from the API', () async {
      final container = await createSignedInContainer();
      await container.read(appointmentsProvider.future);

      // Request one appointment through the controller, then refresh.
      final repository = container.read(doctorRepositoryProvider);
      final days = await repository.fetchAvailability('d1', days: 7);
      await container
          .read(appointmentsProvider.notifier)
          .request(
            doctorId: 'd1',
            date: days.first.date,
            time: days.first.slots.first,
          );

      await container.read(appointmentsProvider.notifier).refresh();
      expect(container.read(appointmentsProvider).value, isNotEmpty);
    });

    test(
      'upcomingAppointmentsProvider excludes cancelled & past items',
      () async {
        final container = await createSignedInContainer();
        await container.read(appointmentsProvider.future);

        final repository = container.read(doctorRepositoryProvider);
        final days = await repository.fetchAvailability('d1', days: 14);
        // Take the last bookable day and cancel it: it must drop out.
        final day = days.last;
        final created = await container
            .read(appointmentsProvider.notifier)
            .request(doctorId: 'd1', date: day.date, time: day.slots.first);
        await container.read(appointmentsProvider.notifier).cancel(created.id);

        expect(container.read(upcomingAppointmentsProvider), isEmpty);
      },
    );
  });
}
