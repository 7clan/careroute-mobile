// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_page_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoctorPageDto _$DoctorPageDtoFromJson(Map<String, dynamic> json) =>
    DoctorPageDto(
      items: (json['items'] as List<dynamic>)
          .map((e) => DoctorDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalCount: (json['totalCount'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$DoctorPageDtoToJson(DoctorPageDto instance) =>
    <String, dynamic>{
      'items': instance.items,
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalCount': instance.totalCount,
      'totalPages': instance.totalPages,
    };
