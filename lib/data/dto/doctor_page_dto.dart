import 'package:json_annotation/json_annotation.dart';

import 'doctor_dto.dart';

part 'doctor_page_dto.g.dart';

/// Paginated envelope for `GET /doctors`.
@JsonSerializable()
class DoctorPageDto {
  DoctorPageDto({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory DoctorPageDto.fromJson(Map<String, dynamic> json) =>
      _$DoctorPageDtoFromJson(json);

  final List<DoctorDto> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  Map<String, dynamic> toJson() => _$DoctorPageDtoToJson(this);
}
