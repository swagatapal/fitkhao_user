/// Base class for all application exceptions
sealed class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// API related exceptions
class ApiException extends AppException {
  final int? statusCode;

  const ApiException({
    required super.message,
    this.statusCode,
    super.code,
    super.originalError,
  });
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Validation related exceptions
class ValidationException extends AppException {
  final Map<String, String>? errors;

  const ValidationException({
    required super.message,
    this.errors,
    super.code,
    super.originalError,
  });
}

/// Cache/Storage related exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Timeout exceptions
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Request timeout. Please try again.',
    super.code,
    super.originalError,
  });
}

/// Server error exceptions
class ServerException extends AppException {
  const ServerException({
    super.message = 'Server error. Please try again later.',
    super.code,
    super.originalError,
  });
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found.',
    super.code,
    super.originalError,
  });
}

/// Unauthorized exceptions
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized access. Please login again.',
    super.code,
    super.originalError,
  });
}

/// Utility class to convert exceptions to user-friendly messages
class ExceptionHandler {
  ExceptionHandler._();

  /// Convert exception to user-friendly message
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else if (error is Exception) {
      return 'An unexpected error occurred. Please try again.';
    } else {
      return error.toString();
    }
  }

  /// Check if error is a network error
  static bool isNetworkError(dynamic error) {
    return error is NetworkException || error is TimeoutException;
  }

  /// Check if error is an authentication error
  static bool isAuthError(dynamic error) {
    return error is AuthException || error is UnauthorizedException;
  }
}
