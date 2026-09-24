import 'package:flutter/foundation.dart';

/// Runtime conditions applied by [MockBackendAdapter].
///
/// CareRoute ships with a deterministic in-process API (see
/// `docs/API.md`). These toggles let a reviewer *experience* the app's
/// offline / timeout / server-error / malformed-response states without
/// touching infrastructure — the Profile tab exposes them as
/// "API condition simulator". They are honest about being simulated.
@immutable
class BackendConditions {
  const BackendConditions({
    this.offline = false,
    this.malformedResponse = false,
    this.forceStatus,
    this.latency = const Duration(milliseconds: 250),
    this.timeoutAfter,
  });

  /// Simulates "device has no connectivity".
  final bool offline;

  /// Answers 200 with a body that is *not* valid JSON.
  final bool malformedResponse;

  /// Forces every endpoint to answer with this HTTP status (e.g. 500).
  final int? forceStatus;

  /// Artificial per-request latency — makes loading states observable.
  final Duration latency;

  /// When non-null, responses never deliver data so the Dio timeouts
  /// (configured on `BaseOptions`) are what abort the request.
  final Duration? timeoutAfter;

  bool get isHealthy =>
      !offline &&
      !malformedResponse &&
      forceStatus == null &&
      timeoutAfter == null;

  /// Sentinel that lets [copyWith] distinguish "not provided" from
  /// "explicitly clear this field" for the nullable parameters.
  static const _unset = Object();

  BackendConditions copyWith({
    bool? offline,
    bool? malformedResponse,
    Object? forceStatus = _unset,
    Duration? latency,
    Object? timeoutAfter = _unset,
  }) {
    return BackendConditions(
      offline: offline ?? this.offline,
      malformedResponse: malformedResponse ?? this.malformedResponse,
      forceStatus: identical(forceStatus, _unset)
          ? this.forceStatus
          : forceStatus as int?,
      latency: latency ?? this.latency,
      timeoutAfter: identical(timeoutAfter, _unset)
          ? this.timeoutAfter
          : timeoutAfter as Duration?,
    );
  }
}
