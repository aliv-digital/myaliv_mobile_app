import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/models/invoice_item.dart';

/// Status for the review invoice screen.
enum ReviewInvoiceStatus { initial, loading, success, failure }

/// State for the Review Invoice Postpaid screen.
class ReviewInvoicePostpaidState extends Equatable {
  const ReviewInvoicePostpaidState({
    this.status = ReviewInvoiceStatus.initial,
    this.invoices = const [],
    this.errorMessage,
    this.downloadingInvoiceId,
    this.downloadError,
  });

  /// Current status of the invoice list loading.
  final ReviewInvoiceStatus status;

  /// List of invoices.
  final List<InvoiceItem> invoices;

  /// Error message when loading fails.
  final String? errorMessage;

  /// Invoice ID currently being downloaded (null if not downloading).
  final int? downloadingInvoiceId;

  /// Error message when PDF download fails.
  final String? downloadError;

  /// Returns true if invoices are being loaded.
  bool get isLoading => status == ReviewInvoiceStatus.loading;

  /// Returns true if a PDF is currently being downloaded.
  bool get isDownloading => downloadingInvoiceId != null;

  /// Checks if a specific invoice is being downloaded.
  bool isDownloadingInvoice(int invoiceId) =>
      downloadingInvoiceId == invoiceId;

  ReviewInvoicePostpaidState copyWith({
    ReviewInvoiceStatus? status,
    List<InvoiceItem>? invoices,
    String? errorMessage,
    int? downloadingInvoiceId,
    bool clearDownloadingId = false,
    String? downloadError,
  }) {
    return ReviewInvoicePostpaidState(
      status: status ?? this.status,
      invoices: invoices ?? this.invoices,
      errorMessage: errorMessage,
      downloadingInvoiceId:
          clearDownloadingId ? null : (downloadingInvoiceId ?? this.downloadingInvoiceId),
      downloadError: downloadError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        invoices,
        errorMessage,
        downloadingInvoiceId,
        downloadError,
      ];
}
