import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/payment_request.dart';
import '../models/payment_result.dart';
import '../repository/payment_iframe_exception.dart';
import '../repository/payment_iframe_repository.dart';
import 'payment_iframe_state.dart';

class PaymentIFrameCubit extends Cubit<PaymentIFrameState> {
  PaymentIFrameCubit(this._repository) : super(const PaymentIFrameState());

  final PaymentIFrameRepository _repository;

  // Stored from the initiating request so onRedirectReceived can use it.
  String? _orderVerificationUrl;
  bool _verificationRequiresAuth = false;

  /// Kicks off the payment flow: POSTs to the API and emits [PaymentIFrameStatus.ready]
  /// with the HTML content when successful.
  Future<void> initiate(PaymentRequest request) async {
    if (state.isLoading) return;

    _orderVerificationUrl = request.orderVerificationUrl;
    _verificationRequiresAuth = request.requiresAuth;
    emit(state.copyWith(status: PaymentIFrameStatus.loading, clearError: true));

    try {
      final html = await _repository.fetchPaymentHtml(request);
      emit(state.copyWith(status: PaymentIFrameStatus.ready, htmlContent: html));
    } on PaymentIFrameException catch (e) {
      if (kDebugMode) debugPrint('❌ PaymentIFrameCubit: ${e.message}');
      emit(state.copyWith(
        status: PaymentIFrameStatus.failure,
        errorMessage: _friendlyMessage(e),
      ));
    } catch (e) {
      if (kDebugMode) debugPrint('❌ PaymentIFrameCubit unexpected: $e');
      emit(state.copyWith(
        status: PaymentIFrameStatus.failure,
        errorMessage: 'Payment failed. Please try again.',
      ));
    }
  }

  /// Called by the WebView when it intercepts the redirect URI.
  ///
  /// When [PaymentRequest.orderVerificationUrl] was provided and `OrderID` is
  /// present in the redirect, emits [PaymentIFrameStatus.verifying] and calls
  /// `GET orderVerificationUrl?orderId=` to get the authoritative result.
  /// Success is determined by `OrderStatus == "Completed"`.
  ///
  /// Falls back to the redirect URI's `status` query parameter when either
  /// `OrderID` or `orderVerificationUrl` is absent.
  Future<void> onRedirectReceived(Uri redirectUri) async {
    // Guard against duplicate fires from the WebView.
    if (state.isSuccess || state.isFailure || state.isVerifying) return;

    final params = redirectUri.queryParameters;
    final orderId = params['OrderID'] ?? params['orderId'];

    if (kDebugMode) {
      debugPrint('💳 PaymentIFrameCubit: redirect received — orderId=$orderId verificationUrl=$_orderVerificationUrl');
    }

    if (orderId != null && _orderVerificationUrl != null) {
      await _verifyWithServer(
        orderId: orderId,
        params: params,
        requiresAuth: _verificationRequiresAuth,
      );
    } else {
      _resolveFromRedirectParams(params: params, orderId: orderId);
    }
  }

  Future<void> _verifyWithServer({
    required String orderId,
    required Map<String, String> params,
    required bool requiresAuth,
  }) async {
    emit(state.copyWith(status: PaymentIFrameStatus.verifying));

    try {
      final order = await _repository.fetchOrderStatus(
        orderVerificationUrl: _orderVerificationUrl!,
        orderId: orderId,
        requiresAuth: requiresAuth,
      );

      if (isClosed) return;

      if (kDebugMode) {
        debugPrint('💳 PaymentIFrameCubit: OrderStatus=${order.orderStatus} isCompleted=${order.isCompleted}');
      }

      if (order.isCompleted) {
        emit(state.copyWith(
          status: PaymentIFrameStatus.success,
          result: PaymentSuccess(orderId: orderId, queryParams: params),
        ));
      } else {
        final message = params['message'] ?? params['error'] ?? 'Payment was not completed.';
        emit(state.copyWith(
          status: PaymentIFrameStatus.failure,
          result: PaymentFailure(message),
          errorMessage: message,
        ));
      }
    } on PaymentIFrameException catch (e) {
      if (isClosed) return;
      if (kDebugMode) debugPrint('❌ PaymentIFrameCubit: order verify failed — ${e.message}');
      emit(state.copyWith(
        status: PaymentIFrameStatus.failure,
        errorMessage: _friendlyMessage(e),
      ));
    } catch (e) {
      if (isClosed) return;
      if (kDebugMode) debugPrint('❌ PaymentIFrameCubit: order verify unexpected — $e');
      emit(state.copyWith(
        status: PaymentIFrameStatus.failure,
        errorMessage: 'Failed to verify payment. Please try again.',
      ));
    }
  }

  void _resolveFromRedirectParams({
    required Map<String, String> params,
    required String? orderId,
  }) {
    final status = (params['status'] ?? '').toLowerCase();

    if (kDebugMode) {
      debugPrint('💳 PaymentIFrameCubit: fallback to redirect params — status=$status');
    }

    if (status == 'success' || status == 'completed') {
      emit(state.copyWith(
        status: PaymentIFrameStatus.success,
        result: PaymentSuccess(orderId: orderId, queryParams: params),
      ));
    } else {
      final message = params['message'] ?? params['error'] ?? 'Payment was not completed.';
      emit(state.copyWith(
        status: PaymentIFrameStatus.failure,
        result: PaymentFailure(message),
        errorMessage: message,
      ));
    }
  }

  void reset() {
    _orderVerificationUrl = null;
    _verificationRequiresAuth = false;
    emit(const PaymentIFrameState());
  }

  String _friendlyMessage(PaymentIFrameException e) {
    switch (e.type) {
      case PaymentIFrameErrorType.noInternet:
        return 'No internet connection. Please check and try again.';
      case PaymentIFrameErrorType.timeout:
        return 'Request timed out. Please try again.';
      case PaymentIFrameErrorType.server:
        return 'Server error. Please try again later.';
      case PaymentIFrameErrorType.invalidResponse:
        return 'Unexpected response from server. Please try again.';
      case PaymentIFrameErrorType.network:
      case PaymentIFrameErrorType.unknown:
        return e.message.isNotEmpty ? e.message : 'Payment failed. Please try again.';
    }
  }
}
