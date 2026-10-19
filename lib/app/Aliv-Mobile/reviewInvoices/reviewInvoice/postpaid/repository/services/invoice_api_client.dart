import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

/// Handles API calls for invoice operations.
///
/// Uses NetworkService which automatically handles Basic Auth from GlobalState.
class InvoiceApiClient {
  InvoiceApiClient({NetworkService? networkService})
    : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  /// Fetches invoices for the current account.
  ///
  /// Returns raw JSON response string on success.
  /// Throws [NetworkException] on errors.
  Future<String> fetchInvoices() async {
    if (kDebugMode) {
      debugPrint('InvoiceApiClient: Fetching invoices from ${Api.invoices}');
    }

    try {
      final response = await _networkService.request<String>(
        Api.invoices,
        method: HttpMethod.get,
      );

      if (kDebugMode) {
        debugPrint('InvoiceApiClient: Response status=${response.statusCode}');
      }

      if (response.data is String) {
        return response.data!;
      } else {
        return jsonEncode(response.data);
      }
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to fetch invoices: $e');
    }
  }

  /// Fetches invoice PDF as base64 string.
  ///
  /// Parameters:
  /// - [invoiceId]: The invoice ID
  /// - [filename]: The file path from the invoice (will be URL encoded)
  ///
  /// API Response format:
  /// ```json
  /// {"InvoiceFile": "JVBERi0xLjcNCiXi48/TDQo..."}
  /// ```
  ///
  /// Returns base64 encoded PDF string on success.
  /// Throws [NetworkException] on errors.
  Future<String> fetchInvoicePdf({
    required int invoiceId,
    required String filename,
  }) async {
    final url = Api.invoicePdf(invoiceId, filename);

    if (kDebugMode) {
      debugPrint('InvoiceApiClient: Fetching PDF from $url');
    }

    try {
      final response = await _networkService.request<String>(
        url,
        method: HttpMethod.get,
      );

      if (kDebugMode) {
        debugPrint(
          'InvoiceApiClient: PDF response status=${response.statusCode}',
        );
      }

      // Parse JSON response and extract InvoiceFile
      String rawResponse;
      if (response.data is String) {
        rawResponse = response.data!;
      } else {
        rawResponse = jsonEncode(response.data);
      }

      final decoded = jsonDecode(rawResponse);
      if (decoded is Map<String, dynamic> && decoded['InvoiceFile'] != null) {
        return decoded['InvoiceFile'] as String;
      }

      throw Exception('Invalid response: InvoiceFile not found');
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to fetch invoice PDF: $e');
    }
  }
}
