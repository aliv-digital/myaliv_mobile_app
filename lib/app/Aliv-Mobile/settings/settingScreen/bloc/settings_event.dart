import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsStarted extends SettingsEvent {
  const SettingsStarted();
}

class FingerprintToggled extends SettingsEvent {
  final bool enabled;
  const FingerprintToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class FaceScanToggled extends SettingsEvent {
  final bool enabled;
  const FaceScanToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class SecurityPressed extends SettingsEvent {
  const SecurityPressed();
}

class PrivacyPressed extends SettingsEvent {
  const PrivacyPressed();
}

class HelpPressed extends SettingsEvent {
  const HelpPressed();
}

class SettingsNavConsumed extends SettingsEvent {
  const SettingsNavConsumed();
}
