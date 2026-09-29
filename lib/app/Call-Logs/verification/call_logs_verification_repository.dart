import 'dart:convert';

import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class CallLogsChallenge {
  const CallLogsChallenge({
    required this.mfaToken,
    required this.apiPhoneNumber,
  });

  final String mfaToken;
  final String apiPhoneNumber;
}

class CallLogsVerificationException implements Exception {
  const CallLogsVerificationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Starts the additional MFA challenge required only for Call Logs access.
class CallLogsVerificationRepository {
  CallLogsVerificationRepository({
    NetworkService? networkService,
    AuthManager? authManager,
    Future<String?> Function()? phoneNumberProvider,
  })  : _networkService = networkService ?? instance<NetworkService>(),
        _authManager = authManager ?? instance<AuthManager>(),
        _phoneNumberProvider =
            phoneNumberProvider ?? _defaultPhoneNumberProvider;

  final NetworkService _networkService;
  final AuthManager _authManager;
  final Future<String?> Function() _phoneNumberProvider;

  Future<CallLogsChallenge> requestChallenge() async {
    final apiPhoneNumber = (await _phoneNumberProvider())?.trim() ?? '';
    if (apiPhoneNumber.isEmpty) {
      throw const CallLogsVerificationException(
        'Your mobile number is unavailable. Please sign in again.',
      );
    }

    var session = _authManager.currentSession;
    if (session == null) {
      throw const CallLogsVerificationException(
        'Your session is unavailable. Please sign in again.',
      );
    }

    try {
      if (session.accessExpired) {
        session = await _authManager.refreshIfNeeded();
        if (session == null || session.accessExpired) {
          throw const CallLogsVerificationException(
            'Your session has expired. Please sign in again.',
          );
        }
      }

      return await _sendChallenge(
        accessToken: session.accessToken,
        apiPhoneNumber: apiPhoneNumber,
      );
    } on CallLogsVerificationException {
      rethrow;
    } catch (error) {
      throw CallLogsVerificationException(_errorMessage(error));
    }
  }

  Future<CallLogsChallenge> _sendChallenge({
    required String accessToken,
    required String apiPhoneNumber,
  }) async {
    final response = await _networkService.request<dynamic>(
      Api.challengeOtpUrl,
      method: HttpMethod.post,
      data: <String, dynamic>{'access_token': accessToken},
    );
    final body = _asMap(response.data);
    final mfaToken =
        (body['mfa_token'] ?? body['mfaToken'] ?? body['Key'] ?? body['key'])
            ?.toString()
            .trim();
    if (mfaToken == null || mfaToken.isEmpty) {
      throw const CallLogsVerificationException(
        'The verification request returned an invalid response.',
      );
    }
    return CallLogsChallenge(
      mfaToken: mfaToken,
      apiPhoneNumber: apiPhoneNumber,
    );
  }

  static Future<String?> _defaultPhoneNumberProvider() async {
    if (!instance.isRegistered<AccountInfoCubit>()) return null;
    final account = instance<AccountInfoCubit>().state.accountInfo;
    if (account == null) return null;

    for (final candidate in <String>[
      account.username,
      account.primaryPhoneNumber,
      account.phoneNumber,
      ...account.tNs,
    ]) {
      if (candidate.trim().isNotEmpty) return candidate;
    }
    return null;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    dynamic decoded = value;
    if (value is String) {
      decoded = jsonDecode(value);
    }
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    throw const CallLogsVerificationException(
      'The verification request returned an invalid response.',
    );
  }

  String _errorMessage(Object error) {
    final raw = error.toString().replaceFirst('Exception:', '').trim();
    return raw.isEmpty
        ? 'Unable to send a verification code. Please try again.'
        : raw;
  }
}
