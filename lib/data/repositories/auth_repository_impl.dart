import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../dto/auth_response_dto.dart';
import '../dto/user_dto.dart';
import '../mappers/user_mapper.dart';

/// Talks to the auth endpoints and persists the session locally.
///
/// Every network failure is converted into an [AppException] before it can
/// reach the presentation layer.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.dio, required this.local});

  final Dio dio;
  final AuthLocalDataSource local;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      throw DioExceptionMapper.map(error, stackTrace: stackTrace);
    }
  }

  @override
  Future<AuthSession> login({required String email, required String password}) {
    return _guard(() async {
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final session = AuthResponseDto.fromJson(response.data!).toDomain();
      await local.save(session);
      return session;
    });
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _guard(() async {
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'passwordConfirmation': passwordConfirmation,
        },
      );
      final session = AuthResponseDto.fromJson(response.data!).toDomain();
      await local.save(session);
      return session;
    });
  }

  @override
  Future<AuthSession?> restoreSession() {
    return _guard(() async {
      final stored = await local.read();
      if (stored == null) return null;
      if (stored.isExpired) {
        await local.clear();
        return null;
      }
      // Verify the token is still accepted server-side.
      try {
        final user = await _verifyToken();
        return AuthSession(
          token: stored.token,
          expiresAt: stored.expiresAt,
          user: user,
        );
      } on UnauthorizedException {
        await local.clear();
        return null;
      }
    });
  }

  Future<AppUser> _verifyToken() async {
    final response = await dio.get<Map<String, dynamic>>('/auth/me');
    final userJson = response.data!['user'] as Map<String, dynamic>;
    return UserDto.fromJson(userJson).toDomain();
  }

  @override
  Future<AppUser?> currentUser() {
    return _guard(() async {
      final stored = await local.read();
      if (stored == null) return null;
      try {
        return await _verifyToken();
      } on UnauthorizedException {
        return null;
      }
    });
  }

  @override
  Future<void> logout() async {
    // Best effort remote logout — the local session is always cleared so a
    // failed network call can never keep the user signed in.
    await _guard(() => dio.post<void>('/auth/logout'));
    await local.clear();
  }

  /// Clears the local session without a network round-trip — used when the
  /// API already reported an expired token.
  @override
  Future<void> discardLocalSession() => local.clear();
}
