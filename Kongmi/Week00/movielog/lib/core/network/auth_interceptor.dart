import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);
  final TokenStorage _storage;

  static const _invalidTokenOnce = bool.fromEnvironment('INVALID_TOKEN_ONCE');
  bool _invalidTokenUsed = false;

  bool _isProtected(RequestOptions options) {
    final uri = options.uri;
    final path = uri.path;
    final base = ApiConfig.authPrefix;
    return uri.host == ApiConfig.host &&
        (path == '$base/members/me' ||
            path == '$base/ratings' ||
            path.startsWith('$base/ratings/'));
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.remove('Authorization');
    if (!_isProtected(options)) {
      handler.next(options);
      return;
    }
    try {
      final token = await _storage.readAccessToken();
      if (kDebugMode && _invalidTokenOnce && !_invalidTokenUsed) {
        _invalidTokenUsed = true;
        options.headers['Authorization'] = 'Bearer invalid.test.token';
      } else if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (_) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: StateError('인증 저장소를 읽지 못했습니다.'),
        ),
      );
    }
  }
}
