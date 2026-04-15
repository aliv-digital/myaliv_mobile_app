import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';

/// Status enum for Device Limits state
enum DeviceLimitsStatus {
  initial,
  loading,
  loaded,
  updating,
  updated,
  failure,
}

/// Immutable state for Device Limits feature
///
/// Contains device limits data for credit limit update screen.
class DeviceLimitsState {
  final DeviceLimitsStatus status;
  final DeviceLimitsModel? deviceLimits;
  final String? errorMessage;
  final DateTime? lastFetchedAt;

  const DeviceLimitsState({
    required this.status,
    this.deviceLimits,
    this.errorMessage,
    this.lastFetchedAt,
  });

  /// Initial state factory
  factory DeviceLimitsState.initial() {
    return const DeviceLimitsState(
      status: DeviceLimitsStatus.initial,
      deviceLimits: null,
      errorMessage: null,
      lastFetchedAt: null,
    );
  }

  /// Copy state with updated fields
  DeviceLimitsState copyWith({
    DeviceLimitsStatus? status,
    DeviceLimitsModel? deviceLimits,
    String? errorMessage,
    DateTime? lastFetchedAt,
    bool clearError = false,
  }) {
    return DeviceLimitsState(
      status: status ?? this.status,
      deviceLimits: deviceLimits ?? this.deviceLimits,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
    );
  }

  /// Check if we have device limits data
  bool get hasDeviceLimits => deviceLimits != null;

  /// Check if currently loading
  bool get isLoading => status == DeviceLimitsStatus.loading;

  /// Check if there was an error
  bool get hasError => status == DeviceLimitsStatus.failure;

  /// Check if data is loaded successfully
  bool get isLoaded => status == DeviceLimitsStatus.loaded;

  /// Check if currently updating
  bool get isUpdating => status == DeviceLimitsStatus.updating;

  /// Check if update was successful
  bool get isUpdated => status == DeviceLimitsStatus.updated;

  /// Check if cache is still valid (5 minutes TTL)
  bool get isCacheValid {
    if (lastFetchedAt == null) return false;
    final age = DateTime.now().difference(lastFetchedAt!);
    return age.inMinutes < 5;
  }

  @override
  String toString() {
    return 'DeviceLimitsState(status: $status, '
        'hasDeviceLimits: $hasDeviceLimits, '
        'errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceLimitsState &&
        other.status == status &&
        other.deviceLimits == deviceLimits &&
        other.errorMessage == errorMessage &&
        other.lastFetchedAt == lastFetchedAt;
  }

  @override
  int get hashCode {
    return Object.hash(status, deviceLimits, errorMessage, lastFetchedAt);
  }
}
