class CommonResponse<T> {
  const CommonResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    this.result,
  });

  final bool isSuccess;
  final String code;
  final String message;
  final T? result;

  factory CommonResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? value) parseResult,
  ) {
    final rawResult = json['result'];
    return CommonResponse<T>(
      isSuccess: json['isSuccess'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      result: rawResult == null ? null : parseResult(rawResult),
    );
  }
}

CommonResponse<Object?>? tryParseCommonResponse(Object? data) {
  if (data is! Map<String, dynamic>) return null;
  if (data['isSuccess'] is! bool ||
      data['code'] is! String ||
      data['message'] is! String) {
    return null;
  }
  return CommonResponse<Object?>.fromJson(data, (value) => value);
}
