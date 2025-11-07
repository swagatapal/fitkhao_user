import 'package:dio/dio.dart';
import '../errors/app_exception.dart';

/// API Client for handling all HTTP requests
class ApiClient {
  late final Dio _dio;
  final String baseUrl;

  ApiClient({
    required this.baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout ?? const Duration(seconds: 30),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_ApiInterceptor());
  }

  /// GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove authorization token
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Handle errors and convert to AppException
  AppException _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException(
            originalError: error,
          );

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'] as String? ??
              'An error occurred';

          if (statusCode == 401) {
            return UnauthorizedException(
              message: message,
              originalError: error,
            );
          } else if (statusCode == 404) {
            return NotFoundException(
              message: message,
              originalError: error,
            );
          } else if (statusCode != null && statusCode >= 500) {
            return ServerException(
              message: message,
              originalError: error,
            );
          } else {
            return ApiException(
              message: message,
              statusCode: statusCode,
              originalError: error,
            );
          }

        case DioExceptionType.cancel:
          return NetworkException(
            message: 'Request was cancelled',
            originalError: error,
          );

        case DioExceptionType.connectionError:
        case DioExceptionType.unknown:
          return NetworkException(
            message: 'No internet connection. Please check your network.',
            originalError: error,
          );

        default:
          return NetworkException(
            message: 'Network error occurred',
            originalError: error,
          );
      }
    }

    return NetworkException(
      message: 'An unexpected error occurred',
      originalError: error,
    );
  }
}

/// API Interceptor for logging and request/response modification
class _ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Log request in debug mode
    // print('REQUEST[${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log response in debug mode
    // print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log error in debug mode
    // print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    super.onError(err, handler);
  }
}
