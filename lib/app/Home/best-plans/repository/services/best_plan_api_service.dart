import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/repository/best_plan_repository_exception.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class BestPlanApiService {
  late final Dio _dio;

  BestPlanApiService() {
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

  Future<String> fetchActivePlans() async {
    const String url = Api.bestPlans;

    if (kDebugMode) {
      debugPrint('');
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 🌐 BEST PLANS API REQUEST');
      debugPrint('│ Method: GET');
      debugPrint('│ URL: $url');
      debugPrint('└─────────────────────────────────────────');
    }

    try {
      final response = await _dio.get<dynamic>(url);

      if (kDebugMode) {
        debugPrint('┌─────────────────────────────────────────');
        debugPrint('│ ✅ BEST PLANS API RESPONSE');
        debugPrint('│ Status Code: ${response.statusCode}');
        final body = response.data is String
            ? response.data as String
            : jsonEncode(response.data);
        debugPrint(
          '│ Response Body: ${body.length > 300 ? '${body.substring(0, 300)}...' : body}',
        );
        debugPrint('└─────────────────────────────────────────');
        debugPrint('');
      }

      if (response.data == null) {
        throw const BestPlanRepositoryException(
          'Empty response from server',
          type: BestPlanErrorType.server,
        );
      }

      return response.data is String
          ? response.data as String
          : jsonEncode(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('');
        debugPrint('╔══════════════════════════════════════════════════════════════');
        debugPrint('║ ❌ BEST PLANS — NETWORK FAILURE REPORT');
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
        debugPrint('║     GET mockservice.newcomobile.com/v1/MyAliv/plans/active');
        debugPrint('╚══════════════════════════════════════════════════════════════');
        debugPrint('');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw BestPlanRepositoryException(
          'Request timed out',
          type: BestPlanErrorType.timeout,
          originalError: e,
        );
      }
      if (e.type == DioExceptionType.connectionError) {
        throw BestPlanRepositoryException(
          'No internet connection',
          type: BestPlanErrorType.network,
          originalError: e,
        );
      }
      throw BestPlanRepositoryException(
        e.message ?? e.type.name,
        type: BestPlanErrorType.unknown,
        originalError: e,
      );
    } catch (e) {
      if (e is BestPlanRepositoryException) rethrow;
      if (kDebugMode) {
        debugPrint('│ ❌ BEST PLANS API ERROR: $e');
      }
      throw BestPlanRepositoryException(
        'Failed to fetch plans: ${e.toString()}',
        type: BestPlanErrorType.unknown,
        originalError: e,
      );
    }
  }
}
