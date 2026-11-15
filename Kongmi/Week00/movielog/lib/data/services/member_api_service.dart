import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../models/member_info.dart';

class MemberApiService {
  MemberApiService(this._authDio);
  final Dio _authDio;

  Future<MemberInfo> fetchMe() async {
    final response = await _authDio.get('${ApiConfig.authPrefix}/members/me');
    return parseMemberInfo(response.data);
  }

  Future<MemberInfo> updateNickname(String nickname) async {
    final response = await _authDio.patch(
      '${ApiConfig.authPrefix}/members/me',
      data: {'nickname': nickname},
    );
    return parseMemberInfo(response.data);
  }
}
