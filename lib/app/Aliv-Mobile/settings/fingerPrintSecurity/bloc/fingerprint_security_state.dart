import 'package:equatable/equatable.dart';
import '../repository/fingerprint_security_repository.dart';

enum FingerPrintSecurityStatus { initial, loading, ready, failure }

enum FingerPrintSecurityNavTarget { none, back }

class FingerPrintSecurityState extends Equatable {
  final FingerPrintSecurityStatus status;
  final FingerPrintSecurityContent? content;
  final String? errorMessage;

  final FingerPrintSecurityNavTarget navTarget;

  const FingerPrintSecurityState({
    required this.status,
    required this.content,
    required this.errorMessage,
    required this.navTarget,
  });

  factory FingerPrintSecurityState.initial() => const FingerPrintSecurityState(
    status: FingerPrintSecurityStatus.initial,
    content: null,
    errorMessage: null,
    navTarget: FingerPrintSecurityNavTarget.none,
  );

  FingerPrintSecurityState copyWith({
    FingerPrintSecurityStatus? status,
    FingerPrintSecurityContent? content,
    String? errorMessage,
    FingerPrintSecurityNavTarget? navTarget,
  }) {
    return FingerPrintSecurityState(
      status: status ?? this.status,
      content: content ?? this.content,
      errorMessage: errorMessage,
      navTarget: navTarget ?? this.navTarget,
    );
  }

  @override
  List<Object?> get props => [status, content, errorMessage, navTarget];
}
