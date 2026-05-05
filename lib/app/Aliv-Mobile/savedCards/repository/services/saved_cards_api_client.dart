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
