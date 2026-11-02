import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/phone_dropdown_helper.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

/// App-wide active device resolver.
///
/// The home-screen phone dropdown writes the user's choice into
/// `AppUiConfigCubit.state.activeDeviceId`. Any feature that talks to a
/// per-device endpoint reads from this helper so it targets the line the
/// user is currently viewing.
///
/// `AppUiConfigCubit` is a plain Cubit (not Hydrated), so cold restart
/// resets `activeDeviceId` to null — the helper then falls back to the
/// primary device from `DeviceLimitsCubit`.
///
/// All lookups are defensive against missing/partially-stubbed registrations
/// (common in unit tests): any failure resolves to `null` so callers that
/// already handle a null id keep working.
class ActiveDevice {
  const ActiveDevice._();

  static int? id() {
    final override = _activeOverride();
    if (override != null && override > 0) return override;
    return _primaryDeviceId();
  }

  static int require() {
    final value = id();
    if (value == null || value <= 0) {
      throw StateError('ActiveDevice unavailable: no primary or override');
    }
    return value;
  }

  /// TN (MSISDN) for the active device, suffix `_<uuid>` stripped. Returns
  /// null when the active device cannot be matched in `allDeviceLimits`.
  static String? tn() {
    try {
      final activeId = id();
      if (activeId == null) return null;
      final cubit = _tryRead<DeviceLimitsCubit>();
      if (cubit == null) return null;
      final List<DeviceLimitsModel> devices = cubit.state.allDeviceLimits;
      for (final d in devices) {
        if (d.deviceId == activeId) {
          return PhoneDropdownHelper.stripTnSuffix(d.tn);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static int? _activeOverride() {
    try {
      return _tryRead<AppUiConfigCubit>()?.state.activeDeviceId;
    } catch (_) {
      return null;
    }
  }

  static int? _primaryDeviceId() {
    try {
      return _tryRead<DeviceLimitsCubit>()?.state.deviceLimits?.deviceId;
    } catch (_) {
      return null;
    }
  }

  static T? _tryRead<T extends Object>() {
    try {
      return instance<T>();
    } catch (_) {
      return null;
    }
  }
}
