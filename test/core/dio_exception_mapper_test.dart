import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careroute_mobile/core/errors/app_exception.dart';
import 'package:careroute_mobile/core/network/dio_exception_mapper.dart';

RequestOptions _options([String path = '/x']) => RequestOptions(path: path);

DioException _badResponse(int status, {Object? data}) => DioException(
  requestOptions: _options(),
  type: DioExceptionType.badResponse,
  response: Response(
    requestOptions: _options(),
    statusCode: status,
    data: data,
  ),
);

void main() {
  group('DioExceptionMapper', () {
    test('connection timeouts map to TimeoutException', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        final error = DioException(requestOptions: _options(), type: type);
        expect(DioExceptionMapper.map(error), isA<TimeoutException>());
      }
    });

    test('connection errors map to NoNetworkException', () {
      final error = DioException(
        requestOptions: _options(),
        type: DioExceptionType.connectionError,
      );
      expect(DioExceptionMapper.map(error), isA<NoNetworkException>());
    });

    test('401 maps to UnauthorizedException', () {
      final mapped = DioExceptionMapper.map(
        _badResponse(401, data: {'message': 'expired'}),
      );
      expect(mapped, isA<UnauthorizedException>());
    });

    test('403 maps to ForbiddenException', () {
      expect(
        DioExceptionMapper.map(_badResponse(403)),
        isA<ForbiddenException>(),
      );
    });

    test('404 maps to NotFoundException', () {
      expect(
        DioExceptionMapper.map(_badResponse(404)),
        isA<NotFoundException>(),
      );
    });

    test('422 maps to ValidationException with field errors', () {
      final mapped = DioExceptionMapper.map(
        _badResponse(
          422,
          data: {
            'message': 'Validation failed.',
            'errors': {
              'email': ['This email is already registered.'],
              'password': ['Password must be at least 8 characters.'],
            },
          },
        ),
      );
      expect(mapped, isA<ValidationException>());
      final validation = mapped as ValidationException;
      expect(validation.fieldErrors['email'], [
        'This email is already registered.',
      ]);
      expect(validation.fieldErrors['password'], [
        'Password must be at least 8 characters.',
      ]);
    });

    test('400 maps to ValidationException (empty errors allowed)', () {
      final mapped = DioExceptionMapper.map(
        _badResponse(400, data: {'message': 'bad request'}),
      );
      expect(mapped, isA<ValidationException>());
      expect((mapped as ValidationException).fieldErrors, isEmpty);
    });

    test('5xx maps to ServerException with status code', () {
      for (final status in [500, 502, 503]) {
        final mapped = DioExceptionMapper.map(_badResponse(status));
        expect(mapped, isA<ServerException>());
        expect((mapped as ServerException).statusCode, status);
      }
    });

    test('unknown dio errors fall back to UnknownException', () {
      final error = DioException(
        requestOptions: _options(),
        type: DioExceptionType.unknown,
        error: StateError('boom'),
      );
      expect(DioExceptionMapper.map(error), isA<UnknownException>());
    });

    test('nested connection errors inside unknown are unwrapped', () {
      final inner = DioException(
        requestOptions: _options(),
        type: DioExceptionType.connectionError,
      );
      final outer = DioException(
        requestOptions: _options(),
        type: DioExceptionType.unknown,
        error: inner,
      );
      expect(DioExceptionMapper.map(outer), isA<NoNetworkException>());
    });

    test('FormatException maps to ParsingException', () {
      const error = FormatException('not json');
      expect(DioExceptionMapper.map(error), isA<ParsingException>());
    });

    test('already-mapped AppExceptions pass through unchanged', () {
      const original = TimeoutException();
      final mapped = DioExceptionMapper.map(original);
      expect(identical(mapped, original), isTrue);
    });

    test('every mapped exception exposes a non-technical user message', () {
      const exceptions = [
        NoNetworkException(),
        TimeoutException(),
        UnauthorizedException(),
        ForbiddenException(),
        NotFoundException(),
        ServerException(),
        ParsingException(),
        UnknownException(),
      ];
      for (final exception in exceptions) {
        expect(exception.userMessage, isNotEmpty);
        expect(
          exception.userMessage.contains('Exception'),
          isFalse,
          reason: '${exception.runtimeType} must not leak its type',
        );
        expect(exception.userMessage.contains('Dio'), isFalse);
      }
    });
  });
}
