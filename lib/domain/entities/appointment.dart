import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment.freezed.dart';

/// Lifecycle of an appointment request.
enum AppointmentStatus { pending, confirmed, cancelled }

/// An appointment the signed-in user requested with a provider.
@freezed
abstract class Appointment with _$Appointment {
  const factory Appointment({
    required String id,
    required String doctorId,
    required String doctorName,
    required String specialtyName,
    required DateTime date,

    /// 24-hour clock label, e.g. `09:30`.
    required String time,

    /// Free-text reason supplied by the patient.
    String? reason,
    required AppointmentStatus status,
    required DateTime createdAt,
  }) = _Appointment;
}
