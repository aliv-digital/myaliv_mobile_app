import 'package:equatable/equatable.dart';

enum RevConfirmNavTarget { none, continueNext }
enum RevPromoStatus { idle, applying, applied, invalid }

class RevConfirmationPrepaidState extends Equatable {
  final String title;

  final String customerName;
  final String service;
  final String accountNumber;

  final double subtotal;
  final double vat;
  final double discount;

  final String promoCode;
  final RevPromoStatus promoStatus;

  final RevConfirmNavTarget navTarget;

  const RevConfirmationPrepaidState({
    required this.title,
    required this.customerName,
    required this.service,
    required this.accountNumber,
    required this.subtotal,
    required this.vat,
    required this.discount,
    required this.promoCode,
    required this.promoStatus,
    required this.navTarget,
  });

  factory RevConfirmationPrepaidState.initial() {
    return const RevConfirmationPrepaidState(
      title: 'confirmation',
      customerName: '',
      service: 'REV',
      accountNumber: '',
      subtotal: 0.0,
      vat: 0.0,
      discount: 0.0,
      promoCode: '',
      promoStatus: RevPromoStatus.idle,
      navTarget: RevConfirmNavTarget.none,
    );
  }

  double get total => (subtotal + vat - discount).clamp(0, double.infinity);

  String get subtotalText => r'$ ' + subtotal.toStringAsFixed(2);
  String get vatText => r'$ ' + vat.toStringAsFixed(2);
  String get totalText => r'$ ' + total.toStringAsFixed(2);

  String get headerAmountPillText => subtotalText;

  bool get canApplyPromo => promoCode.trim().isNotEmpty && promoStatus != RevPromoStatus.applying;

  bool get canContinue => true; // design shows it enabled

  RevConfirmationPrepaidState copyWith({
    String? title,
    String? customerName,
    String? service,
    String? accountNumber,
    double? subtotal,
    double? vat,
    double? discount,
    String? promoCode,
    RevPromoStatus? promoStatus,
    RevConfirmNavTarget? navTarget,
  }) {
    return RevConfirmationPrepaidState(
      title: title ?? this.title,
      customerName: customerName ?? this.customerName,
      service: service ?? this.service,
      accountNumber: accountNumber ?? this.accountNumber,
      subtotal: subtotal ?? this.subtotal,
      vat: vat ?? this.vat,
      discount: discount ?? this.discount,
      promoCode: promoCode ?? this.promoCode,
      promoStatus: promoStatus ?? this.promoStatus,
      navTarget: navTarget ?? this.navTarget,
    );
  }

  @override
  List<Object?> get props => [
    title,
    customerName,
    service,
    accountNumber,
    subtotal,
    vat,
    discount,
    promoCode,
    promoStatus,
    navTarget,
  ];
}
