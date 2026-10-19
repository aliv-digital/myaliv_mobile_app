import 'package:equatable/equatable.dart';

abstract class HelpEvent extends Equatable {
  const HelpEvent();

  @override
  List<Object?> get props => [];
}

class HelpStarted extends HelpEvent {
  const HelpStarted();
}

class HelpNavConsumed extends HelpEvent {
  const HelpNavConsumed();
}

class HelpHomePressed extends HelpEvent {
  const HelpHomePressed();
}
