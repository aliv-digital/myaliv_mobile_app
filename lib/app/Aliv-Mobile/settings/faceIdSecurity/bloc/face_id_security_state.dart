import 'package:equatable/equatable.dart';
import '../repository/face_id_security_repository.dart';

enum FaceIdSecurityStatus { initial, loading, ready, failure }

enum FaceIdSecurityNavTarget { none, back }

class FaceIdSecurityState extends Equatable {
  final FaceIdSecurityStatus status;
  final FaceIdSecurityContent? content;
  final String? errorMessage;

  final FaceIdSecurityNavTarget navTarget;

  const FaceIdSecurityState({
    required this.status,
    required this.content,
    required this.errorMessage,
    required this.navTarget,
  });

  factory FaceIdSecurityState.initial() => const FaceIdSecurityState(
    status: FaceIdSecurityStatus.initial,
    content: null,
    errorMessage: null,
    navTarget: FaceIdSecurityNavTarget.none,
  );

  FaceIdSecurityState copyWith({
    FaceIdSecurityStatus? status,
    FaceIdSecurityContent? content,
    String? errorMessage,
    FaceIdSecurityNavTarget? navTarget,
  }) {
    return FaceIdSecurityState(
      status: status ?? this.status,
      content: content ?? this.content,
      errorMessage: errorMessage,
      navTarget: navTarget ?? this.navTarget,
    );
  }

  @override
  List<Object?> get props => [status, content, errorMessage, navTarget];
}
