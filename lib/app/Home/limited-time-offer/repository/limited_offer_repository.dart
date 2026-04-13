import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/models/limited_offer_model.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/repository/limited_offer_repository_exception.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/repository/services/limited_offer_api_service.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/repository/services/limited_offer_parser_service.dart';

/// Abstract repository interface for Limited Time Offers
abstract class LimitedOfferRepository {
  /// Fetch active limited time offers
  ///
  /// Returns list of active offers for the specified user type
  /// Throws [LimitedOfferRepositoryException] on errors
  Future<List<LimitedOfferModel>> fetchActiveOffers({
    String userType = 'prepaid',
  });
}

/// Concrete implementation of LimitedOfferRepository
///
/// Orchestrates API service and parser service to fetch and parse offers.
/// Filters offers by user type (prepaid/postpaid).
class LimitedOfferRepositoryImpl implements LimitedOfferRepository {
  final LimitedOfferApiService _apiService;
  final LimitedOfferParserService _parserService;

  LimitedOfferRepositoryImpl({
    required LimitedOfferApiService apiService,
    required LimitedOfferParserService parserService,
  })  : _apiService = apiService,
        _parserService = parserService;

  @override
  Future<List<LimitedOfferModel>> fetchActiveOffers({
    String userType = 'prepaid',
  }) async {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('📦 LIMITED OFFER REPOSITORY: fetchActiveOffers()');
      debugPrint('   User Type: $userType');
    }

    try {
      // 1. Fetch raw JSON from API
      if (kDebugMode) {
        debugPrint('   Step 1: Fetching from API...');
      }
      final rawJson = await _apiService.fetchActiveOffers();

      // 2. Parse JSON to models
      if (kDebugMode) {
        debugPrint('   Step 2: Parsing JSON...');
      }
      final allOffers = _parserService.parseOffers(rawJson);

      if (kDebugMode) {
        debugPrint('   ✓ Parsed ${allOffers.length} total offers');
      }

      // 3. Filter by user type
      if (kDebugMode) {
        debugPrint('   Step 3: Filtering by user type "$userType"...');
      }
      final filteredOffers = allOffers
          .where((offer) => offer.type.toLowerCase() == userType.toLowerCase())
          .toList();

      if (kDebugMode) {
        debugPrint('   ✓ Filtered to ${filteredOffers.length} offers for $userType');
        for (final offer in filteredOffers) {
          debugPrint('     - ${offer.title} (id: ${offer.id})');
        }
        debugPrint('   ✅ Repository returning ${filteredOffers.length} offers');
        debugPrint('');
      }

      return filteredOffers;
    } on LimitedOfferApiException catch (e) {
      // Map API exceptions to repository exceptions
      final errorType = _mapApiErrorType(e.statusCode);
      throw LimitedOfferRepositoryException(
        type: errorType,
        message: e.message,
        originalError: e,
      );
    } on LimitedOfferParseException catch (e) {
      // Map parser exceptions to repository exceptions
      throw LimitedOfferRepositoryException(
        type: LimitedOfferErrorType.parsing,
        message: e.message,
        originalError: e,
      );
    } catch (e) {
      // Handle unexpected errors
      throw LimitedOfferRepositoryException(
        type: LimitedOfferErrorType.unknown,
        message: 'Unexpected error: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Map HTTP status codes to error types
  LimitedOfferErrorType _mapApiErrorType(int? statusCode) {
    if (statusCode == null) {
      return LimitedOfferErrorType.network;
    }

    switch (statusCode) {
      case 404:
        return LimitedOfferErrorType.notFound;
      case 408:
      case 504:
        return LimitedOfferErrorType.timeout;
      case >= 500:
        return LimitedOfferErrorType.server;
      default:
        return LimitedOfferErrorType.network;
    }
  }
}
