import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../dto/auth_response_dto.dart';
import '../dto/user_dto.dart';

extension UserDtoMapper on UserDto {
  AppUser toDomain() => AppUser(
    id: id,
    name: name,
    email: email,
    phone: phone,
    memberSince: memberSince,
  );
}

extension AuthResponseDtoMapper on AuthResponseDto {
  AuthSession toDomain() =>
      AuthSession(token: token, expiresAt: expiresAt, user: user.toDomain());
}
