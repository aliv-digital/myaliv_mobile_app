import 'package:equatable/equatable.dart';

abstract class TopUpPrepaidNumberPostPaidEvent extends Equatable {
  const TopUpPrepaidNumberPostPaidEvent();

  @override
  List<Object?> get props => [];
}

class TopUpPrepaidNumberPostPaidStarted extends TopUpPrepaidNumberPostPaidEvent {
  const TopUpPrepaidNumberPostPaidStarted();
}

class TopUpPrepaidNumberPostPaidNumberChanged extends TopUpPrepaidNumberPostPaidEvent {
  final String value;
  const TopUpPrepaidNumberPostPaidNumberChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class TopUpPrepaidNumberPostPaidConfirmNumberChanged extends TopUpPrepaidNumberPostPaidEvent {
  final String value;
  const TopUpPrepaidNumberPostPaidConfirmNumberChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class TopUpPrepaidNumberPostPaidAmountChanged extends TopUpPrepaidNumberPostPaidEvent {
  final String value;
  const TopUpPrepaidNumberPostPaidAmountChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class TopUpPrepaidNumberPostPaidApplyPressed extends TopUpPrepaidNumberPostPaidEvent {
  const TopUpPrepaidNumberPostPaidApplyPressed();
}
