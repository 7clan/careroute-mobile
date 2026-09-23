import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

/// Translates transport-level failures into domain [AppException]s.
///
/// Widgets and controllers only ever see `AppException` — this is the
/// single place where Dio/HTTP jargon is converted into user-safe errors.
abstract final class DioExceptionMapper {
  static AppException map(Object error, {StackTrace? stackTrace}) {
    if (error is AppException) return error;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.transformTimeout:
          return TimeoutException(cause: error, stackTrace: stackTrace);
        case DioExceptionType.connectionError:
          return NoNetworkException(cause: error, stackTrace: stackTrace);
        case DioExceptionType.badResponse:
          return _mapBadResponse(error, stackTrace);
        case DioExceptionType.cancel:
          return const UnknownException();
        case DioExceptionType.badCertificate:
          return const UnknownException();
        case DioExceptionType.unknown:
          return _unwrapUnknown(error, stackTrace);
      }
    }

    if (error is FormatException || error is TypeError) {
      return ParsingException(cause: error, stackTrace: stackTrace);
    }

    return UnknownException(cause: error, stackTrace: stackTrace);
  }

  static AppException _mapBadResponse(DioException error, StackTrace? stack) {
    final status = error.response?.statusCode ?? 0;
    final data = error.response?.data;
    final Map<String, dynamic> body = data is Map<String, dynamic>
        ? data
        : const {};

    switch (status) {
      case 400:
      case 422:
        final rawErrors = body['errors'];
        final fieldErrors = <String, List<String>>{};
        if (rawErrors is Map<String, dynamic>) {
          for (final entry in rawErrors.entries) {
            final messages = entry.value;
            if (messages is List) {
              fieldErrors[entry.key] = [for (final m in messages) m.toString()];
            }
          }
        }
        return ValidationException(
          fieldErrors: fieldErrors,
          cause: error,
          stackTrace: stack,
        );
      case 401:
        return UnauthorizedException(cause: error, stackTrace: stack);
      case 403:
        return ForbiddenException(cause: error, stackTrace: stack);
      case 404:
        return NotFoundException(cause: error, stackTrace: stack);
      default:
        if (status >= 500) {
          return ServerException(
            statusCode: status,
            cause: error,
            stackTrace: stack,
          );
        }
        return UnknownException(cause: error, stackTrace: stack);
    }
  }

  /// Dio sometimes wraps adapter-level exceptions as `unknown` with the
  /// original error nested inside — unwrap before deciding.
  static AppException _unwrapUnknown(DioException error, StackTrace? stack) {
    Object? cause = error.error;
    while (cause is DioException) {
      if (cause.type == DioExceptionType.connectionError) {
        return NoNetworkException(cause: cause, stackTrace: stack);
      }
      if (cause.type == DioExceptionType.receiveTimeout ||
          cause.type == DioExceptionType.connectionTimeout ||
          cause.type == DioExceptionType.sendTimeout) {
        return TimeoutException(cause: cause, stackTrace: stack);
      }
      cause = cause.error;
    }
    if (cause is FormatException || cause is TypeError) {
      return ParsingException(cause: cause, stackTrace: stack);
    }
    return UnknownException(cause: error, stackTrace: stack);
  }
}
