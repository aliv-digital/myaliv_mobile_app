import 'package:equatable/equatable.dart';

enum AltNumberValidationStatus { initial, loading, valid, invalid, failure }

class AltNumberValidationState extends Equatable {
  final AltNumberValidationStatus status;
  final String errorMessage;

  /// Bumped on every emit that should drive a one-shot side effect
  /// (toast or navigation). Prevents the same listener from firing twice
  /// when an Equatable-equal state is re-emitted.
  final int signalId;

  const AltNumberValidationState({
    this.status = AltNumberValidationStatus.initial,
    this.errorMessage = '',
    this.signalId = 0,
  });

  bool get isLoading => status == AltNumberValidationStatus.loading;

  AltNumberValidationState copyWith({
    AltNumberValidationStatus? status,
    String? errorMessage,
    int? signalId,
  }) {
    return AltNumberValidationState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      signalId: signalId ?? this.signalId,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, signalId];
}
