import 'package:equatable/equatable.dart';

import '../model/support_models.dart';

sealed class SupportEvent extends Equatable {
  const SupportEvent();

  @override
  List<Object?> get props => [];
}

final class SupportStarted extends SupportEvent {
  const SupportStarted();
}

final class SupportMenuItemPressed extends SupportEvent {
  final SupportMenuItem item;

  const SupportMenuItemPressed(this.item);

  @override
  List<Object?> get props => [item];
}

final class SupportCallPressed extends SupportEvent {
  const SupportCallPressed();
}

final class SupportLaunchHandled extends SupportEvent {
  const SupportLaunchHandled();
}
