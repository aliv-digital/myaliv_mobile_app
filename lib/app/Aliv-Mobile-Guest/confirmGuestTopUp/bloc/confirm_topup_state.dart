import 'package:equatable/equatable.dart';

enum GuestConfirmTopUpStatus { initial, loading, success, failure }

class GuestConfirmTopUpState extends Equatable {
  final GuestConfirmTopUpStatus status;

  final String phoneNumber;

  final double subTotal;
  final double vat;
  final double total;

  final String? errorMessage;

  /// ✅ UI action trigger: Terms clicked (increments each click)
  final int termsRequestId;

  const GuestConfirmTopUpState({
    required this.status,
    required this.phoneNumber,
    required this.subTotal,
    required this.vat,
    required this.total,
    this.errorMessage,
    required this.termsRequestId,
  });

  factory GuestConfirmTopUpState.initial() {
    return const GuestConfirmTopUpState(
      status: GuestConfirmTopUpStatus.initial,
      phoneNumber: '',
      subTotal: 0,
      vat: 0,
      total: 0,
      errorMessage: null,
      termsRequestId: 0,
    );
  }

  GuestConfirmTopUpState copyWith({
    GuestConfirmTopUpStatus? status,
    String? phoneNumber,
    double? subTotal,
    double? vat,
    double? total,
    String? errorMessage,
    int? termsRequestId,
  }) {
    return GuestConfirmTopUpState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      subTotal: subTotal ?? this.subTotal,
      vat: vat ?? this.vat,
      total: total ?? this.total,
      errorMessage: errorMessage,
      termsRequestId: termsRequestId ?? this.termsRequestId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    phoneNumber,
    subTotal,
    vat,
    total,
    errorMessage,
    termsRequestId,
  ];
}
