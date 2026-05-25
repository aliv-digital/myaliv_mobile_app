import 'dart:convert';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import '../saved_cards_exception.dart';

/// Handles API calls for saved credit cards operations.
///
/// Responsibilities:
/// - Make authenticated API requests for saved cards
/// - Map HTTP errors to SavedCardsException
/// - Uses NetworkService which automatically handles Basic Auth from GlobalState
class SavedCardsApiClient {
  SavedCardsApiClient({NetworkService? networkService})
      : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  /// Fetches saved credit cards using Basic Auth from GlobalState.
  ///
  /// Returns raw JSON response string on success.
  /// Throws [SavedCardsException] on errors.
  Future<String> fetchSavedCards() async {
    if (kDebugMode) {
      debugPrint('SavedCardsApiClient: Fetching saved cards');
    }

    try {
      final response = await _networkService.request<String>(
        Api.savedCardsUrl,
        method: HttpMethod.get,
      );

      if (kDebugMode) {
        debugPrint(
          'SavedCardsApiClient: Saved cards status=${response.statusCode}',
        );
      }

      if (response.data is String) {
        return response.data!;
      } else {
        return jsonEncode(response.data);
      }
    } on NetworkException catch (e) {
      throw _mapNetworkExceptionToSavedCardsException(e);
    } catch (e) {
      throw SavedCardsException(
        type: SavedCardsErrorType.unknown,
        statusCode: 0,
        serverMessage: e.toString(),
      );
    }
  }

  /// Fetches the currently selected auto-pay (postpaid) card token.
  ///
  /// Returns `null` when no card is configured (404 or empty token).
  Future<String?> fetchAutoPayToken() => _fetchSelectedToken(
        url: Api.creditCardAutoRenew,
        debugLabel: 'auto-pay',
      );

  /// Fetches the currently selected auto-renew (prepaid) card token.
  ///
  /// Returns `null` when no card is configured (404 or empty token).
  Future<String?> fetchAutoRenewToken() => _fetchSelectedToken(
        url: Api.creditCardAutoRenew,
        debugLabel: 'auto-renew',
      );

  Future<String?> _fetchSelectedToken({
    required String url,
    required String debugLabel,
  }) async {
    try {
      final response = await _networkService.request<dynamic>(
        url,
        method: HttpMethod.get,
      );

      Map<String, dynamic>? decoded;
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        decoded = raw;
      } else if (raw is String && raw.isNotEmpty) {
        final parsed = jsonDecode(raw);
        if (parsed is Map<String, dynamic>) decoded = parsed;
      }

      final token = decoded?['Token'] as String?;
      if (token == null || token.trim().isEmpty) return null;
      return token.trim();
    } on NetworkException catch (e) {
      if (e.statusCode == 404) return null;
      throw _mapNetworkExceptionToSavedCardsException(e);
    } catch (e) {
      throw SavedCardsException(
        type: SavedCardsErrorType.unknown,
        statusCode: 0,
        serverMessage: 'Failed to fetch $debugLabel token: $e',
      );
    }
  }

  /// Deletes a saved card by token.
  ///
  /// DELETE [Api.savedCardsUrl] with body `{"token": "..."}`.
  /// Returns `true` when the server reports `{"Success": true}`.
  Future<bool> deleteCard(String token) async {
    if (kDebugMode) {
      debugPrint('SavedCardsApiClient: Deleting card $token');
    }

    try {
      final response = await _networkService.request<dynamic>(
        Api.savedCardsUrl,
        method: HttpMethod.delete,
        data: {'token': token},
      );

      if (kDebugMode) {
        debugPrint(
          'SavedCardsApiClient: Delete card status=${response.statusCode}',
        );
      }

      Map<String, dynamic>? decoded;
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        decoded = raw;
      } else if (raw is String && raw.isNotEmpty) {
        final parsed = jsonDecode(raw);
        if (parsed is Map<String, dynamic>) decoded = parsed;
      }

      if (decoded == null) {
        throw const SavedCardsException(
          type: SavedCardsErrorType.invalidResponse,
          serverMessage: 'Invalid delete response',
        );
      }

      return decoded['Success'] == true;
    } on NetworkException catch (e) {
      throw _mapNetworkExceptionToSavedCardsException(e);
    } on SavedCardsException {
      rethrow;
    } catch (e) {
      throw SavedCardsException(
        type: SavedCardsErrorType.unknown,
        statusCode: 0,
        serverMessage: e.toString(),
      );
    }
  }

  SavedCardsException _mapNetworkExceptionToSavedCardsException(
    NetworkException e,
  ) {
    if (e is TimeoutException) {
      return SavedCardsException(
        type: SavedCardsErrorType.timeout,
        statusCode: e.statusCode ?? 408,
        serverMessage: e.message,
      );
    }

    if (e is HostUnreachableException) {
      return SavedCardsException(
        type: SavedCardsErrorType.noInternet,
        statusCode: 0,
        serverMessage: e.message,
      );
    }

    if (e is NoInternetException) {
      return SavedCardsException(
        type: SavedCardsErrorType.noInternet,
        statusCode: 0,
        serverMessage: e.message,
      );
    }

    if (e is SessionExpiredException) {
      return SavedCardsException(
        type: SavedCardsErrorType.unauthorized,
        statusCode: 401,
        serverMessage: e.message,
      );
    }

    if (e is ServerException) {
      return SavedCardsException(
        type: SavedCardsErrorType.server,
        statusCode: e.statusCode ?? 500,
        serverMessage: e.message,
      );
    }

    final statusCode = e.statusCode ?? 0;

    switch (statusCode) {
      case 401:
        return SavedCardsException(
          type: SavedCardsErrorType.unauthorized,
          statusCode: statusCode,
          serverMessage: e.message,
        );
      case 404:
        return SavedCardsException(
          type: SavedCardsErrorType.notFound,
          statusCode: statusCode,
          serverMessage: e.message,
        );
      case 408:
        return SavedCardsException(
          type: SavedCardsErrorType.timeout,
          statusCode: statusCode,
          serverMessage: e.message,
        );
      default:
        if (statusCode >= 500) {
          return SavedCardsException(
            type: SavedCardsErrorType.server,
            statusCode: statusCode,
            serverMessage: e.message,
          );
        } else if (statusCode >= 400) {
          return SavedCardsException(
            type: SavedCardsErrorType.badResponse,
            statusCode: statusCode,
            serverMessage: e.message,
          );
        }
        return SavedCardsException(
          type: SavedCardsErrorType.unknown,
          statusCode: statusCode,
          serverMessage: e.message,
        );
    }
  }
}
