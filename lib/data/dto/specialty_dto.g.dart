// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'specialty_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpecialtyDto _$SpecialtyDtoFromJson(Map<String, dynamic> json) => SpecialtyDto(
  id: json['id'] as String,
  name: json['name'] as String,
  doctorCount: (json['doctorCount'] as num).toInt(),
);

Map<String, dynamic> _$SpecialtyDtoToJson(SpecialtyDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'doctorCount': instance.doctorCount,
    };
