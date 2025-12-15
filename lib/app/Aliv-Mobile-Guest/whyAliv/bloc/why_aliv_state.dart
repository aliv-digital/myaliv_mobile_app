// lib/features/why_aliv/why_aliv/bloc/why_aliv_state.dart
import 'package:equatable/equatable.dart';

enum WhyAlivStatus { initial, loading, ready, failure }

class WhyAlivState extends Equatable {
  const WhyAlivState({
    this.status = WhyAlivStatus.initial,
    this.errorMessage,
  });

  final WhyAlivStatus status;
  final String? errorMessage;

  WhyAlivState copyWith({
    WhyAlivStatus? status,
    String? errorMessage,
  }) {
    return WhyAlivState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
