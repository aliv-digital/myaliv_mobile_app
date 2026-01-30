import 'package:equatable/equatable.dart';
import '../repository/help_repository.dart';

enum HelpStatus { initial, loading, ready, failure }

enum HelpNavTarget { none, home }

class HelpState extends Equatable {
  final HelpStatus status;
  final HelpContent? content;
  final String? errorMessage;
  final HelpNavTarget navTarget;

  const HelpState({
    required this.status,
    required this.content,
    required this.errorMessage,
    required this.navTarget,
  });

  factory HelpState.initial() => const HelpState(
    status: HelpStatus.initial,
    content: null,
    errorMessage: null,
    navTarget: HelpNavTarget.none,
  );

  HelpState copyWith({
    HelpStatus? status,
    HelpContent? content,
    String? errorMessage,
    HelpNavTarget? navTarget,
  }) {
    return HelpState(
      status: status ?? this.status,
      content: content ?? this.content,
      errorMessage: errorMessage,
      navTarget: navTarget ?? this.navTarget,
    );
  }

  @override
  List<Object?> get props => [status, content, errorMessage, navTarget];
}
