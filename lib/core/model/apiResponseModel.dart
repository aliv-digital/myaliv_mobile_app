
class ApiResponseModel{
  final int _statusCode;
  final String _responseJson;
  ApiResponseModel(this._statusCode,this._responseJson);
  String get responseJson =>_responseJson;
  int get statusCode => _statusCode;
}