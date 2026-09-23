import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/auth_session.dart';
import '../dto/user_dto.dart';
import '../mappers/user_mapper.dart';

/// Persistence seam for the authenticated session.
///
/// Production stores the session in [FlutterSecureStorage] (Keychain /
/// EncryptedSharedPreferences). Tests inject
/// [InMemoryAuthLocalDataSource] through a Riverpod override — the
/// repositories never know the difference.
abstract interface class AuthLocalDataSource {
  Future<void> save(AuthSession session);
  Future<AuthSession?> read();
  Future<void> clear();
}

class SecureAuthLocalDataSource implements AuthLocalDataSource {
  SecureAuthLocalDataSource({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _storageKey = 'careroute.session';

  final FlutterSecureStorage _storage;
  // Secure-storage reads are slow; cache the decoded session in memory.
  AuthSession? _cached;

  @override
  Future<void> save(AuthSession session) async {
    _cached = session;
    final userDto = UserDto(
      id: session.user.id,
      name: session.user.name,
      email: session.user.email,
      phone: session.user.phone,
      memberSince: session.user.memberSince,
    );
    await _storage.write(
      key: _storageKey,
      value: jsonEncode({
        'token': session.token,
        'expiresAt': session.expiresAt.toIso8601String(),
        'user': userDto.toJson(),
      }),
    );
  }

  @override
  Future<AuthSession?> read() async {
    if (_cached != null) return _cached;
    final raw = await _storage.read(key: _storageKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final session = AuthSession(
        token: decoded['token'] as String,
        expiresAt: DateTime.parse(decoded['expiresAt'] as String),
        user: UserDto.fromJson(decoded['user'] as Map<String, dynamic>)
            .toDomain(),
      );
      _cached = session;
      return session;
    } on FormatException {
      // Corrupt storage is treated as "signed out" — never crash on it.
      await clear();
      return null;
    } on TypeError {
      await clear();
      return null;
    }
  }

  @override
  Future<void> clear() {
    _cached = null;
    return _storage.delete(key: _storageKey);
  }
}

class InMemoryAuthLocalDataSource implements AuthLocalDataSource {
  AuthSession? _session;

  @override
  Future<void> save(AuthSession session) async => _session = session;

  @override
  Future<AuthSession?> read() async => _session;

  @override
  Future<void> clear() async => _session = null;
}
