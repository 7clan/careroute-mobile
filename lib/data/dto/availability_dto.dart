import 'package:json_annotation/json_annotation.dart';

part 'availability_dto.g.dart';

/// Wire representation of one bookable calendar day.
@JsonSerializable()
class AvailabilityDayDto {
  AvailabilityDayDto({required this.date, required this.slots});

  factory AvailabilityDayDto.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityDayDtoFromJson(json);

  /// `YYYY-MM-DD` date key.
  final String date;
  final List<String> slots;

  Map<String, dynamic> toJson() => _$AvailabilityDayDtoToJson(this);
}

/// Response of `GET /doctors/{id}/availability`.
@JsonSerializable()
class AvailabilityResponseDto {
  AvailabilityResponseDto({required this.doctorId, required this.days});

  factory AvailabilityResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityResponseDtoFromJson(json);

  final String doctorId;
  final List<AvailabilityDayDto> days;

  Map<String, dynamic> toJson() => _$AvailabilityResponseDtoToJson(this);
}
