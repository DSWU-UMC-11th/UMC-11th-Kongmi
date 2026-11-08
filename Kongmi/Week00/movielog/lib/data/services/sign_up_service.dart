import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';

import '../models/check_result.dart';
import '../models/common_response.dart';
import '../models/create_member_request.dart';
import '../models/sign_up_models.dart';

class SignUpService {
  SignUpService(this._dio);
  final Dio _dio;

  Future<bool> checkNickname(String nickname) async {
    final encoded = Uri.encodeComponent(nickname.trim());
    final response = await _dio.get('${ApiConfig.prefix}/members/nickname/$encoded');
    return CheckResult.fromJson(response.data as Map<String, dynamic>).available;
  }

  Future<bool> checkEmail(String email) async {
    final encoded = Uri.encodeComponent(email.trim());
    final response = await _dio.get('${ApiConfig.prefix}/members/email/$encoded');
    return CheckResult.fromJson(response.data as Map<String, dynamic>).available;
  }

  Future<CommonResponse<SignUpResult>> signUp(
    CreateMemberRequest request,
  ) async {
    final response = await _dio.post(
      '${ApiConfig.prefix}/members',
      data: request.toJson(),
    );

    return CommonResponse<SignUpResult>.fromJson(
      response.data as Map<String, dynamic>,
      (value) => SignUpResult.fromJson(value as Map<String, dynamic>),
    );
  }
}

String writeSignUpErrorMessage(DioException error) {
  return tryParseCommonResponse(error.response?.data)?.message ??
      '회원가입에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}
