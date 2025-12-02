import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/networkService/api_paths.dart';
import '../../../core/networkService/app_http_client.dart';
import '../model/auth_response_model.dart';

class AuthRepository {
  Future<AuthResponse> signIn(String phoneNumber, String password) async {

    //await Future.delayed(const Duration(seconds: 2));
    final apiService = ApiService();


    final apiResponse = await apiService.postJson("${Api.baseUrl}${Api.login}",body: {
      "phone": phoneNumber,
      "password": password
    }).timeout(Duration(milliseconds: 5000));
    final raw = apiResponse.responseJson;
    if (raw.isEmpty) {
      return const AuthResponse(status: -1, message: 'Empty response');
    }

    try{
      final Map<String,dynamic> data = jsonDecode(raw);
      final response = AuthResponse.fromJson(data);
      debugPrint("---------- User Sign-in Api Response ------------------------");
      debugPrint("status : ${response.status}");
      debugPrint("message : ${response.message}");
      return response;
    }catch(e){
      debugPrint('JSON parse error: $e');
      return const AuthResponse(status: -1, message: 'Invalid response format');
    }
  }
}
