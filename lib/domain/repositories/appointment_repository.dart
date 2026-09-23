import '../entities/appointment.dart';

/// Appointment request contract used by the presentation layer.
abstract interface class AppointmentRepository {
  /// Lists the signed-in user's appointments (newest first).
  Future<List<Appointment>> fetchAppointments();

  /// Requests a new appointment. Validation failures (past date, slot not
  /// offered, missing fields) surface as [ValidationException].
  Future<Appointment> requestAppointment({
    required String doctorId,
    required DateTime date,
    required String time,
    String? reason,
  });

  /// Cancels an appointment by [id].
  Future<Appointment> cancelAppointment(String id);
}
