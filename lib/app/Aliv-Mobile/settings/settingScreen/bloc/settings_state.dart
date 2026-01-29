import 'package:equatable/equatable.dart';

enum SettingsStatus { initial, loading, ready, failure }

enum SettingsNavTarget { none, security, privacy, help }

class SettingsState extends Equatable {
  final SettingsStatus status;

  final bool fingerprintEnabled;
  final bool faceScanEnabled;

  final SettingsNavTarget navTarget;
  final String? errorMessage;

  const SettingsState({
    required this.status,
    required this.fingerprintEnabled,
    required this.faceScanEnabled,
    required this.navTarget,
    required this.errorMessage,
  });

  factory SettingsState.initial() => const SettingsState(
    status: SettingsStatus.initial,
    fingerprintEnabled: false,
    faceScanEnabled: false,
    navTarget: SettingsNavTarget.none,
    errorMessage: null,
  );

  SettingsState copyWith({
    SettingsStatus? status,
    bool? fingerprintEnabled,
    bool? faceScanEnabled,
    SettingsNavTarget? navTarget,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
      faceScanEnabled: faceScanEnabled ?? this.faceScanEnabled,
      navTarget: navTarget ?? this.navTarget,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    fingerprintEnabled,
    faceScanEnabled,
    navTarget,
    errorMessage,
  ];
}
