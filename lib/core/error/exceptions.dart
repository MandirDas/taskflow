/// Custom exceptions for the data layer.
/// These are thrown by data sources and caught by repositories
/// to convert into Failure objects.
library;

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() =>
      'ServerException(message: $message, statusCode: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException(message: $message)';
}

class NotFoundException implements Exception {
  final String message;

  const NotFoundException({required this.message});

  @override
  String toString() => 'NotFoundException(message: $message)';
}

class TimeoutException implements Exception {
  final String message;

  const TimeoutException({required this.message});

  @override
  String toString() => 'TimeoutException(message: $message)';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  const ValidationException({required this.message, this.fieldErrors});

  @override
  String toString() =>
      'ValidationException(message: $message, fieldErrors: $fieldErrors)';
}

class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException({required this.message});

  @override
  String toString() => 'UnauthorizedException(message: $message)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException(message: $message)';
}
