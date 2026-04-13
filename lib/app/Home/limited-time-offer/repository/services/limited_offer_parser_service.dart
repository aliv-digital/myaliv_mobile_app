import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/models/limited_offer_model.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/repository/limited_offer_repository_exception.dart';

/// Service for parsing limited time offer JSON responses
///
/// Handles JSON parsing and validation of API responses.
/// Filters active offers and validates data structure.
class LimitedOfferParserService {
  /// In debug mode, automatically extend expired offers by 1 month
  /// This allows testing with expired backend data without modifying the API
  static const bool _autoExtendExpiredInDebug = true;

  /// Parse raw JSON response to list of LimitedOfferModel
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Operation successful",
  ///   "data": [
  ///     {
  ///       "id": 7,
  ///       "title": "Limited Offer",
  ///       "subHeading": "Testing",
  ///       "link": "https://www.google.com",
  ///       "type": "prepaid",
  ///       "addedOn": "2026-04-08T04:00:00.000Z",
  ///       "expireOn": "2026-04-13T04:00:00.000Z",
  ///       "status": "active"
  ///     }
  ///   ]
  /// }
  /// ```
  ///
  /// Returns list of active offers only
  /// Throws [LimitedOfferParseException] on parsing errors
  List<LimitedOfferModel> parseOffers(String jsonString) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('🔍 LIMITED OFFER PARSER: Starting to parse JSON');
    }

    try {
      // Decode JSON
      final json = jsonDecode(jsonString);

      if (kDebugMode) {
        debugPrint('✓ JSON decoded successfully');
      }

      // Validate root structure
      if (json is! Map<String, dynamic>) {
        throw const LimitedOfferParseException(
          'Invalid JSON structure: expected object',
        );
      }

      // Check success flag
      final success = json['success'] as bool? ?? false;
      if (kDebugMode) {
        debugPrint('✓ Success flag: $success');
      }

      if (!success) {
        final message = json['message'] as String? ?? 'Unknown error';
        throw LimitedOfferParseException(
          'API returned success=false: $message',
        );
      }

      // Extract data array
      final data = json['data'];
      if (data == null) {
        if (kDebugMode) {
          debugPrint('⚠️ No "data" field in response - returning empty list');
        }
        return [];
      }

      if (data is! List) {
        throw const LimitedOfferParseException(
          'Invalid data structure: expected array',
        );
      }

      if (kDebugMode) {
        debugPrint('✓ Data array found with ${data.length} items');
      }

      // Parse each offer
      final offers = <LimitedOfferModel>[];
      for (int i = 0; i < data.length; i++) {
        final item = data[i];

        if (item is! Map<String, dynamic>) {
          if (kDebugMode) {
            debugPrint('⚠️ Skipping item $i - not a valid object');
          }
          continue;
        }

        try {
          var offer = LimitedOfferModel.fromJson(item);

          if (kDebugMode && _autoExtendExpiredInDebug) {
            offer = _extendExpiredOfferForDebug(offer);
          }

          if (kDebugMode) {
            debugPrint('✓ Parsed offer: id=${offer.id}, title="${offer.title}"');
            debugPrint('  - Type: ${offer.type}');
            debugPrint('  - Status: ${offer.status}');
            debugPrint('  - Expires: ${offer.expireOn}');
            debugPrint('  - isActive: ${offer.isActive}');
            debugPrint('  - isExpired: ${offer.isExpired}');
          }

          final shouldInclude = offer.isActive;

          if (shouldInclude) {
            offers.add(offer);
            if (kDebugMode) {
              if (offer.isExpired) {
                debugPrint('  ⚠️ Added to offers list (debug extension failed)');
              } else {
                debugPrint('  ✅ Added to offers list');
              }
            }
          } else {
            if (kDebugMode) {
              debugPrint('  ❌ Skipped (not active or expired)');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Failed to parse item $i: $e');
          }
          continue;
        }
      }

      if (kDebugMode) {
        debugPrint('');
        debugPrint('📊 PARSER RESULT: ${offers.length} active offers found');
        debugPrint('');
      }

      return offers;
    } on LimitedOfferParseException {
      rethrow;
    } catch (e) {
      throw LimitedOfferParseException(
        'Failed to parse offers: ${e.toString()}',
        originalError: e,
      );
    }
  }

  LimitedOfferModel _extendExpiredOfferForDebug(LimitedOfferModel offer) {
    final isActiveStatus = offer.status.toLowerCase() == 'active';
    if (!isActiveStatus || !offer.isExpired) {
      return offer;
    }

    final now = DateTime.now();
    final extendedExpireOn = DateTime(
      now.year,
      now.month + 1,
      now.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );

    if (kDebugMode) {
      debugPrint('  🛠️ Debug mode: extended expired offer by 1 month');
      debugPrint('  - Original expireOn: ${offer.expireOn}');
      debugPrint('  - Extended expireOn: $extendedExpireOn');
    }

    return offer.copyWith(expireOn: extendedExpireOn);
  }
}
