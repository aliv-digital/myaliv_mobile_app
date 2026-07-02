import 'dart:convert';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
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

  /// Adds a credit card and returns the server-issued card token.
  Future<String> addCreditCard(NewCardDetails details) async {
    if (kDebugMode) {
      debugPrint('SavedCardsApiClient: Adding credit card');
    }

    try {
      final response = await _networkService.request<dynamic>(
        Api.addCreditCard,
        method: HttpMethod.post,
        data: _addCardPayload(details),
        options: Options(
          extra: const <String, Object?>{
            networkLogRedactedFieldsExtraKey: <String>[
              'Number',
              'Name',
              'SecurityCode',
              'Token',
            ],
          },
        ),
      );

      final responseMap = _decodeMap(response.data);
      final token =
          (responseMap['Token'] ?? responseMap['token'])?.toString().trim() ??
              '';
      if (token.isEmpty) {
        throw const SavedCardsException(
          type: SavedCardsErrorType.invalidResponse,
          serverMessage: 'Card token missing in add-card response',
        );
      }

      if (kDebugMode) {
        debugPrint(
          'SavedCardsApiClient: Add card status=${response.statusCode}',
        );
      }
      return token;
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

  Map<String, dynamic> _addCardPayload(NewCardDetails details) {
    final expirationParts = details.cardExpiration.split('-');
    final expirationYear =
        expirationParts.length == 2 ? int.tryParse(expirationParts[0]) : null;
    final expirationMonth =
        expirationParts.length == 2 ? int.tryParse(expirationParts[1]) : null;

    if (expirationYear == null ||
        expirationMonth == null ||
        expirationMonth < 1 ||
        expirationMonth > 12) {
      throw const SavedCardsException(
        type: SavedCardsErrorType.badResponse,
        serverMessage: 'Invalid card expiration date',
      );
    }

    return <String, dynamic>{
      'Number': details.cardNumber,
      'Name': details.cardHolderName,
      'ExpirationMonth': expirationMonth,
      'ExpirationYear': expirationYear,
      'SecurityCode': details.cardSecurityCode,
    };
  }

  Map<String, dynamic> _decodeMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    if (data is String && data.trim().isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    }
    return <String, dynamic>{};
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
