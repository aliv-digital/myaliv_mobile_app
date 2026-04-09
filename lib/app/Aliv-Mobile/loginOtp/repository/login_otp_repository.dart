import 'package:flutter/foundation.dart';
import '../model/login_otp_resend_response_model.dart';
import '../model/login_otp_verify_response_model.dart';
import 'base_login_otp_repository.dart';
import 'services/login_otp_api_client.dart';
import 'services/phone_normalizer.dart';
import 'services/otp_response_validator.dart';
import 'services/otp_json_parser.dart';

/// Login OTP repository - refactored version using service composition.
///
/// This repository orchestrates:
/// - LoginOtpApiClient: Handles API calls
/// - PhoneNormalizer: Normalizes phone numbers
/// - OtpResponseValidator: Validates response data
/// - OtpJsonParser: Parses JSON responses
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
    required String twoFactorKey,
    required String pinCode,
  }) async {
    // 1. Normalize phone number
    final normalizedPhone = _phoneNormalizer.normalize(phoneNumber);

    if (kDebugMode) {
      debugPrint(
        'LoginOtpRepository: Verifying OTP for phone=$normalizedPhone',
      );
    }

    // 2. Make API call
    final rawJson = await _apiClient.verifyOtp(
      phoneNumber: normalizedPhone,
      twoFactorKey: twoFactorKey,
      pinCode: pinCode,
    );

    // 3. Parse response
    final response = _jsonParser.parseVerifyResponse(rawJson);

    if (kDebugMode) {
      debugPrint(
        'LoginOtpRepository: Verify response parsed successfully',
      );
    }

    // 4. Validate response
    _responseValidator.validateVerifyResponse(response);

    return response;
  }

  @override
  Future<LoginOtpResendResponse> resendCode({
    required String phoneNumber,
    required String twoFactorKey,
  }) async {
    // 1. Normalize phone number
    final normalizedPhone = _phoneNormalizer.normalize(phoneNumber);

    if (kDebugMode) {
      debugPrint(
        'LoginOtpRepository: Resending OTP for phone=$normalizedPhone',
      );
    }

    // 2. Make API call
    final rawJson = await _apiClient.resendOtp(
      phoneNumber: normalizedPhone,
      twoFactorKey: twoFactorKey,
    );

    // 3. Parse response
    final response = _jsonParser.parseResendResponse(rawJson);

    if (kDebugMode) {
      debugPrint(
        'LoginOtpRepository: Resend response parsed successfully',
      );
    }

    // 4. Validate response
    _responseValidator.validateResendResponse(response);

    return response;
  }
}
