/// Transport-agnostic error raised by [MockDatabase] handlers.
///
/// The adapter turns this into a real HTTP response with the given status
/// and JSON body, so the app exercises the full Dio error pipeline
/// (interceptors → exception mapping → user-facing states).
class MockHttpError implements Exception {
  const MockHttpError(this.statusCode, this.body);

  final int statusCode;
  final Map<String, Object?> body;

  @override
  String toString() => 'MockHttpError($statusCode): $body';
}
