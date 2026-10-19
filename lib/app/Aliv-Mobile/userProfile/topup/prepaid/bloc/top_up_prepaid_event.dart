import 'package:equatable/equatable.dart';

abstract class TopUpPrepaidEvent extends Equatable {
  const TopUpPrepaidEvent();

  @override
  List<Object?> get props => [];
}

class TopUpPrepaidStarted extends TopUpPrepaidEvent {
  const TopUpPrepaidStarted();
}

class TopUpPrepaidTabChanged extends TopUpPrepaidEvent {
  final int index;
  const TopUpPrepaidTabChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class TopUpPrepaidAmountChanged extends TopUpPrepaidEvent {
  final String value;
  const TopUpPrepaidAmountChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class TopUpPrepaidTopUpPressed extends TopUpPrepaidEvent {
  const TopUpPrepaidTopUpPressed();
}

/// Re-fetch `/top-up-limit-left` after a successful top-up / transfer so
/// the 24h bucket stays in sync when the user comes back to either tab.
class TopUpPrepaidLimitRefreshed extends TopUpPrepaidEvent {
  const TopUpPrepaidLimitRefreshed();
}
