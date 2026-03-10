import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/networkService/api_paths.dart';
import '../../../../core/networkService/app_http_client.dart';
import '../model/login_otp_resend_response_model.dart';
import '../model/login_otp_verify_response_model.dart';

class LoginOtpRepository {

  LoginOtpRepository({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<LoginOtpVerifyResponse> verifyCode({
    required String phoneNumber,
    required String twoFactorKey,
    required String pinCode,
  }) async {
    // API expects a digits-only phone number (e.g. 2428997105).
    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final payload = <String, dynamic>{
      'PhoneNumber': normalizedPhone,
      'Key': twoFactorKey,
      'PinCode': pinCode,
    };

    if (kDebugMode) {
      debugPrint(
        'OTP verify payload: {PhoneNumber: $normalizedPhone, Key: ****, PinCode: ****}',
      );
    }

    final response = await _api.postJson(Api.verifyOtpUrl, body: payload);

    if (kDebugMode) {
      debugPrint(
        'OTP verify status: ${response.statusCode}, body: ${response.responseJson}',
      );
    }

    final parsedJson = _tryDecodeMap(response.responseJson);
    final verifyResponse = LoginOtpVerifyResponse.fromJson(parsedJson);

    if (ApiService.isSuccessStatusCode(response.statusCode)) {
      final ticket = verifyResponse.ticket?.trim() ?? '';
      if (ticket.isEmpty) {
        throw Exception(
          _resolveMessage(
            verifyResponse.reason,
            fallback: 'Ticket missing in OTP verify response',
          ),
        );
      }
      return verifyResponse;
    }

    throw Exception(
      ApiService.friendlyErrorFromResponse(
        response,
        backendMessage: verifyResponse.reason,
      ) ?? 'OTP verification failed. Please try again.',
    );
  }

  Future<LoginOtpResendResponse> resendCode({
    required String phoneNumber,
    required String twoFactorKey,
  }) async {
    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final payload = <String, dynamic>{
      'PhoneNumber': normalizedPhone,
      'Key': twoFactorKey,
    };

    if (kDebugMode) {
      debugPrint(
        'OTP resend payload: {PhoneNumber: $normalizedPhone, Key: ****}',
      );
    }

    final response = await _api.postJson(Api.resendOtpUrl, body: payload);

    if (kDebugMode) {
      debugPrint(
        'OTP resend status: ${response.statusCode}, body: ${response.responseJson}',
      );
    }

    final parsedJson = _tryDecodeMap(response.responseJson);
    final resendResponse = LoginOtpResendResponse.fromJson(parsedJson);

    if (ApiService.isSuccessStatusCode(response.statusCode)) {
      final key = resendResponse.key?.trim() ?? '';
      if (key.isEmpty) {
        throw Exception(
          _resolveMessage(
            resendResponse.reason,
            fallback: 'Key missing in OTP resend response',
          ),
        );
      }
      return resendResponse;
    }

    throw Exception(
      ApiService.friendlyErrorFromResponse(
        response,
        backendMessage: resendResponse.reason,
      ) ?? 'Could not resend OTP. Please try again.',
    );
  }

  Map<String, dynamic>? _tryDecodeMap(String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  String _resolveMessage(String? message, {required String fallback}) {
    final trimmed = message?.trim() ?? '';
    if (trimmed.isNotEmpty) return trimmed;
    return fallback;
  }
}
/*
I/flutter (24566): OTP verify status: 200,
 body: {"Ticket":"db09c1ce-9969-43d3-a346-a5cb18f1d366szcN/FyIvrgsd1fVpZ/+L8tdriQQn05FV7DB2Lhv8+kCr2KzoIgCB40J3rULAkhigqyNZj4Cpgl6+IBlztX58Q==","AccountId":235724603}
 */