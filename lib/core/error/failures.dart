import 'package:equatable/equatable.dart';

/// Failure classes represent domain-level errors.
/// Repositories return these instead of throwing exceptions,
/// allowing the presentation layer to handle errors gracefully.

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required super.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message});
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({required super.message, this.fieldErrors});

  @override
  List<Object?> get props => [message, fieldErrors];
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}
