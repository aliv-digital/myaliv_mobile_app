import 'package:equatable/equatable.dart';

import '../repository/auto_renew_auth_prepaid_repository.dart';

enum AutoRenewAuthLoadStatus { loading, ready, failure }
enum AutoRenewAuthSubmitStatus { idle, submitting, success, failure }
enum AutoRenewAuthNavTarget { none, home, success }

class AutoRenewAuthPrepaidState extends Equatable {
  final AutoRenewAuthLoadStatus loadStatus;
  final AutoRenewAuthContent? content;

  final String name;
  final AutoRenewAuthSubmitStatus submitStatus;

  final String? errorMessage;
  final AutoRenewAuthNavTarget navTarget;

  /// Payment method selected (wallet or card)
  final AutoRenewPaymentMethodType paymentMethod;

  /// Saved card token for the card payment flow
  final String? cardToken;

  const AutoRenewAuthPrepaidState({
    required this.loadStatus,
    required this.content,
    required this.name,
    required this.submitStatus,
    required this.errorMessage,
    required this.navTarget,
    required this.paymentMethod,
    required this.cardToken,
  });

  factory AutoRenewAuthPrepaidState.initial() {
    return const AutoRenewAuthPrepaidState(
      loadStatus: AutoRenewAuthLoadStatus.loading,
      content: null,
      name: '',
      submitStatus: AutoRenewAuthSubmitStatus.idle,
      errorMessage: null,
      navTarget: AutoRenewAuthNavTarget.none,
      paymentMethod: AutoRenewPaymentMethodType.wallet,
      cardToken: null,
    );
  }

  /// Expected name from content for validation
  String get expectedName => content?.expectedName ?? '';

  /// Check if entered name matches expected name (case-insensitive)
  bool get isNameValid =>
      name.trim().toLowerCase() == expectedName.trim().toLowerCase();

  bool get canSubmit =>
      loadStatus == AutoRenewAuthLoadStatus.ready &&
      name.trim().isNotEmpty &&
      submitStatus != AutoRenewAuthSubmitStatus.submitting;

  AutoRenewAuthPrepaidState copyWith({
    AutoRenewAuthLoadStatus? loadStatus,
    AutoRenewAuthContent? content,
    String? name,
    AutoRenewAuthSubmitStatus? submitStatus,
    String? errorMessage,
    AutoRenewAuthNavTarget? navTarget,
    AutoRenewPaymentMethodType? paymentMethod,
    String? cardToken,
    bool clearError = false,
  }) {
    return AutoRenewAuthPrepaidState(
      loadStatus: loadStatus ?? this.loadStatus,
      content: content ?? this.content,
      name: name ?? this.name,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      navTarget: navTarget ?? this.navTarget,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cardToken: cardToken ?? this.cardToken,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        content,
        name,
        submitStatus,
        errorMessage,
        navTarget,
        paymentMethod,
        cardToken,
      ];
}
