import 'package:flutter/foundation.dart';

import '../model/login_otp_resend_response_model.dart';
import '../model/login_otp_verify_response_model.dart';
import 'base_login_otp_repository.dart';
import 'services/login_otp_api_client.dart';
import 'services/otp_json_parser.dart';
import 'services/otp_response_validator.dart';
import 'services/phone_normalizer.dart';

/// Login OTP repository — orchestrates api client + phone normalizer +
/// parser + validator for the 2fa/verify and 2fa/resend endpoints.
class LoginOtpRepository implements BaseLoginOtpRepository {
  LoginOtpRepository({
    LoginOtpApiClient? apiClient,
    PhoneNormalizer? phoneNormalizer,
    OtpResponseValidator? responseValidator,
    OtpJsonParser? jsonParser,
  })  : _apiClient = apiClient ?? LoginOtpApiClient(),
        _phoneNormalizer = phoneNormalizer ?? PhoneNormalizer(),
        _responseValidator = responseValidator ?? OtpResponseValidator(),
        _jsonParser = jsonParser ?? OtpJsonParser();

  final LoginOtpApiClient _apiClient;
  final PhoneNormalizer _phoneNormalizer;
  final OtpResponseValidator _responseValidator;
  final OtpJsonParser _jsonParser;

  @override
  Future<LoginOtpVerifyResponse> verifyCode({
    required String phoneNumber,
    required String mfaToken,
    required String otpCode,
  }) async {
    final normalizedPhone = _phoneNormalizer.normalize(phoneNumber);

    if (kDebugMode) {
      debugPrint('LoginOtpRepository: Verifying OTP for phone=$normalizedPhone');
    }

    final rawJson = await _apiClient.verifyOtp(
      phoneNumber: normalizedPhone,
      mfaToken: mfaToken,
      otpCode: otpCode,
    );

    final response = _jsonParser.parseVerifyResponse(rawJson);
    _responseValidator.validateVerifyResponse(response);
    return response;
  }

  @override
  Future<LoginOtpResendResponse> resendCode({
    required String phoneNumber,
    required String mfaToken,
  }) async {
    final normalizedPhone = _phoneNormalizer.normalize(phoneNumber);

    if (kDebugMode) {
      debugPrint('LoginOtpRepository: Resending OTP for phone=$normalizedPhone');
    }

    final rawJson = await _apiClient.resendOtp(
      phoneNumber: normalizedPhone,
      mfaToken: mfaToken,
    );

    final response = _jsonParser.parseResendResponse(rawJson);
    _responseValidator.validateResendResponse(response);
    return response;
  }
}
