import 'package:equatable/equatable.dart';

enum RevNavTarget { none, proceed }

class RevPrepaidState extends Equatable {
  final String title;
  final String service;

  final String accountNumber;
  final String name;

  final String? accountStatus;
  final double? accountBalance;

  final double amount;

  final bool submitting;
  final String? errorMessage;

  final RevNavTarget navTarget;

  const RevPrepaidState({
    required this.title,
    required this.service,
    required this.accountNumber,
    required this.name,
    required this.accountStatus,
    required this.accountBalance,
    required this.amount,
    required this.submitting,
    required this.errorMessage,
    required this.navTarget,
  });

  factory RevPrepaidState.initial() {
    return const RevPrepaidState(
      title: 'REV bill pay',
      service: 'REV',
      accountNumber: '',
      name: '',
      accountStatus: null,
      accountBalance: null,
      amount: 0.00,
      submitting: false,
      errorMessage: null,
      navTarget: RevNavTarget.none,
    );
  }

  bool get canSubmit =>
      accountNumber.trim().isNotEmpty && name.trim().isNotEmpty && !submitting;

  bool get canProceed => accountStatus != null && accountBalance != null;

  String get accountStatusText => accountStatus ?? '--------';

  String get accountBalanceText =>
      accountBalance == null ? '--------' : r'$ ' + accountBalance!.toStringAsFixed(2);

  String get amountFormatted => r'$ ' + amount.toStringAsFixed(2);

  RevPrepaidState copyWith({
    String? title,
    String? service,
    String? accountNumber,
    String? name,
    String? accountStatus,
    double? accountBalance,
    double? amount,
    bool? submitting,
    String? errorMessage,
    RevNavTarget? navTarget,
    bool clearAccountData = false,
    bool clearError = false,
  }) {
    return RevPrepaidState(
      title: title ?? this.title,
      service: service ?? this.service,
      accountNumber: accountNumber ?? this.accountNumber,
      name: name ?? this.name,
      accountStatus: clearAccountData ? null : (accountStatus ?? this.accountStatus),
      accountBalance: clearAccountData ? null : (accountBalance ?? this.accountBalance),
      amount: amount ?? this.amount,
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      navTarget: navTarget ?? this.navTarget,
    );
  }

  @override
  List<Object?> get props => [
    title,
    service,
    accountNumber,
    name,
    accountStatus,
    accountBalance,
    amount,
    submitting,
    errorMessage,
    navTarget,
  ];
}
