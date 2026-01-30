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

  // ✅ NEW: Terms checkbox
  final bool termsAccepted;

  // ✅ NEW: UI flag to show validation feedback once (snackbar etc.)
  final bool showTermsError;

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
    required this.termsAccepted,
    required this.showTermsError,
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

      // ✅ defaults
      termsAccepted: false,
      showTermsError: false,
    );
  }

  double get total => (subtotal + vat - discount).clamp(0, double.infinity);

  String get subtotalText => r'$ ' + subtotal.toStringAsFixed(2);
  String get vatText => r'$ ' + vat.toStringAsFixed(2);
  String get totalText => r'$ ' + total.toStringAsFixed(2);

  String get headerAmountPillText => subtotalText;

  bool get canApplyPromo =>
      promoCode.trim().isNotEmpty && promoStatus != RevPromoStatus.applying;

  // ✅ safer: only allow continue if terms accepted
  bool get canContinue => termsAccepted;

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

    // ✅ NEW
    bool? termsAccepted,
    bool? showTermsError,
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

      termsAccepted: termsAccepted ?? this.termsAccepted,
      showTermsError: showTermsError ?? this.showTermsError,
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
    termsAccepted,
    showTermsError,
  ];
}
