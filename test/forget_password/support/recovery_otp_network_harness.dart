import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

const invalidRecoveryOtpBody = <String, dynamic>{
  'ErrorCode': 202,
  'ErrorCodeName': 'TwoFactorKeyInvalid',
  'Message': 'Two Factor Key Invalid',
  'Errors': <String, dynamic>{},
  'Detail': null,
};
const requiredRecoveryOtpMessage =
    'Too many incorrect attempts. Please request a new code to continue.';

class OtpHttpReply {
  const OtpHttpReply(this.status, this.body);
  final int status;
  final Object body;
}

/// Only the transport is fake: Dio decoding/status checks and NetworkService run.
class RecoveryOtpTransport implements HttpClientAdapter {
  final verifyRequests = <RequestOptions>[];
  final resendRequests = <RequestOptions>[];
  final forgotRequests = <RequestOptions>[];
  final verifyReplies = <OtpHttpReply>[];
  OtpHttpReply invalidReply = const OtpHttpReply(400, invalidRecoveryOtpBody);
  OtpHttpReply resendReply = const OtpHttpReply(200, {
    'mfa_token': 'replacement-challenge',
  });
  int? successfulAttempt;
  DioExceptionType? transportFailure;
  Completer<void>? pendingVerification;
  Completer<void>? verificationStarted;
  bool jsonContentType = true;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    OtpHttpReply reply;
    if (options.uri.toString() == Api.verifyOtpUrl) {
      verifyRequests.add(options);
      if (verificationStarted?.isCompleted == false) {
        verificationStarted!.complete();
      }
      await pendingVerification?.future;
      if (transportFailure != null) {
        throw DioException(requestOptions: options, type: transportFailure!);
      }
      reply = verifyReplies.isNotEmpty
          ? verifyReplies.removeAt(0)
          : successfulAttempt == verifyRequests.length
          ? const OtpHttpReply(200, {
              'access_token': 'test-access',
              'refresh_token': 'test-refresh',
              'expires_in': 3600,
              'refresh_expires_in': 86400,
            })
          : invalidReply;
    } else if (options.uri.toString() == Api.resendOtpUrl) {
      resendRequests.add(options);
      reply = resendReply;
    } else if (options.uri.toString() == Api.forgotPasswordUrl) {
      forgotRequests.add(options);
      reply = const OtpHttpReply(200, {'mfa_token': 'original-challenge'});
    } else {
      throw StateError('Unexpected test request: ${options.uri.path}');
    }
    return ResponseBody.fromString(
      jsonEncode(reply.body),
      reply.status,
      headers: {
        Headers.contentTypeHeader: [
          jsonContentType ? 'application/json' : 'text/plain',
        ],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class RecoveryOtpNetworkHarness {
  RecoveryOtpNetworkHarness({
    required this.authManager,
    this.persistCookies = true,
  });
  final AuthManager authManager;
  final bool persistCookies;
  final transport = RecoveryOtpTransport();
  late NetworkService network;
  late Directory directory;
  int hardLogouts = 0;
  static const _pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  static const _storageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  Future<void> open() async {
    directory = await Directory.systemTemp.createTemp('recovery_otp_test_');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      _pathChannel,
      (_) async => directory.path,
    );
    messenger.setMockMethodCallHandler(_storageChannel, (_) async => null);
    network = NetworkService(
      authManager: authManager,
      onHardLogout: () async {
        hardLogouts++;
      },
    );
    await network.init();
    if (!persistCookies) {
      // Widget fake time cannot service disk-cookie IO. Keep the real Dio,
      // bearer interceptor and NetworkService response/error mapping intact.
      network.dio.interceptors.removeWhere(
        (interceptor) => interceptor.runtimeType.toString() == 'CookieManager',
      );
    }
    network.dio.httpClientAdapter = transport;
  }

  Future<void> close() async {
    network.dio.close(force: true);
    await directory.delete(recursive: true);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_pathChannel, null);
    messenger.setMockMethodCallHandler(_storageChannel, null);
  }
}
