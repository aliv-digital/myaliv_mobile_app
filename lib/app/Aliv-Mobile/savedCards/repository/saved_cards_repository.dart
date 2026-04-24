import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/saved_card_model.dart';
import 'saved_cards_exception.dart';
import 'services/saved_cards_api_client.dart';

/// Abstract repository interface for saved cards operations.
abstract class SavedCardsRepository {
  /// Fetches saved credit cards from the API.
  Future<List<SavedCardModel>> fetchSavedCards();
}

/// Implementation of [SavedCardsRepository].
class SavedCardsRepositoryImpl implements SavedCardsRepository {
  SavedCardsRepositoryImpl({
    required SavedCardsApiClient apiClient,
  }) : _apiClient = apiClient;

  final SavedCardsApiClient _apiClient;

  @override
  Future<List<SavedCardModel>> fetchSavedCards() async {
    if (kDebugMode) {
      debugPrint('SavedCardsRepository: Fetching saved cards');
    }

    final rawJson = await _apiClient.fetchSavedCards();
    final cards = _parseCards(rawJson);

    if (kDebugMode) {
      debugPrint('SavedCardsRepository: Parsed ${cards.length} cards');
    }

    return cards;
  }

  /// Parses the raw JSON response into a list of [SavedCardModel].
  ///
  /// Expected response format:
  /// ```json
  /// {
  ///   "Cards": [
  ///     { "Token": "...", "Number": "*3686" },
  ///     { "Token": "...", "Number": "*8244" }
  ///   ]
  /// }
  /// ```
  List<SavedCardModel> _parseCards(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);

      if (decoded is! Map<String, dynamic>) {
        throw const SavedCardsException(
          type: SavedCardsErrorType.invalidResponse,
          serverMessage: 'Invalid response format: expected object',
        );
      }

      final cardsRaw = decoded['Cards'];

      // Handle null or non-list Cards field
      if (cardsRaw == null) {
        return [];
      }

      if (cardsRaw is! List) {
        throw const SavedCardsException(
          type: SavedCardsErrorType.invalidResponse,
          serverMessage: 'Invalid Cards format: expected array',
        );
      }

      final List<SavedCardModel> cards = [];

      for (final item in cardsRaw) {
        if (item is Map<String, dynamic>) {
          cards.add(SavedCardModel.fromJson(item));
        } else {
          // Skip malformed items but log in debug mode
          if (kDebugMode) {
            debugPrint('SavedCardsRepository: Skipping malformed card item: $item');
          }
        }
      }

      return cards;
    } catch (e) {
      if (e is SavedCardsException) rethrow;

      throw SavedCardsException(
        type: SavedCardsErrorType.invalidResponse,
        serverMessage: 'Failed to parse saved cards response',
        debugMessage: e.toString(),
      );
    }
  }
}
