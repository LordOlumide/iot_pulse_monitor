class Failure implements Exception {
  final String? message;
  final Exception? exception;
  final StackTrace _stackTrace;

  Failure({
    this.message,
    this.exception,
    StackTrace? stackTrace,
  }) : _stackTrace = stackTrace ?? StackTrace.current;

  @override
  String toString() => ''' | --- Failure --- | 
      message: $message,
      exception: $exception,
      _stackTrace: $_stackTrace''';

  Failure copyWith({
    String? message,
    Exception? exception,
    StackTrace? stackTrace,
  }) {
    return Failure(
      message: message ?? this.message,
      exception: exception ?? this.exception,
      stackTrace: stackTrace ?? _stackTrace,
    );
  }
}
