// lib/features/guest_top_up/guest_top_up/bloc/guest_top_up_event.dart
import 'package:equatable/equatable.dart';

abstract class GuestTopUpEvent extends Equatable {
  const GuestTopUpEvent();

  @override
  List<Object?> get props => [];
}

class GuestTopUpStarted extends GuestTopUpEvent {
  const GuestTopUpStarted();
}

class GuestActivePrepaidNumberEvent extends GuestTopUpEvent{
  final String number;
  const GuestActivePrepaidNumberEvent(this.number);
  @override
  List<Object?> get props => [number];
}

class GuestActivePrepaidNumberConfirmEvent extends GuestTopUpEvent{
  final String number;
  const GuestActivePrepaidNumberConfirmEvent(this.number);
  @override
  List<Object?> get props => [number];
}

class GuestTopUpAmountEvent extends GuestTopUpEvent{
  final String amount;
  const GuestTopUpAmountEvent(this.amount);
  @override
  List<Object?> get props => [amount];
}