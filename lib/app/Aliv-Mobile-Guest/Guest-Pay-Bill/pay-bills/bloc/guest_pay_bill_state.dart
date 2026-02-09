import 'package:equatable/equatable.dart';

import '../model/guest_pay_bill_models.dart';

enum GuestPayBillLoadStatus { initial, loading, ready, failure }

enum GuestPayBillVerifyStatus { idle, loading, success, failure }

enum GuestPayBillSubmitStatus { idle, loading, success, failure }

class GuestPayBillState extends Equatable {
  final GuestPayBillLoadStatus loadStatus;

  final List<BillService> services;
  final BillService? selectedService;
  final PayBillCountry selectedCountry;

  // REV
  final String accountNumber;
  final String name;

  // ALIV Postpaid
  final String mobileNumber;
  final String confirmMobileNumber;

  final String amountText;

  final GuestPayBillVerifyStatus verifyStatus;
  final PayBillAccountInfo? accountInfo;
  final String? errorMessage;

  final GuestPayBillSubmitStatus submitStatus;

  const GuestPayBillState({
    required this.loadStatus,
    required this.services,
    required this.selectedService,
    required this.selectedCountry,
    required this.accountNumber,
    required this.name,
    required this.mobileNumber,
    required this.confirmMobileNumber,
    required this.amountText,
    required this.verifyStatus,
    required this.accountInfo,
    required this.errorMessage,
    required this.submitStatus,
  });

  factory GuestPayBillState.initial() => const GuestPayBillState(
        loadStatus: GuestPayBillLoadStatus.initial,
        services: [],
        selectedService: null,
        selectedCountry: PayBillCountry.defaultCountry,
        accountNumber: '',
        name: '',
        mobileNumber: '',
        confirmMobileNumber: '',
        amountText: '0.00',
        verifyStatus: GuestPayBillVerifyStatus.idle,
        accountInfo: null,
        errorMessage: null,
        submitStatus: GuestPayBillSubmitStatus.idle,
      );

  bool get isAlivPostpaid => selectedService?.code == 'ALIV_POSTPAID';
  bool get isAlivFibr => selectedService?.code == 'ALIV_FIBR';

  String get accountIdentifierLabel =>
      isAlivFibr ? 'account number/username' : 'account number';

  String get accountIdentifierHint => isAlivFibr ? 'enter ID' : 'enter number';

  double get amountValue {
    final cleaned = amountText.trim().replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  bool get canVerify {
    if (selectedService == null) return false;
    if (verifyStatus == GuestPayBillVerifyStatus.loading) return false;

    if (isAlivPostpaid) {
      return mobileNumber.trim().isNotEmpty &&
          confirmMobileNumber.trim().isNotEmpty &&
          mobileNumber.trim() == confirmMobileNumber.trim();
    }

    return accountNumber.trim().isNotEmpty && name.trim().isNotEmpty;
  }

  bool get canSubmit {
    return selectedService != null &&
        accountInfo != null &&
        amountValue > 0 &&
        submitStatus != GuestPayBillSubmitStatus.loading;
  }

  GuestPayBillState copyWith({
    GuestPayBillLoadStatus? loadStatus,
    List<BillService>? services,
    BillService? selectedService,
    PayBillCountry? selectedCountry,
    String? accountNumber,
    String? name,
    String? mobileNumber,
    String? confirmMobileNumber,
    String? amountText,
    GuestPayBillVerifyStatus? verifyStatus,
    PayBillAccountInfo? accountInfo,
    String? errorMessage,
    GuestPayBillSubmitStatus? submitStatus,
  }) {
    return GuestPayBillState(
      loadStatus: loadStatus ?? this.loadStatus,
      services: services ?? this.services,
      selectedService: selectedService ?? this.selectedService,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      accountNumber: accountNumber ?? this.accountNumber,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      confirmMobileNumber: confirmMobileNumber ?? this.confirmMobileNumber,
      amountText: amountText ?? this.amountText,
      verifyStatus: verifyStatus ?? this.verifyStatus,
      accountInfo: accountInfo ?? this.accountInfo,
      errorMessage: errorMessage,
      submitStatus: submitStatus ?? this.submitStatus,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        services,
        selectedService,
        selectedCountry,
        accountNumber,
        name,
        mobileNumber,
        confirmMobileNumber,
        amountText,
        verifyStatus,
        accountInfo,
        errorMessage,
        submitStatus,
      ];
}
