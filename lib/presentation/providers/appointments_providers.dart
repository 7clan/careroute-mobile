import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/appointment.dart';
import 'infrastructure_providers.dart';

/// All appointments of the signed-in user (newest first).
final appointmentsProvider =
    AsyncNotifierProvider<AppointmentsController, List<Appointment>>(
      AppointmentsController.new,
    );

class AppointmentsController extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() =>
      ref.watch(appointmentRepositoryProvider).fetchAppointments();

  Future<Appointment> request({
    required String doctorId,
    required DateTime date,
    required String time,
    String? reason,
  }) async {
    final repository = ref.read(appointmentRepositoryProvider);
    final appointment = await repository.requestAppointment(
      doctorId: doctorId,
      date: date,
      time: time,
      reason: reason,
    );
    final current = state.value ?? const <Appointment>[];
    // Insert locally so the appointments screen reflects it instantly.
    state = AsyncData([appointment, ...current]);
    return appointment;
  }

  Future<Appointment> cancel(String id) async {
    final repository = ref.read(appointmentRepositoryProvider);
    final updated = await repository.cancelAppointment(id);
    final current = state.value ?? const <Appointment>[];
    state = AsyncData([
      for (final appointment in current)
        appointment.id == updated.id ? updated : appointment,
    ]);
    return updated;
  }

  /// Pull-to-refresh.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Derived state: appointments that are still relevant (future or today,
/// not cancelled) — the "upcoming" section of the appointments screen.
final upcomingAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final appointments = ref.watch(appointmentsProvider).value ?? const [];
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  return [
    for (final appointment in appointments)
      if (appointment.status != AppointmentStatus.cancelled &&
          !appointment.date.isBefore(startOfDay))
        appointment,
  ];
});
