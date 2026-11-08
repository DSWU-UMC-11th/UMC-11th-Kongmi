import 'package:dio/dio.dart';

import '../config/api_config.dart';

Dio createMovieLogClient() {
  return Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}