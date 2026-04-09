import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:core/core.dart';

import '../../../../../../core/networkService/api_paths.dart';
import '../home_plans_postpaid_repository_exception.dart';

class HomePlansPostPaidApiClient {
  HomePlansPostPaidApiClient({
    NetworkService? networkService,
    AuthManager? authManager,
  })  : _networkService = networkService ?? instance<NetworkService>(),
        _authManager = authManager ?? instance<AuthManager>();

  final NetworkService _networkService;
  final AuthManager _authManager;

  Future<String> fetchRawPlansJson() async {
    final auth = _authManager.getCurrentAuth();

    if (auth == null || !auth.isAuthenticated) {
      throw const HomePlansPostPaidRepositoryException(
        type: HomePlansPostPaidRepositoryErrorType.unauthorized,
        serverMessage: 'Authentication required to fetch plans',
        statusCode: 401,
      );
    }

    if (kDebugMode) {
      debugPrint(
        'HomePlansPostPaidApiClient: Fetching plans for device=${auth.deviceAccountID}',
      );
    }

    final response = await _networkService.request<String>(
      '${Api.getAllPlans}/${auth.deviceAccountID}/available-plans',
      method: HttpMethod.get,
    );

    if (kDebugMode) {
      debugPrint(
        'HomePlansPostPaidApiClient: Response status=${response.statusCode}',
      );
    }

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw _mapErrorToException(
        statusCode: response.statusCode ?? 0,
        responseBody: response.data ?? '',
      );
    }

    return response.data ?? '';
  }

  HomePlansPostPaidRepositoryException _mapErrorToException({
    required int statusCode,
    required String responseBody,
  }) {
    final serverMessage = _extractServerMessage(responseBody);

    if (statusCode == 0) {
      if (responseBody.toLowerCase().contains('timeout')) {
        return HomePlansPostPaidRepositoryException(
          type: HomePlansPostPaidRepositoryErrorType.timeout,
          statusCode: statusCode,
          serverMessage: serverMessage,
        );
      }

      return HomePlansPostPaidRepositoryException(
        type: HomePlansPostPaidRepositoryErrorType.noInternet,
        statusCode: statusCode,
        serverMessage: serverMessage,
      );
    }

    switch (statusCode) {
      case 401:
        return HomePlansPostPaidRepositoryException(
          type: HomePlansPostPaidRepositoryErrorType.unauthorized,
          statusCode: statusCode,
          serverMessage: serverMessage,
        );
      case 403:
        return HomePlansPostPaidRepositoryException(
          type: HomePlansPostPaidRepositoryErrorType.forbidden,
          statusCode: statusCode,
          serverMessage: serverMessage,
        );
      case 404:
        return HomePlansPostPaidRepositoryException(
          type: HomePlansPostPaidRepositoryErrorType.notFound,
          statusCode: statusCode,
          serverMessage: serverMessage,
        );
      case 408:
        return HomePlansPostPaidRepositoryException(
          type: HomePlansPostPaidRepositoryErrorType.timeout,
          statusCode: statusCode,
          serverMessage: serverMessage,
        );
      default:
        if (statusCode >= 500) {
          return HomePlansPostPaidRepositoryException(
            type: HomePlansPostPaidRepositoryErrorType.server,
            statusCode: statusCode,
            serverMessage: serverMessage,
          );
        }

        if (statusCode >= 400) {
          return HomePlansPostPaidRepositoryException(
            type: HomePlansPostPaidRepositoryErrorType.badResponse,
            statusCode: statusCode,
            serverMessage: serverMessage,
          );
        }

        return HomePlansPostPaidRepositoryException(
          type: HomePlansPostPaidRepositoryErrorType.unknown,
          statusCode: statusCode,
          serverMessage: serverMessage,
        );
    }
  }

  String? _extractServerMessage(String responseBody) {
    if (responseBody.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(responseBody);

      if (decoded is String && decoded.trim().isNotEmpty) {
        return decoded.trim();
      }

      if (decoded is Map) {
        for (final key in <String>[
          'message',
          'error',
          'errorMessage',
          'detail',
          'title',
        ]) {
          final value = decoded[key];
          if (value is String && value.trim().isNotEmpty) {
            return value.trim();
          }
        }
      }
    } catch (_) {
      // Ignore invalid JSON error shapes and return raw body below.
    }

    final trimmed = responseBody.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
