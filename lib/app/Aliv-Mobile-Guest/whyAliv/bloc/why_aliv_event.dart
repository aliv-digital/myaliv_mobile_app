// lib/features/why_aliv/why_aliv/bloc/why_aliv_event.dart
import 'package:equatable/equatable.dart';

sealed class WhyAlivEvent extends Equatable {
  const WhyAlivEvent();

  @override
  List<Object?> get props => [];
}

final class WhyAlivStarted extends WhyAlivEvent {
  const WhyAlivStarted();
}
