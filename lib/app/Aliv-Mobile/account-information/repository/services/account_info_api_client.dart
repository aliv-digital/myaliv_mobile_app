import 'dart:convert';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/networkService/api_paths.dart';
import '../account_info_exception.dart';

/// Handles API calls for account information operations.
///
/// Responsibilities:
/// - Make authenticated API requests for account details
/// - Map HTTP errors to AccountInfoException
/// - Uses NetworkService which automatically handles Basic Auth from GlobalState
class AccountInfoApiClient {
  AccountInfoApiClient({NetworkService? networkService})
    : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  /// Fetches account info using Basic Auth from GlobalState.
  ///
  /// Returns raw JSON response string on success.
  /// Throws [AccountInfoException] on errors.
  ///
  /// Note: NetworkService automatically adds Basic Auth headers from
  /// GlobalState (managed by AuthManager), so no credentials needed here.
  Future<String> fetchAccountInfo() async {
    if (kDebugMode) {
      debugPrint('AccountInfoApiClient: Fetching account info');
    }

    try {
      // NetworkService automatically includes auth headers from GlobalState
      final response = await _networkService.request<String>(
        Api.accountUrl,
        method: HttpMethod.get,
      );

      if (kDebugMode) {
        debugPrint(
          'AccountInfoApiClient: Account info status=${response.statusCode}',
        );
      }

      // Return response data as JSON string
      if (response.data is String) {
        return response.data!;
      } else {
        return jsonEncode(response.data);
      }
    } on NetworkException catch (e) {
      throw _mapNetworkExceptionToAccountInfoException(e);
    } catch (e) {
      throw AccountInfoException(
        type: AccountInfoErrorType.unknown,
        statusCode: 0,
        serverMessage: e.toString(),
      );
    }
  }

  /// Sets auto-pay invoice status for postpaid accounts.
  ///
  /// Returns true if the operation was successful.
  /// Throws [AccountInfoException] on errors.
  Future<bool> setAutoPayInvoice(bool enable) async {
    if (kDebugMode) {
      debugPrint('AccountInfoApiClient: Setting autoPayInvoice to $enable');
    }

    try {
      final response = await _networkService.request<Map<String, dynamic>>(
        Api.invoiceAutoPayment(enable),
        method: HttpMethod.put,
      );

      if (kDebugMode) {
        debugPrint(
          'AccountInfoApiClient: setAutoPayInvoice status=${response.statusCode}',
        );
      }

      // Check for Success field in response
      final data = response.data;
      if (data != null && data['Success'] == true) {
        return true;
      }

      return false;
    } on NetworkException catch (e) {
      throw _mapNetworkExceptionToAccountInfoException(e);
    } catch (e) {
      throw AccountInfoException(
        type: AccountInfoErrorType.unknown,
        statusCode: 0,
        serverMessage: e.toString(),
      );
    }
  }

  /// Maps NetworkException to AccountInfoException.
  AccountInfoException _mapNetworkExceptionToAccountInfoException(
    NetworkException e,
  ) {
    // Handle specific network exception types
    if (e is TimeoutException) {
      return AccountInfoException(
        type: AccountInfoErrorType.timeout,
        statusCode: e.statusCode ?? 408,
        serverMessage: e.message,
      );
    }

    if (e is HostUnreachableException) {
      return AccountInfoException(
        type: AccountInfoErrorType.noInternet,
        statusCode: 0,
        serverMessage: e.message,
      );
    }

    if (e is NoInternetException) {
      return AccountInfoException(
        type: AccountInfoErrorType.noInternet,
        statusCode: 0,
        serverMessage: e.message,
      );
    }

    if (e is SessionExpiredException) {
      return AccountInfoException(
        type: AccountInfoErrorType.unauthorized,
        statusCode: 401,
        serverMessage: e.message,
      );
    }

    if (e is ServerException) {
      return AccountInfoException(
        type: AccountInfoErrorType.server,
        statusCode: e.statusCode ?? 500,
        serverMessage: e.message,
      );
    }

    // Map based on status code
    final statusCode = e.statusCode ?? 0;

    switch (statusCode) {
      case 401:
        return AccountInfoException(
          type: AccountInfoErrorType.unauthorized,
          statusCode: statusCode,
          serverMessage: e.message,
        );
      case 403:
        return AccountInfoException(
          type: AccountInfoErrorType.invalidCredentials,
          statusCode: statusCode,
          serverMessage: e.message,
        );
      case 404:
        return AccountInfoException(
          type: AccountInfoErrorType.notFound,
          statusCode: statusCode,
          serverMessage: e.message,
        );
      case 408:
        return AccountInfoException(
          type: AccountInfoErrorType.timeout,
          statusCode: statusCode,
          serverMessage: e.message,
        );
      default:
        if (statusCode >= 500) {
          return AccountInfoException(
            type: AccountInfoErrorType.server,
            statusCode: statusCode,
            serverMessage: e.message,
          );
        } else if (statusCode >= 400) {
          return AccountInfoException(
            type: AccountInfoErrorType.badResponse,
            statusCode: statusCode,
            serverMessage: e.message,
          );
        }
        return AccountInfoException(
          type: AccountInfoErrorType.unknown,
          statusCode: statusCode,
          serverMessage: e.message,
        );
    }
  }
}
