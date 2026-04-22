import 'package:equatable/equatable.dart';

import '../repository/privacy_repository.dart';

enum PrivacyStatus { initial, loading, ready, failure }

enum PrivacyNavTarget { none, home }

class PrivacyState extends Equatable {
  final PrivacyStatus status;
  final PrivacyContent? content;
  final String? errorMessage;
  final PrivacyNavTarget navTarget;

  const PrivacyState({
    required this.status,
    required this.content,
    required this.errorMessage,
    required this.navTarget,
  });

  factory PrivacyState.initial() => const PrivacyState(
    status: PrivacyStatus.initial,
    content: null,
    errorMessage: null,
    navTarget: PrivacyNavTarget.none,
  );

  PrivacyState copyWith({
    PrivacyStatus? status,
    PrivacyContent? content,
    String? errorMessage,
    PrivacyNavTarget? navTarget,
  }) {
    return PrivacyState(
      status: status ?? this.status,
      content: content ?? this.content,
      errorMessage: errorMessage,
      navTarget: navTarget ?? this.navTarget,
    );
  }

  @override
  List<Object?> get props => [
    status,
    content,
    errorMessage,
    navTarget,
  ];
}