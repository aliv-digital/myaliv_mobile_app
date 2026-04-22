import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/cubit/review_invoice_postpaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/models/invoice_item.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/repository/review_invoice_postpaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/repository/services/invoice_pdf_service.dart';

/// Cubit for managing Review Invoice screen state.
class ReviewInvoicePostpaidCubit extends Cubit<ReviewInvoicePostpaidState> {
  ReviewInvoicePostpaidCubit({
    required ReviewInvoicePostpaidRepository repository,
    required InvoicePdfService pdfService,
  }) : _repository = repository,
       _pdfService = pdfService,
       super(const ReviewInvoicePostpaidState());

  final ReviewInvoicePostpaidRepository _repository;
  final InvoicePdfService _pdfService;

  /// Loads invoices from the API.
  Future<void> loadInvoices() async {
    emit(state.copyWith(status: ReviewInvoiceStatus.loading));

    try {
      final invoices = await _repository.fetchInvoices();
      emit(
        state.copyWith(status: ReviewInvoiceStatus.success, invoices: invoices),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ReviewInvoicePostpaidCubit: Error loading invoices: $e');
      }
      emit(
        state.copyWith(
          status: ReviewInvoiceStatus.failure,
          errorMessage: 'Failed to load invoices',
        ),
      );
    }
  }

  /// Downloads and opens the PDF for the given invoice.
  Future<void> downloadAndOpenPdf(InvoiceItem invoice) async {
    if (state.downloadingInvoiceId != null) {
      // Already downloading another invoice
      return;
    }

    emit(
      state.copyWith(
        downloadingInvoiceId: invoice.invoiceId,
        downloadError: null,
      ),
    );

    try {
      // Get the file path to use for download
      final filePath = invoice.primaryFilePath ?? invoice.invoicePath;

      if (kDebugMode) {
        debugPrint(
          'ReviewInvoicePostpaidCubit: Downloading PDF for invoice ${invoice.invoiceId}',
        );
      }

      // Download and save PDF
      final savedFilePath = await _repository.downloadInvoicePdf(
        invoiceId: invoice.invoiceId,
        filename: filePath,
        invoiceNo: invoice.invoiceNo,
      );

      // Clear downloading state
      emit(state.copyWith(clearDownloadingId: true));

      // Open the PDF
      await _pdfService.openPdf(savedFilePath);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ReviewInvoicePostpaidCubit: Error downloading PDF: $e');
      }
      emit(
        state.copyWith(
          clearDownloadingId: true,
          downloadError: 'Failed to download invoice',
        ),
      );
    }
  }

  /// Shares the PDF for the given invoice.
  Future<void> sharePdf(InvoiceItem invoice) async {
    if (state.downloadingInvoiceId != null) return;

    emit(
      state.copyWith(
        downloadingInvoiceId: invoice.invoiceId,
        downloadError: null,
      ),
    );

    try {
      final filePath = invoice.primaryFilePath ?? invoice.invoicePath;

      final savedFilePath = await _repository.downloadInvoicePdf(
        invoiceId: invoice.invoiceId,
        filename: filePath,
        invoiceNo: invoice.invoiceNo,
      );

      emit(state.copyWith(clearDownloadingId: true));

      await _pdfService.sharePdf(savedFilePath, invoice.invoiceNo);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ReviewInvoicePostpaidCubit: Error sharing PDF: $e');
      }
      emit(
        state.copyWith(
          clearDownloadingId: true,
          downloadError: 'Failed to share invoice',
        ),
      );
    }
  }

  /// Saves the PDF to the downloads folder.
  Future<void> savePdfToDownloads(InvoiceItem invoice) async {
    if (state.downloadingInvoiceId != null) return;

    emit(
      state.copyWith(
        downloadingInvoiceId: invoice.invoiceId,
        downloadError: null,
      ),
    );

    try {
      final filePath = invoice.primaryFilePath ?? invoice.invoicePath;

      final savedFilePath = await _repository.downloadInvoicePdf(
        invoiceId: invoice.invoiceId,
        filename: filePath,
        invoiceNo: invoice.invoiceNo,
      );

      emit(state.copyWith(clearDownloadingId: true));

      final success = await _pdfService.savePdfToDownloads(
        savedFilePath,
        invoice.invoiceNo,
      );

      if (!success) {
        emit(state.copyWith(downloadError: 'Failed to save to downloads'));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ReviewInvoicePostpaidCubit: Error saving PDF: $e');
      }
      emit(
        state.copyWith(
          clearDownloadingId: true,
          downloadError: 'Failed to save invoice',
        ),
      );
    }
  }

  /// Clears any download error message.
  void clearDownloadError() {
    emit(state.copyWith(downloadError: null));
  }
}
