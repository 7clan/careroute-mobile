// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailabilityDayDto _$AvailabilityDayDtoFromJson(Map<String, dynamic> json) =>
    AvailabilityDayDto(
      date: json['date'] as String,
      slots: (json['slots'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$AvailabilityDayDtoToJson(AvailabilityDayDto instance) =>
    <String, dynamic>{'date': instance.date, 'slots': instance.slots};

AvailabilityResponseDto _$AvailabilityResponseDtoFromJson(
  Map<String, dynamic> json,
) => AvailabilityResponseDto(
  doctorId: json['doctorId'] as String,
  days: (json['days'] as List<dynamic>)
      .map((e) => AvailabilityDayDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AvailabilityResponseDtoToJson(
  AvailabilityResponseDto instance,
) => <String, dynamic>{'doctorId': instance.doctorId, 'days': instance.days};
