import 'package:json_annotation/json_annotation.dart';

import 'user_dto.dart';

part 'auth_response_dto.g.dart';

/// Response of `POST /auth/login` and `POST /auth/register`.
@JsonSerializable()
class AuthResponseDto {
  AuthResponseDto({
    required this.token,
    required this.tokenType,
    required this.expiresAt,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);

  final String token;
  final String tokenType;
  final DateTime expiresAt;
  final UserDto user;

  Map<String, dynamic> toJson() => _$AuthResponseDtoToJson(this);
}
