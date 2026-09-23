import 'package:freezed_annotation/freezed_annotation.dart';

import 'app_user.dart';

part 'auth_session.freezed.dart';

/// An authenticated session: who is signed in and until when the token
/// is accepted by the API.
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required AppUser user,
    required String token,
    required DateTime expiresAt,
  }) = _AuthSession;

  const AuthSession._();

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
