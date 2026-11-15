import 'package:dio/dio.dart';

import '../core/network/api_error.dart';
import 'auth_view_model.dart';
import 'session_rating_store.dart';

Future<String> handleRatingError(
  DioException error, {
  required AuthViewModel auth,
  required SessionRatingStore store,
  required int sessionVersion,
  int? ratingId,
}) async {
  final code = apiErrorCode(error);
  if (sessionExpiredCodes.contains(code)) {
    await auth.expireSession(ifVersion: sessionVersion);
    return '로그인이 만료됐어요. 다시 로그인해 주세요.';
  }
  switch (code) {
    case 'RATING403_1':
      return '본인이 작성한 평점만 수정·삭제할 수 있어요.';
    case 'RATING404_1':
      if (ratingId != null) store.remove(sessionVersion, ratingId);
      return '이미 삭제됐거나 존재하지 않는 평점이에요. 목록을 갱신했어요.';
    case 'RATING409_1':
      return '이미 이 영화에 평점을 남겼어요. 기존 기록을 확인해 주세요.';
    case 'COMMON400':
      return apiErrorMessage(error) ?? '입력값을 확인해 주세요.';
  }
  if (isNetworkFailure(error)) {
    return '네트워크 상태를 확인하고 다시 시도해 주세요.';
  }
  return apiErrorMessage(error) ?? '요청에 실패했어요. 잠시 후 다시 시도해 주세요.';
}
