import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const _maskedKeys = {'password', 'accessToken', 'token'};

Object? maskSensitive(Object? value) {
  if (value is Map) {
    return {
      for (final entry in value.entries)
        entry.key: _maskedKeys.contains(entry.key)
            ? '***'
            : maskSensitive(entry.value),
    };
  }
  if (value is List) return value.map(maskSensitive).toList();
  return value;
}

class MovieLogLoggingInterceptor extends Interceptor {
  MovieLogLoggingInterceptor(this.label);
  final String label;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final hasAuth = options.headers.containsKey('Authorization');
      debugPrint('[MovieLog $label 요청] ${options.method} ${options.uri}');
      debugPrint(
        '[MovieLog $label Header] Authorization: ${hasAuth ? 'Bearer ***' : '없음'}',
      );
      if (options.data != null) {
        debugPrint('[MovieLog $label Body] ${maskSensitive(options.data)}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[MovieLog $label 응답] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri.path}',
      );
      debugPrint('[MovieLog $label 응답 Body] ${maskSensitive(response.data)}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final data = err.response?.data;
      final code = data is Map ? data['code'] : null;
      debugPrint(
        '[MovieLog $label 오류] ${err.response?.statusCode ?? err.type.name} ${err.requestOptions.method} ${err.requestOptions.uri.path} code=$code',
      );
    }
    handler.next(err);
  }
}
