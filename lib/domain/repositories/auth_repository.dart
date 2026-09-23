import '../entities/app_user.dart';
import '../entities/auth_session.dart';

/// Authentication contract used by the presentation layer.
///
/// The implementation talks to the API (and secure local storage for token
/// persistence). Tests replace it with fakes through Riverpod overrides.
abstract interface class AuthRepository {
  /// Signs in with [email] and [password]; returns the issued session.
  ///
  /// Throws [AppException] subtypes on failure — never raw HTTP errors.
  Future<AuthSession> login({required String email, required String password});

  /// Creates an account and signs the user in.
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  /// Returns the currently stored session, or `null` when signed out.
  Future<AuthSession?> restoreSession();

  /// Re-reads the profile from the API; `null` when the session expired.
  Future<AppUser?> currentUser();

  /// Signs out remotely (invalidates the token) and clears local storage.
  Future<void> logout();

  /// Clears the local session without a network round-trip — used when the
  /// API already reported an expired token (401).
  Future<void> discardLocalSession();
}
