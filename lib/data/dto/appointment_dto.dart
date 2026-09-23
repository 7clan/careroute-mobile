import 'package:json_annotation/json_annotation.dart';

part 'appointment_dto.g.dart';

/// Wire representation of an appointment request.
@JsonSerializable()
class AppointmentDto {
  AppointmentDto({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialtyName,
    required this.date,
    required this.time,
    this.reason,
    required this.status,
    required this.createdAt,
  });

  factory AppointmentDto.fromJson(Map<String, dynamic> json) =>
      _$AppointmentDtoFromJson(json);

  final String id;
  final String doctorId;
  final String doctorName;
  final String specialtyName;

  /// `YYYY-MM-DD` date key.
  final String date;

  /// `HH:mm` 24-hour clock.
  final String time;
  final String? reason;

  /// `pending`, `confirmed` or `cancelled`.
  final String status;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$AppointmentDtoToJson(this);
}
