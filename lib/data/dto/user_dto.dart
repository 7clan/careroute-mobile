import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

/// Wire representation of a CareRoute user.
@JsonSerializable()
class UserDto {
  UserDto({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.memberSince,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  final String id;
  final String name;
  final String email;
  final String? phone;
  final DateTime memberSince;

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}
