import 'package:json_annotation/json_annotation.dart';

part 'doctor_dto.g.dart';

/// One weekly session block of a provider (detail responses only).
@JsonSerializable()
class SessionDto {
  SessionDto({required this.day, required this.from, required this.to});

  factory SessionDto.fromJson(Map<String, dynamic> json) =>
      _$SessionDtoFromJson(json);

  /// Weekday name, e.g. `Monday`.
  final String day;
  final String from;
  final String to;

  Map<String, dynamic> toJson() => _$SessionDtoToJson(this);
}

/// Wire representation of a healthcare provider.
///
/// List responses omit [sessions]; detail responses include them.
@JsonSerializable()
class DoctorDto {
  DoctorDto({
    required this.id,
    required this.name,
    required this.specialtyId,
    required this.specialtyName,
    required this.city,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.experienceYears,
    required this.consultationFee,
    required this.languages,
    required this.education,
    required this.bio,
    required this.photoUrl,
    this.nextAvailableAt,
    required this.isAcceptingNewPatients,
    this.sessions,
  });

  factory DoctorDto.fromJson(Map<String, dynamic> json) =>
      _$DoctorDtoFromJson(json);

  final String id;
  final String name;
  final String specialtyId;
  final String specialtyName;
  final String city;
  final String address;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final double consultationFee;
  final List<String> languages;
  final List<String> education;
  final String bio;
  final String photoUrl;
  final DateTime? nextAvailableAt;
  final bool isAcceptingNewPatients;
  final List<SessionDto>? sessions;

  Map<String, dynamic> toJson() => _$DoctorDtoToJson(this);
}
