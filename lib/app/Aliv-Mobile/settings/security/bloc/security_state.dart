import 'package:equatable/equatable.dart';

import '../repository/security_repository.dart';

enum SecurityStatus { initial, loading, ready, failure }

enum SecurityNavTarget { none, home }

class SecurityState extends Equatable {
  final SecurityStatus status;
  final SecurityContent? content;
  final String? errorMessage;
  final SecurityNavTarget navTarget;

  const SecurityState({
    required this.status,
    required this.content,
    required this.errorMessage,
    required this.navTarget,
  });

  factory SecurityState.initial() => const SecurityState(
    status: SecurityStatus.initial,
    content: null,
    errorMessage: null,
    navTarget: SecurityNavTarget.none,
  );

  SecurityState copyWith({
    SecurityStatus? status,
    SecurityContent? content,
    String? errorMessage,
    SecurityNavTarget? navTarget,
  }) {
    return SecurityState(
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