import 'package:equatable/equatable.dart';

import '../models/payment_result.dart';

enum PaymentIFrameStatus { initial, loading, ready, verifying, success, failure }

class PaymentIFrameState extends Equatable {
  const PaymentIFrameState({
    this.status = PaymentIFrameStatus.initial,
    this.htmlContent,
    this.result,
    this.errorMessage,
  });

  final PaymentIFrameStatus status;

  /// The HTML document returned by the API, ready to load in the WebView.
  final String? htmlContent;

  /// Set after the redirect URI is received from the WebView.
  final PaymentResult? result;

  final String? errorMessage;

  bool get isLoading => status == PaymentIFrameStatus.loading;
  bool get isReady => status == PaymentIFrameStatus.ready;
  bool get isVerifying => status == PaymentIFrameStatus.verifying;
  bool get isSuccess => status == PaymentIFrameStatus.success;
  bool get isFailure => status == PaymentIFrameStatus.failure;

  PaymentIFrameState copyWith({
    PaymentIFrameStatus? status,
    String? htmlContent,
    PaymentResult? result,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentIFrameState(
      status: status ?? this.status,
      htmlContent: htmlContent ?? this.htmlContent,
      result: result ?? this.result,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, htmlContent, result, errorMessage];
}
