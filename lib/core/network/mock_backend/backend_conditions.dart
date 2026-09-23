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

  /// When set, requests hang for this long so the Dio timeouts fire.
  final Duration? timeoutAfter;

  bool get isHealthy =>
      !offline &&
      !malformedResponse &&
      forceStatus == null &&
      timeoutAfter == null;

  BackendConditions copyWith({
    bool? offline,
    bool? malformedResponse,
    int? forceStatus,
    Duration? latency,
    Duration? timeoutAfter,
  }) {
    return BackendConditions(
      offline: offline ?? this.offline,
      malformedResponse: malformedResponse ?? this.malformedResponse,
      forceStatus: forceStatus ?? this.forceStatus,
      latency: latency ?? this.latency,
      timeoutAfter: timeoutAfter ?? this.timeoutAfter,
    );
  }
}
