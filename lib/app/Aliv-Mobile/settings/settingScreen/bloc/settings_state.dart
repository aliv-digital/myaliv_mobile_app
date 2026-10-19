import 'package:equatable/equatable.dart';

enum SettingsStatus { initial, loading, ready, failure }

enum SettingsNavTarget { none, security, privacy, help }

class SettingsState extends Equatable {
  final SettingsStatus status;

  final bool fingerprintEnabled;
  final bool faceScanEnabled;

  final bool isFingerprintAvailable;
  final bool isFaceIdAvailable;

  final SettingsNavTarget navTarget;
  final String? errorMessage;

  const SettingsState({
    required this.status,
    required this.fingerprintEnabled,
    required this.faceScanEnabled,
    required this.isFingerprintAvailable,
    required this.isFaceIdAvailable,
    required this.navTarget,
    required this.errorMessage,
  });

  factory SettingsState.initial() => const SettingsState(
    status: SettingsStatus.initial,
    fingerprintEnabled: false,
    faceScanEnabled: false,
    isFingerprintAvailable: false,
    isFaceIdAvailable: false,
    navTarget: SettingsNavTarget.none,
    errorMessage: null,
  );

  SettingsState copyWith({
    SettingsStatus? status,
    bool? fingerprintEnabled,
    bool? faceScanEnabled,
    bool? isFingerprintAvailable,
    bool? isFaceIdAvailable,
    SettingsNavTarget? navTarget,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
      faceScanEnabled: faceScanEnabled ?? this.faceScanEnabled,
      isFingerprintAvailable:
          isFingerprintAvailable ?? this.isFingerprintAvailable,
      isFaceIdAvailable: isFaceIdAvailable ?? this.isFaceIdAvailable,
      navTarget: navTarget ?? this.navTarget,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    fingerprintEnabled,
    faceScanEnabled,
    isFingerprintAvailable,
    isFaceIdAvailable,
    navTarget,
    errorMessage,
  ];
}
