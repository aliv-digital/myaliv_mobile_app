// lib/features/guest_top_up/guest_top_up/bloc/guest_top_up_state.dart
import 'package:equatable/equatable.dart';

enum GuestTopUpStatus { initial, loading, ready, failure }

class GuestTopUpState extends Equatable {
  const GuestTopUpState({
    this.status = GuestTopUpStatus.initial,
    this.errorMessage,
    this.amount = '',
    this.phoneNumber = '',
    this.confirmPhoneNumber = '',
  });

  final GuestTopUpStatus status;
  final String? errorMessage;
  final String amount;
  final String phoneNumber;
  final String confirmPhoneNumber;

  GuestTopUpState copyWith({
    GuestTopUpStatus? status,
    String? errorMessage,
    String? amount,
    String? phoneNumber,
    String? confirmPhoneNumber,
  }) {
    return GuestTopUpState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      amount: amount ?? this.amount,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      confirmPhoneNumber: confirmPhoneNumber ?? this.confirmPhoneNumber,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, amount, phoneNumber, confirmPhoneNumber];
}
