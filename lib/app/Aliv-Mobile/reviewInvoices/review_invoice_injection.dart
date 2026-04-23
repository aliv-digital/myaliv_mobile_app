import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/cubit/review_invoice_postpaid_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/repository/review_invoice_postpaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/repository/services/invoice_api_client.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/repository/services/invoice_pdf_service.dart';

/// Sets up dependency injection for Review Invoice feature.
///
/// Registers:
/// - InvoiceApiClient (API layer)
/// - InvoicePdfService (PDF operations)
/// - ReviewInvoicePostpaidRepositoryImpl (data layer)
/// - ReviewInvoicePostpaidCubit (state management)
Future<void> setupReviewInvoiceInjection() async {
  // Register Invoice API client
  if (!instance.isRegistered<InvoiceApiClient>()) {
    instance.registerLazySingleton<InvoiceApiClient>(
      () => InvoiceApiClient(networkService: instance<NetworkService>()),
    );
  }

  // Register Invoice PDF service
  if (!instance.isRegistered<InvoicePdfService>()) {
    instance.registerLazySingleton<InvoicePdfService>(
      () => InvoicePdfService(),
    );
  }

  // Register Invoice repository
  if (!instance.isRegistered<ReviewInvoicePostpaidRepository>()) {
    instance.registerLazySingleton<ReviewInvoicePostpaidRepository>(
      () => ReviewInvoicePostpaidRepositoryImpl(
        apiClient: instance<InvoiceApiClient>(),
        pdfService: instance<InvoicePdfService>(),
      ),
    );
  }

  // Register Invoice cubit as factory (new instance per screen)
  if (!instance.isRegistered<ReviewInvoicePostpaidCubit>()) {
    instance.registerFactory<ReviewInvoicePostpaidCubit>(
      () => ReviewInvoicePostpaidCubit(
        repository: instance<ReviewInvoicePostpaidRepository>(),
        pdfService: instance<InvoicePdfService>(),
      ),
    );
  }
}
