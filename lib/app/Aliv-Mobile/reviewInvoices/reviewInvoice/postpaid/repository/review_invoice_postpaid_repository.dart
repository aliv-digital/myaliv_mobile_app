import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/models/invoice_item.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/repository/services/invoice_api_client.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/repository/services/invoice_pdf_service.dart';

/// Repository interface for fetching invoices.
abstract class ReviewInvoicePostpaidRepository {
  /// Fetches all invoices for the current account.
  Future<List<InvoiceItem>> fetchInvoices();

  /// Downloads invoice PDF and returns the local file path.
  Future<String> downloadInvoicePdf({
    required int invoiceId,
    required String filename,
    required String invoiceNo,
  });
}

/// Implementation of [ReviewInvoicePostpaidRepository] using API client.
///
/// Handles data fetching and parsing from the invoices API.
class ReviewInvoicePostpaidRepositoryImpl
    implements ReviewInvoicePostpaidRepository {
  ReviewInvoicePostpaidRepositoryImpl({
    InvoiceApiClient? apiClient,
    InvoicePdfService? pdfService,
  }) : _apiClient = apiClient ?? InvoiceApiClient(),
       _pdfService = pdfService ?? InvoicePdfService();

  final InvoiceApiClient _apiClient;
  final InvoicePdfService _pdfService;

  @override
  Future<List<InvoiceItem>> fetchInvoices() async {
    if (kDebugMode) {
      debugPrint('ReviewInvoicePostpaidRepository: Fetching invoices');
    }

    final rawJson = await _apiClient.fetchInvoices();
    final invoices = _parseInvoices(rawJson);

    if (kDebugMode) {
      debugPrint(
        'ReviewInvoicePostpaidRepository: Parsed ${invoices.length} invoices',
      );
    }

    return invoices;
  }

  @override
  Future<String> downloadInvoicePdf({
    required int invoiceId,
    required String filename,
    required String invoiceNo,
  }) async {
    if (kDebugMode) {
      debugPrint(
        'ReviewInvoicePostpaidRepository: Downloading PDF for invoice $invoiceId',
      );
    }

    // Fetch base64 PDF from API
    final base64Pdf = await _apiClient.fetchInvoicePdf(
      invoiceId: invoiceId,
      filename: filename,
    );

    // Decode and save to cache (uses invoiceId for unique filename)
    final filePath = await _pdfService.decodeAndSavePdf(base64Pdf, invoiceId);

    if (kDebugMode) {
      debugPrint('ReviewInvoicePostpaidRepository: PDF saved to $filePath');
    }

    return filePath;
  }

  /// Parses JSON response into list of InvoiceItem.
  List<InvoiceItem> _parseInvoices(String rawJson) {
    final decoded = jsonDecode(rawJson);

    if (decoded is List) {
      final invoices = decoded
          .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
          .toList();
      // Sort by invoice date descending (newest first)
      invoices.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
      return invoices;
    }

    return [];
  }
}
