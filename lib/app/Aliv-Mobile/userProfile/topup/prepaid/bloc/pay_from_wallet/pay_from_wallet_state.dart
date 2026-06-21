import 'package:equatable/equatable.dart';

enum PayFromWalletStatus { initial, submitting, success, failure }

class PayFromWalletState extends Equatable {
  final PayFromWalletStatus status;
  final String? errorMessage;

  const PayFromWalletState({
    this.status = PayFromWalletStatus.initial,
    this.errorMessage,
  });

  bool get isSubmitting => status == PayFromWalletStatus.submitting;
  bool get isSuccess => status == PayFromWalletStatus.success;
  bool get hasError => status == PayFromWalletStatus.failure;

  PayFromWalletState copyWith({
    PayFromWalletStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PayFromWalletState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
