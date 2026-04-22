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

  /// Full list of all device limits from API
  final List<DeviceLimitsModel> allDeviceLimits;
  final String? errorMessage;
  final DateTime? lastFetchedAt;

  /// Whether auto-renew toggle operation is in progress
  final bool isTogglingAutoRenew;

  const DeviceLimitsState({
    required this.status,
    this.allDeviceLimits = const [],
    this.errorMessage,
    this.lastFetchedAt,
    this.isTogglingAutoRenew = false,
  });

  /// Initial state factory
  factory DeviceLimitsState.initial() {
    return const DeviceLimitsState(
      status: DeviceLimitsStatus.initial,
      allDeviceLimits: [],
      errorMessage: null,
      lastFetchedAt: null,
      isTogglingAutoRenew: false,
    );
  }

  /// Copy state with updated fields
  DeviceLimitsState copyWith({
    DeviceLimitsStatus? status,
    List<DeviceLimitsModel>? allDeviceLimits,
    String? errorMessage,
    DateTime? lastFetchedAt,
    bool? isTogglingAutoRenew,
    bool clearError = false,
  }) {
    return DeviceLimitsState(
      status: status ?? this.status,
      allDeviceLimits: allDeviceLimits ?? this.allDeviceLimits,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      isTogglingAutoRenew: isTogglingAutoRenew ?? this.isTogglingAutoRenew,
    );
  }

  /// Get first device limits (for backward compatibility)
  ///
  /// Returns null if list is empty.
  DeviceLimitsModel? get deviceLimits =>
      allDeviceLimits.isNotEmpty ? allDeviceLimits.first : null;

  /// Check if we have device limits data
  bool get hasDeviceLimits => allDeviceLimits.isNotEmpty;

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

  /// Total number of devices
  int get deviceCount => allDeviceLimits.length;

  /// First name from device with non-null fName
  String? get fName {
    for (final device in allDeviceLimits) {
      if (device.fName != null && device.fName!.isNotEmpty) {
        return device.fName;
      }
    }
    return null;
  }

  /// Last name from device with non-null lName
  String? get lName {
    for (final device in allDeviceLimits) {
      if (device.lName != null && device.lName!.isNotEmpty) {
        return device.lName;
      }
    }
    return null;
  }

  /// Full name (fName + lName) from first device with valid name
  String? get fullName {
    final f = fName;
    final l = lName;
    if (f == null && l == null) return null;
    return '${f ?? ''} ${l ?? ''}'.trim();
  }

  /// First subscriber contract that is not null
  SubscriberContract? get subscriberContract {
    for (final device in allDeviceLimits) {
      if (device.subscriberContract != null) {
        return device.subscriberContract;
      }
    }
    return null;
  }

  /// Auto-renew status from first device
  bool get autoRenew => deviceLimits?.autoRenew ?? false;

  @override
  String toString() {
    return 'DeviceLimitsState(status: $status, '
        'deviceCount: $deviceCount, '
        'hasDeviceLimits: $hasDeviceLimits, '
        'errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeviceLimitsState) return false;
    if (other.status != status) return false;
    if (other.errorMessage != errorMessage) return false;
    if (other.lastFetchedAt != lastFetchedAt) return false;
    if (other.isTogglingAutoRenew != isTogglingAutoRenew) return false;
    if (other.allDeviceLimits.length != allDeviceLimits.length) return false;
    for (int i = 0; i < allDeviceLimits.length; i++) {
      if (other.allDeviceLimits[i] != allDeviceLimits[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      Object.hashAll(allDeviceLimits),
      errorMessage,
      lastFetchedAt,
      isTogglingAutoRenew,
    );
  }
}
