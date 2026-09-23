// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionDto _$SessionDtoFromJson(Map<String, dynamic> json) => SessionDto(
  day: json['day'] as String,
  from: json['from'] as String,
  to: json['to'] as String,
);

Map<String, dynamic> _$SessionDtoToJson(SessionDto instance) =>
    <String, dynamic>{
      'day': instance.day,
      'from': instance.from,
      'to': instance.to,
    };

DoctorDto _$DoctorDtoFromJson(Map<String, dynamic> json) => DoctorDto(
  id: json['id'] as String,
  name: json['name'] as String,
  specialtyId: json['specialtyId'] as String,
  specialtyName: json['specialtyName'] as String,
  city: json['city'] as String,
  address: json['address'] as String,
  rating: (json['rating'] as num).toDouble(),
  reviewCount: (json['reviewCount'] as num).toInt(),
  experienceYears: (json['experienceYears'] as num).toInt(),
  consultationFee: (json['consultationFee'] as num).toDouble(),
  languages: (json['languages'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  education: (json['education'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  bio: json['bio'] as String,
  photoUrl: json['photoUrl'] as String,
  nextAvailableAt: json['nextAvailableAt'] == null
      ? null
      : DateTime.parse(json['nextAvailableAt'] as String),
  isAcceptingNewPatients: json['isAcceptingNewPatients'] as bool,
  sessions: (json['sessions'] as List<dynamic>?)
      ?.map((e) => SessionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DoctorDtoToJson(DoctorDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'specialtyId': instance.specialtyId,
  'specialtyName': instance.specialtyName,
  'city': instance.city,
  'address': instance.address,
  'rating': instance.rating,
  'reviewCount': instance.reviewCount,
  'experienceYears': instance.experienceYears,
  'consultationFee': instance.consultationFee,
  'languages': instance.languages,
  'education': instance.education,
  'bio': instance.bio,
  'photoUrl': instance.photoUrl,
  'nextAvailableAt': instance.nextAvailableAt?.toIso8601String(),
  'isAcceptingNewPatients': instance.isAcceptingNewPatients,
  'sessions': instance.sessions,
};
