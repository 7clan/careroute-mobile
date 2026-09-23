import 'dart:async';

/// Bridges the networking layer to app-level session state without
/// creating a dependency cycle (Dio → session controller → repository →
/// Dio is impossible; instead the interceptor emits an event and the
/// session controller subscribes).
class SessionEvents {
  final _sessionExpired = StreamController<void>.broadcast();

  /// Fired when a protected endpoint answers 401 while a token was sent.
  Stream<void> get sessionExpired => _sessionExpired.stream;

  void notifySessionExpired() => _sessionExpired.add(null);

  void dispose() => _sessionExpired.close();
}
