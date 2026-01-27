import 'package:flutter_bloc/flutter_bloc.dart';
import 'review_invoice_postpaid_event.dart';
import 'review_invoice_postpaid_state.dart';
import '../repository/review_invoice_postpaid_repository.dart';

class ReviewInvoicePostpaidBloc
    extends Bloc<ReviewInvoicePostpaidEvent, ReviewInvoicePostpaidState> {
  final ReviewInvoicePostpaidRepository repository;

  ReviewInvoicePostpaidBloc({required this.repository})
      : super(ReviewInvoicePostpaidState.initial()) {
    on<ReviewInvoicePostpaidStarted>(_onStarted);
    on<PostpaidInvoicePressed>(_onInvoicePressed);
  }

  Future<void> _onStarted(
      ReviewInvoicePostpaidStarted event,
      Emitter<ReviewInvoicePostpaidState> emit,
      ) async {
    emit(state.copyWith(status: ReviewInvoicePostpaidStatus.loading, errorMessage: null));
    try {
      final invoices = await repository.fetchInvoices();
      emit(state.copyWith(status: ReviewInvoicePostpaidStatus.success, invoices: invoices));
    } catch (e) {
      emit(state.copyWith(
        status: ReviewInvoicePostpaidStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onInvoicePressed(
      PostpaidInvoicePressed event,
      Emitter<ReviewInvoicePostpaidState> emit,
      ) {
    // Future: download/open actions
    emit(state.copyWith(lastPressed: event.invoice));
  }
}
