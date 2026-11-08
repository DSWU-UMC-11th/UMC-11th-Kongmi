class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://workbook.devnoco.com',
  );

  static const String prefix = String.fromEnvironment(
    'API_PREFIX',
    defaultValue: '/v6',
  );

  static const int devMemberId = int.fromEnvironment('DEV_MEMBER_ID');
}
