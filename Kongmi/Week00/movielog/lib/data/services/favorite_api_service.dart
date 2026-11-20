import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../models/common_response.dart';
import '../models/favorite_check_dto.dart';
import '../models/favorite_response_dto.dart';

class FavoriteApiService {
  FavoriteApiService(this._dio);

  final Dio _dio;

  static const _base = '${ApiConfig.authPrefix}/favorites';

  Future<FavoriteResponseDto> addFavorite({required int movieId}) async {
    final response = await _dio.post(_base, data: {'movieId': movieId});
    final body = CommonResponse<FavoriteResponseDto>.fromJson(
      response.data as Map<String, dynamic>,
      FavoriteResponseDto.fromJson,
    );
    final result = body.result;
    if (result == null) throw StateError('즐겨찾기 등록 result가 없습니다.');
    return result;
  }

  Future<List<FavoriteResponseDto>> fetchMyFavorites() async {
    final response = await _dio.get(_base);
    final body = CommonResponse<List<FavoriteResponseDto>>.fromJson(
      response.data as Map<String, dynamic>,
      (value) => (value as List<dynamic>)
          .map(FavoriteResponseDto.fromJson)
          .toList(),
    );
    return body.result ?? const [];
  }

  Future<FavoriteCheckDto> checkFavorite({required int movieId}) async {
    final response = await _dio.get('$_base/$movieId');
    final body = CommonResponse<FavoriteCheckDto>.fromJson(
      response.data as Map<String, dynamic>,
      (value) => FavoriteCheckDto.fromJson(value, movieId: movieId),
    );
    final result = body.result;
    if (result == null) throw StateError('즐겨찾기 여부 result가 없습니다.');
    return result;
  }

  Future<void> deleteFavorite({required int movieId}) async {
    await _dio.delete('$_base/$movieId');
  }
}
