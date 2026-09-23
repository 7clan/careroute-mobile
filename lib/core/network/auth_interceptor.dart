import 'package:dio/dio.dart';

import 'session_events.dart';

/// Injects the bearer token into every request and reports session expiry
/// (401 with a token present) through [SessionEvents].
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokenReader, required this.sessionEvents});

  final Future<String?> Function() tokenReader;
  final SessionEvents sessionEvents;

  static const _authEndpoints = <String>{'auth/login', 'auth/register'};

  bool _isAuthEndpoint(String path) =>
      _authEndpoints.any((endpoint) => path.contains(endpoint));

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    tokenReader()
        .then((token) {
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        })
        .catchError((Object error) {
          // Token lookup must never break traffic — continue anonymously.
          handler.next(options);
        });
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final hadToken = err.requestOptions.headers['Authorization'] != null;
    final isAuthEndpoint = _isAuthEndpoint(err.requestOptions.path);

    if (status == 401 && hadToken && !isAuthEndpoint) {
      // A previously valid token is now rejected → the session expired.
      // Emit instead of logging out here to avoid repository cycles.
      sessionEvents.notifySessionExpired();
    }
    handler.next(err);
  }
}
