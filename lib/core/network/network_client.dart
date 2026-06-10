import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

class NetworkClient {
  late final Dio _dio;

  NetworkClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );
    _dio.interceptors.add(_AppInterceptor());
  }

  Dio get dio => _dio;
}

class _AppInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException(
            'No internet connection. Please check your network.',
          ),
          type: err.type,
        ),
      );
    }

    if (response != null) {
      final statusCode = response.statusCode;

      if (statusCode == 400 || statusCode == 404) {
        final errorBody = response.data;
        final apiMessage = _extractApiMessage(errorBody);
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: response,
            error: CityNotFoundException(
              apiMessage ?? 'City not found. Please check the city name.',
            ),
            type: err.type,
          ),
        );
      }

      if (statusCode == 429) {
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: response,
            error: const RateLimitException(
              'API rate limit exceeded. Please try again later.',
            ),
            type: err.type,
          ),
        );
      }

      if (statusCode != null && statusCode >= 500) {
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: response,
            error: ServerException(
              'Server error. Please try again later.',
              statusCode: statusCode,
            ),
            type: err.type,
          ),
        );
      }
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: const ServerException('An unexpected error occurred.'),
        type: err.type,
      ),
    );
  }

  String? _extractApiMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body['error']?['message'] as String?;
    }
    return null;
  }
}