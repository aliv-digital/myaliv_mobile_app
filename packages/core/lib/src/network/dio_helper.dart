import 'package:dio/dio.dart';

/// HTTP method types for makeRequest helper
/// Import HTTPMethod from http_method.dart instead
@Deprecated('Use HTTPMethod from http_method.dart')
enum HTTPMethodLegacy {
  get,
  post,
  delete,
  patch,
  put,
  multiPart,
}

/// Helper function for making HTTP requests with Dio
/// This is a legacy helper - consider using NetworkService for new code
Future<Response> makeRequest({
  required Dio dio,
  required String path,
  required dynamic method, // Can be HTTPMethod or HTTPMethodLegacy
  dynamic data,
  Map<String, dynamic>? formDataFields,
  List<MultipartFile>? files,
}) async {
  final methodStr = method.toString().split('.').last;

  if (methodStr == 'multiPart' && data == null) {
    if (formDataFields == null && files == null) {
      throw ArgumentError(
        'formDataFields or files must be provided for multipart requests.',
      );
    }

    data = FormData.fromMap({
      ...?formDataFields,
      if (files != null) 'files': files,
    });
  }

  switch (methodStr) {
    case 'get':
      return dio.get(path, data: data);
    case 'post':
      return dio.post(path, data: data);
    case 'put':
      return dio.put(path, data: data);
    case 'delete':
      return dio.delete(path, data: data);
    case 'patch':
      return dio.patch(path, data: data);
    case 'multiPart':
      return dio.post(
        path,
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
    default:
      throw ArgumentError('Unsupported HTTP method: $methodStr');
  }
}
