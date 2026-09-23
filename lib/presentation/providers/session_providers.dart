import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/auth_session.dart';
import 'infrastructure_providers.dart';

/// One-shot notices for the auth flow ("session expired"), consumed by the
/// login screen as a banner.
final authNoticeProvider = NotifierProvider<AuthNoticeController, String?>(
  AuthNoticeController.new,
);

class AuthNoticeController extends Notifier<String?> {
  @override
  String? build() => null;

  void show(String message) => state = message;

  void clear() => state = null;
}

/// App-wide authentication state.
///
/// `null` means signed out. The state is an [AsyncValue]: `loading` while
/// restoring/submitting, `error` only for boot-blocking failures (e.g. no
/// network while verifying a stored token) — form-level failures are thrown
/// to the caller instead so screens can show inline errors.
final sessionProvider = AsyncNotifierProvider<SessionController, AuthSession?>(
  SessionController.new,
);

class SessionController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() {
    final repository = ref.watch(authRepositoryProvider);

    // A 401 anywhere in the app expires the session: clear local state and
    // let the router send the user back to the login screen.
    final events = ref.watch(sessionEventsProvider);
    final subscription = events.sessionExpired.listen((_) async {
      await repository.discardLocalSession();
      state = const AsyncData(null);
      ref
          .read(authNoticeProvider.notifier)
          .show('Your session has expired. Please sign in again.');
    });
    ref.onDispose(subscription.cancel);

    return repository.restoreSession();
  }

  Future<void> login({required String email, required String password}) async {
    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    try {
      final session = await repository.login(email: email, password: password);
      state = AsyncData(session);
    } catch (_) {
      state = const AsyncData(null);
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    try {
      final session = await repository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = AsyncData(session);
    } catch (_) {
      state = const AsyncData(null);
      rethrow;
    }
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    try {
      // Always clears local state — even when the network call fails.
      await repository.logout();
    } on AppException {
      // Signed out locally regardless; the token was best-effort revoked.
    } finally {
      state = const AsyncData(null);
    }
  }
}
