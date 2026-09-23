import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'backend_conditions.dart';
import 'mock_database.dart';
import 'mock_http_error.dart';

/// Dio [HttpClientAdapter] that serves the [MockDatabase].
///
/// Why this shape? The app must demonstrate *real* REST integration:
/// request serialization, interceptors, status codes, headers, JSON
/// decoding, timeouts and cancellation. Pointing Dio at an in-process
/// database keeps that entire pipeline intact while the repository layer
/// stays oblivious — swapping this adapter for a real backend is a
/// one-line change in `network_providers.dart`.
///
/// Failure modes are driven by [BackendConditions], which the Profile tab
/// exposes as an "API condition simulator".
class MockBackendAdapter implements HttpClientAdapter {
  MockBackendAdapter({required this.readConditions, MockDatabase? database})
    : _database = database ?? MockDatabase.seeded();

  final BackendConditions Function() readConditions;
  final MockDatabase _database;
  bool _closed = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    // Honour Dio cancellation: resolve the returned future with a cancel
    // error so callers see the same behaviour as with a real socket.
    final pending = Completer<ResponseBody>();
    cancelFuture?.then((_) {
      if (!pending.isCompleted) {
        pending.completeError(
          DioException.requestCancelled(
            requestOptions: options,
            reason: 'Request was cancelled (mock backend).',
          ),
        );
      }
    });

    _execute(options).then(
      pending.complete,
      onError: (Object error, StackTrace stack) {
        if (!pending.isCompleted) pending.completeError(error, stack);
      },
    );
    return pending.future;
  }

  Future<ResponseBody> _execute(RequestOptions options) async {
    if (_closed) {
      throw StateError('MockBackendAdapter was closed.');
    }
    final conditions = readConditions();

    // 1. Simulated connectivity loss — mirrors a socket-level failure.
    if (conditions.offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'Simulated offline mode: no route to host.',
      );
    }

    // 2. Latency — every real request has a round-trip cost.
    if (conditions.latency > Duration.zero) {
      await Future<void>.delayed(conditions.latency);
    }

    // 3. Simulated hang — longer than the configured Dio timeouts.
    if (conditions.timeoutAfter != null) {
      await Future<void>.delayed(conditions.timeoutAfter!);
    }

    // 4. Forced status / malformed body — exercised by tests & simulator.
    if (conditions.forceStatus != null) {
      return _jsonResponse({
        'message': 'Simulated server error (${conditions.forceStatus}).',
      }, conditions.forceStatus!);
    }
    if (conditions.malformedResponse) {
      return ResponseBody.fromString(
        '{"message": "not-json', // Intentionally broken JSON.
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json; charset=utf-8'],
        },
      );
    }

    // 5. Delegate to the deterministic database.
    final query = <String, String>{
      for (final entry in options.queryParameters.entries)
        entry.key: entry.value.toString(),
    };
    final token = _bearerToken(options);
    try {
      final body = _database.handle(
        method: options.method,
        path: options.uri.path,
        query: query,
        body: _asJsonMap(options.data),
        token: token,
      );
      return _jsonResponse(body, 200);
    } on MockHttpError catch (error) {
      return _jsonResponse(error.body, error.statusCode);
    }
  }

  String? _bearerToken(RequestOptions options) {
    final header = options.headers['Authorization'];
    if (header is String && header.startsWith('Bearer ')) {
      return header.substring('Bearer '.length);
    }
    return null;
  }

  Map<String, dynamic>? _asJsonMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  ResponseBody _jsonResponse(Map<String, Object?> body, int status) {
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {
    _closed = true;
  }
}
