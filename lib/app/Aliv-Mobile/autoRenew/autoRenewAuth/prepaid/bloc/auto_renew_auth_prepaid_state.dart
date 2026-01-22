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

  const AutoRenewAuthPrepaidState({
    required this.loadStatus,
    required this.content,
    required this.name,
    required this.submitStatus,
    required this.errorMessage,
    required this.navTarget,
  });

  factory AutoRenewAuthPrepaidState.initial() {
    return const AutoRenewAuthPrepaidState(
      loadStatus: AutoRenewAuthLoadStatus.loading,
      content: null,
      name: '',
      submitStatus: AutoRenewAuthSubmitStatus.idle,
      errorMessage: null,
      navTarget: AutoRenewAuthNavTarget.none,
    );
  }

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
    bool clearError = false,
  }) {
    return AutoRenewAuthPrepaidState(
      loadStatus: loadStatus ?? this.loadStatus,
      content: content ?? this.content,
      name: name ?? this.name,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      navTarget: navTarget ?? this.navTarget,
    );
  }

  @override
  List<Object?> get props =>
      [loadStatus, content, name, submitStatus, errorMessage, navTarget];
}
