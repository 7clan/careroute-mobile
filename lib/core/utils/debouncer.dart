import 'dart:async';

/// Runs [call] only after [delay] of silence.
///
/// Used to avoid firing a search request on every keystroke.
/// Not tied to any UI framework, so it is trivially unit-testable.
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 350)});

  final Duration delay;
  Timer? _timer;

  bool get isScheduled => _timer?.isActive ?? false;

  /// Schedules [call]; reschedules if another event arrives first.
  void call(void Function() call) {
    _timer?.cancel();
    _timer = Timer(delay, call);
  }

  /// Cancels any pending scheduled call.
  void cancel() => _timer?.cancel();

  /// Cancels pending timers — call from `ref.onDispose` / `dispose`.
  void dispose() => cancel();
}
