import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';
import 'movie_log_logging_interceptor.dart';

BaseOptions _movieLogOptions() {
  return BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  );
}

Dio createMovieLogClient() {
  final dio = Dio(_movieLogOptions());
  dio.interceptors.add(MovieLogLoggingInterceptor('공개'));
  return dio;
}

Dio createAuthMovieLogClient(TokenStorage storage) {
  final dio = Dio(_movieLogOptions());
  dio.interceptors
    ..add(AuthInterceptor(storage))
    ..add(MovieLogLoggingInterceptor('보호'));
  return dio;
}
