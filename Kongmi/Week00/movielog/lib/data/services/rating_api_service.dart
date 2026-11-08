import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/api_config.dart';

import '../models/common_response.dart';
import '../models/rating_dto.dart';
import '../models/rating_request.dart';

class RatingApiService {
  RatingApiService(this._dio);
  final Dio _dio;

  static const _failRefreshOnce = bool.fromEnvironment('FAIL_REFRESH_ONCE');
  bool _failNextFetch = false;

  void _armRefreshFailure() {
    if (kDebugMode && _failRefreshOnce) _failNextFetch = true;
  }

  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    if (_failNextFetch) {
      _failNextFetch = false;
      throw DioException(
        requestOptions: RequestOptions(
          path: '${ApiConfig.prefix}/members/$memberId/ratings',
        ),
        type: DioExceptionType.connectionError,
        message: 'FAIL_REFRESH_ONCE',
      );
    }
    final response = await _dio.get('${ApiConfig.prefix}/members/$memberId/ratings');
    final list = response.data as List<dynamic>;
    return list
        .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createRating({
    required int memberId,
    required CreateRatingRequest request,
  }) async {
    final response = await _dio.post(
      '${ApiConfig.prefix}/members/$memberId/ratings',
      data: request.toJson(),
    );
    if (response.statusCode != 201) {
      throw StateError('예상하지 못한 등록 응답: ${response.statusCode}');
    }
  }

  Future<void> updateRating({
    required int memberId,
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    await _dio.patch(
      '${ApiConfig.prefix}/members/$memberId/ratings/$ratingId',
      data: UpdateRatingRequest(score: score, comment: comment).toJson(),
    );
    _armRefreshFailure();
  }

  Future<void> deleteRating({
    required int memberId,
    required int ratingId,
  }) async {
    final response = await _dio.delete(
      '${ApiConfig.prefix}/members/$memberId/ratings/$ratingId',
    );
    if (response.statusCode != 204) {
      throw StateError('예상하지 못한 삭제 응답: ${response.statusCode}');
    }
    _armRefreshFailure();
  }
}

String writeMyRatingsErrorMessage(DioException error) {
  final common = tryParseCommonResponse(error.response?.data);
  if (common != null) return common.message;
  final status = error.response?.statusCode;
  if (status == 400) return 'memberId 형식을 다시 확인해 주세요.';
  if (status == 404) return '존재하지 않는 회원입니다.';
  return '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
}

String writeErrorMessage(DioException error) {
  return tryParseCommonResponse(error.response?.data)?.message ??
      '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}

bool shouldRefreshAfterRatingError(DioException error) {
  final code = tryParseCommonResponse(error.response?.data)?.code;
  return code == 'COMMON403' || code == 'COMMON404';
}
