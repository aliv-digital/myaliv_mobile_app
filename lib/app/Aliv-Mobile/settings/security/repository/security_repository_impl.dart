import 'package:dio/dio.dart';

import 'security_repository.dart';

class SecurityRepositoryImpl implements SecurityRepository {
  SecurityRepositoryImpl({
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _securityUrl =
      'https://myalivappuat-api.bealiv.com/api/app-settings/security';

  @override
  Future<SecurityContent> fetchContent() async {
    final Response<dynamic> response = await _dio.get(_securityUrl);
    final dynamic responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw Exception('Invalid security response format');
    }

    final dynamic data = responseData['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Security data not found');
    }

    final String htmlContent = (data['value'] as String?)?.trim() ?? '';

    if (htmlContent.isEmpty) {
      throw Exception('Security content is empty');
    }

    return SecurityContent(htmlContent: htmlContent);
  }
}