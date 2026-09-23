import '../../domain/entities/appointment.dart';
import '../dto/appointment_dto.dart';

extension AppointmentDtoMapper on AppointmentDto {
  Appointment toDomain() => Appointment(
    id: id,
    doctorId: doctorId,
    doctorName: doctorName,
    specialtyName: specialtyName,
    date: DateTime.parse(date),
    time: time,
    reason: reason,
    status: switch (status) {
      'confirmed' => AppointmentStatus.confirmed,
      'cancelled' => AppointmentStatus.cancelled,
      _ => AppointmentStatus.pending,
    },
    createdAt: createdAt,
  );
}
