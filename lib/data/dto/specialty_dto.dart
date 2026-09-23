import 'package:json_annotation/json_annotation.dart';

part 'specialty_dto.g.dart';

/// Wire representation of a medical specialty.
@JsonSerializable()
class SpecialtyDto {
  SpecialtyDto({
    required this.id,
    required this.name,
    required this.doctorCount,
  });

  factory SpecialtyDto.fromJson(Map<String, dynamic> json) =>
      _$SpecialtyDtoFromJson(json);

  final String id;
  final String name;
  final int doctorCount;

  Map<String, dynamic> toJson() => _$SpecialtyDtoToJson(this);
}
