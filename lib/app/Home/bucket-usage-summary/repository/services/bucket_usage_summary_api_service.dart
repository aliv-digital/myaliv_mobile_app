import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/repository/bucket_usage_summary_exception.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

/// Makes the HTTP request for the bucket usage summary endpoint.
///
/// NetworkService adds the current auth headers automatically.
class BucketUsageSummaryApiService {
  final NetworkService _networkService;

  BucketUsageSummaryApiService({NetworkService? networkService})
    : _networkService = networkService ?? instance<NetworkService>();

  /// Fetch the raw bucket usage summary response for one device account.
  Future<String> fetchBucketUsageSummary({required int deviceAccountId}) async {
    final url = Api.bucketUsageSummary(deviceAccountId);

    if (kDebugMode) {
      debugPrint('');
      debugPrint('BucketUsageSummaryApiService: GET $url');
      debugPrint(
        'BucketUsageSummaryApiService: deviceAccountId=$deviceAccountId',
      );
    }

    try {
      final response = await _networkService.request<String>(
        url,
        method: HttpMethod.get,
      );

      final rawResponse = _responseDataToString(response.data);

      if (kDebugMode) {
        debugPrint(
          'BucketUsageSummaryApiService: status=${response.statusCode}',
        );
        _debugPrintFullResponse(rawResponse);
        debugPrint('');
      }

      return rawResponse;
    } on NetworkException catch (e) {
      throw _mapNetworkException(e);
    } catch (e) {
      throw BucketUsageSummaryException(
        'Failed to fetch bucket usage summary: ${e.toString()}',
        originalError: e,
      );
    }
  }

  String _responseDataToString(dynamic data) {
    if (data == null) {
      return '';
    }

    if (data is String) {
      return data;
    }

    return jsonEncode(data);
  }

  void _debugPrintFullResponse(String rawResponse) {
    const chunkSize = 800;

    debugPrint('BucketUsageSummaryApiService: full response start');

    if (rawResponse.isEmpty) {
      debugPrint('(empty response)');
    } else {
      for (int start = 0; start < rawResponse.length; start += chunkSize) {
        final end = (start + chunkSize < rawResponse.length)
            ? start + chunkSize
            : rawResponse.length;
        debugPrint(rawResponse.substring(start, end));
      }
    }

    debugPrint('BucketUsageSummaryApiService: full response end');
  }

  BucketUsageSummaryException _mapNetworkException(NetworkException e) {
    if (e is TimeoutException) {
      return BucketUsageSummaryException(
        'Request timed out',
        type: BucketUsageSummaryErrorType.timeout,
        originalError: e,
      );
    }

    if (e is HostUnreachableException || e is NoInternetException) {
      return BucketUsageSummaryException(
        e.message,
        type: BucketUsageSummaryErrorType.network,
        originalError: e,
      );
    }

    if (e is SessionExpiredException) {
      return BucketUsageSummaryException(
        'Session expired. Please login again',
        type: BucketUsageSummaryErrorType.sessionExpired,
        originalError: e,
      );
    }

    if (e is ServerException) {
      return BucketUsageSummaryException(
        'Server error occurred',
        type: BucketUsageSummaryErrorType.server,
        originalError: e,
      );
    }

    final statusCode = e.statusCode ?? 0;

    if (statusCode == 401 || statusCode == 403) {
      return BucketUsageSummaryException(
        'Authentication failed',
        type: BucketUsageSummaryErrorType.sessionExpired,
        originalError: e,
      );
    }

    if (statusCode == 404) {
      return BucketUsageSummaryException(
        'Bucket usage summary not found',
        type: BucketUsageSummaryErrorType.notFound,
        originalError: e,
      );
    }

    if (statusCode >= 500) {
      return BucketUsageSummaryException(
        'Server error occurred',
        type: BucketUsageSummaryErrorType.server,
        originalError: e,
      );
    }

    return BucketUsageSummaryException(
      'Network error: ${e.message}',
      type: BucketUsageSummaryErrorType.network,
      originalError: e,
    );
  }
}
