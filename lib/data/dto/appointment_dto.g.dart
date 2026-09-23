// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentDto _$AppointmentDtoFromJson(Map<String, dynamic> json) =>
    AppointmentDto(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      specialtyName: json['specialtyName'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      reason: json['reason'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AppointmentDtoToJson(AppointmentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doctorId': instance.doctorId,
      'doctorName': instance.doctorName,
      'specialtyName': instance.specialtyName,
      'date': instance.date,
      'time': instance.time,
      'reason': instance.reason,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
    };
