/// Base type for every failure the UI may need to present.
///
/// Repositories translate low-level transport / HTTP / parsing errors into
/// these user-safe types so widgets never receive raw stack traces.
sealed class AppException implements Exception {
  const AppException({this.cause, this.stackTrace});

  /// Original error, kept for logging — never shown to users.
  final Object? cause;
  final StackTrace? stackTrace;

  /// Human-readable, non-technical message safe to display in the UI.
  String get userMessage;

  @override
  String toString() => '$runtimeType(${cause ?? ''})';
}

/// The device is offline or the server cannot be reached at all.
class NoNetworkException extends AppException {
  const NoNetworkException({super.cause, super.stackTrace});

  @override
  String get userMessage => 'No connection. Check your internet and try again.';
}

/// The request took longer than the configured timeouts.
class TimeoutException extends AppException {
  const TimeoutException({super.cause, super.stackTrace});

  @override
  String get userMessage =>
      'The server is taking too long to respond. Please try again.';
}

/// Missing or expired credentials (HTTP 401).
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    this.serverMessage,
    super.cause,
    super.stackTrace,
  });

  /// User-safe message supplied by the API, when the backend provides one
  /// (e.g. "These credentials do not match our records.").
  final String? serverMessage;

  @override
  String get userMessage =>
      serverMessage ?? 'Your session has expired. Please sign in again.';
}

/// Authenticated but not allowed to perform the action (HTTP 403).
class ForbiddenException extends AppException {
  const ForbiddenException({this.serverMessage, super.cause, super.stackTrace});

  final String? serverMessage;

  @override
  String get userMessage =>
      serverMessage ?? "You don't have permission to perform this action.";
}

/// Requested resource does not exist (HTTP 404).
class NotFoundException extends AppException {
  const NotFoundException({this.serverMessage, super.cause, super.stackTrace});

  final String? serverMessage;

  @override
  String get userMessage =>
      serverMessage ?? 'What you were looking for is no longer available.';
}

/// The API rejected the request payload (HTTP 400 / 422).
///
/// Carries per-field messages the forms can render inline.
class ValidationException extends AppException {
  const ValidationException({
    required this.fieldErrors,
    super.cause,
    super.stackTrace,
  });

  /// Field name → list of validation messages.
  final Map<String, List<String>> fieldErrors;

  @override
  String get userMessage =>
      'Please review the highlighted fields and try again.';
}

/// Server-side failure (HTTP 5xx).
class ServerException extends AppException {
  const ServerException({
    this.statusCode,
    this.serverMessage,
    super.cause,
    super.stackTrace,
  });

  final int? statusCode;
  final String? serverMessage;

  @override
  String get userMessage =>
      serverMessage ?? 'Something went wrong on our side. Please try again.';
}

/// The response could not be decoded / parsed.
class ParsingException extends AppException {
  const ParsingException({super.cause, super.stackTrace});

  @override
  String get userMessage =>
      'We received an unexpected response from the server.';
}

/// Anything unexpected — the safe fallback.
class UnknownException extends AppException {
  const UnknownException({super.cause, super.stackTrace});

  @override
  String get userMessage => 'Something went wrong. Please try again.';
}
