import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/repository/limited_offer_repository_exception.dart';

class LimitedOfferApiService {
  late final Dio _dio;

  LimitedOfferApiService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
        },
      ),
    );
  }

  Future<String> fetchActiveOffers() async {
    const String url = Api.adsTimer;

    if (kDebugMode) {
      debugPrint('');
      debugPrint('┌─────────────────────────────────────────────────────────────');
      debugPrint('│ 🌐 LIMITED OFFER API REQUEST');
      debugPrint('├─────────────────────────────────────────────────────────────');
      debugPrint('│ Method: GET');
      debugPrint('│ URL: $url');
      debugPrint('└─────────────────────────────────────────────────────────────');
    }

    try {
      final response = await _dio.get<dynamic>(url);

      if (kDebugMode) {
        debugPrint('');
        debugPrint('┌─────────────────────────────────────────────────────────────');
        debugPrint('│ ✅ LIMITED OFFER API RESPONSE');
        debugPrint('├─────────────────────────────────────────────────────────────');
        debugPrint('│ Status Code: ${response.statusCode}');
        final body = response.data is String
            ? response.data as String
            : jsonEncode(response.data);
        debugPrint(
          '│ Response Body: ${body.length > 300 ? '${body.substring(0, 300)}...' : body}',
        );
        debugPrint('└─────────────────────────────────────────────────────────────');
        debugPrint('');
      }

      if (response.data == null) {
        throw const LimitedOfferApiException(
          statusCode: 204,
          message: 'Empty response from server',
        );
      }

      return response.data is String
          ? response.data as String
          : jsonEncode(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('');
        debugPrint('╔══════════════════════════════════════════════════════════════');
        debugPrint('║ ❌ LIMITED OFFER — NETWORK FAILURE REPORT');
        debugPrint('╠══════════════════════════════════════════════════════════════');
        debugPrint('║ Endpoint   : $url');
        debugPrint('║ Error Type : ${e.type.name}');
        debugPrint('║ Error Msg  : ${e.message}');
        debugPrint('║ Status Code: ${e.response?.statusCode ?? 'N/A (no response)'}');
        debugPrint('║ ─────────────────────────────────────────────────────────────');
        debugPrint('║ DIAGNOSIS  : Cloudflare JA3/TLS fingerprint block.');
        debugPrint('║   • Android Chrome  → uses system TLS stack → ✅ allowed');
        debugPrint('║   • Flutter (Dart)  → uses own BoringSSL TLS → ❌ blocked');
        debugPrint('║   • User-Agent header has NO effect (block is at TLS layer,');
        debugPrint('║     before any HTTP headers are sent).');
        debugPrint('║ ─────────────────────────────────────────────────────────────');
        debugPrint('║ FIX NEEDED (backend):');
        debugPrint('║   Option A — Disable Cloudflare Bot Protection for:');
        debugPrint('║     https://myalivappuat-api.bealiv.com');
        debugPrint('║   Option B — Proxy these endpoints through the existing');
        debugPrint('║     authenticated API server so the app calls the same');
        debugPrint('║     domain as all other requests:');
        debugPrint('║     GET mockservice.newcomobile.com/v1/MyAliv/ads-timer/active');
        debugPrint('╚══════════════════════════════════════════════════════════════');
        debugPrint('');
      }
      throw LimitedOfferApiException(
        statusCode: e.response?.statusCode,
        message: e.message ?? e.type.name,
      );
    } catch (e) {
      if (e is LimitedOfferApiException) rethrow;
      if (kDebugMode) {
        debugPrint('❌ LIMITED OFFER API EXCEPTION: $e');
      }
      throw LimitedOfferApiException(
        statusCode: null,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
