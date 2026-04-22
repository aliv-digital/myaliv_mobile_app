import 'package:dio/dio.dart';

import 'privacy_repository.dart';

class PrivacyRepositoryImpl implements PrivacyRepository {
  PrivacyRepositoryImpl({
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _privacyUrl =
      'https://myalivappuat-api.bealiv.com/api/app-settings/privacy-policy';

  @override
  Future<PrivacyContent> fetchContent() async {
    final Response<dynamic> response = await _dio.get(_privacyUrl);
    final dynamic responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw Exception('Invalid privacy response format');
    }

    final dynamic data = responseData['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Privacy data not found');
    }

    final String htmlContent = (data['value'] as String?)?.trim() ?? '';

    if (htmlContent.isEmpty) {
      throw Exception('Privacy content is empty');
    }

    return PrivacyContent(htmlContent: htmlContent);
  }
}