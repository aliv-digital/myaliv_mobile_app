import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';

/// Static helper for PhoneDropdown logic.
///
/// Takes plain data so the widget
/// only needs to pull current state from cubits and pass it in — no cubit
/// access inside the helper, fully testable.
class PhoneDropdownHelper {
  const PhoneDropdownHelper._();

  // TNs can arrive as "2428997820_97dc5ea5-fdf7-49d3-83ab-50e735c45791";
  // strip the "_<uuid>" suffix before processing.
  static String stripTnSuffix(String tn) {
    final i = tn.indexOf('_');
    return i == -1 ? tn : '${tn.substring(0, i)}*DC*';
  }

  /// First device's TN (suffix-stripped). Empty string if devices is empty.
  static String getFirstDeviceTn(List<DeviceLimitsModel> devices) {
    if (devices.isEmpty) return '';
    return stripTnSuffix(devices.first.tn.trim());
  }

  /// All unique phone numbers from TNs, or phoneNumber/altPhoneNumber as fallback.
  static List<String> getPhoneNumbers(AccountInfoModel? accountInfo) {
    if (accountInfo == null) return [''];

    if (accountInfo.tNs.isNotEmpty) {
      final unique = <String>{};
      for (final tn in accountInfo.tNs) {
        final phone = stripTnSuffix(tn.trim());
        if (phone.isNotEmpty) unique.add(phone);
      }
      return unique.toList();
    }

    final phones = <String>{};
    final phone = accountInfo.phoneNumber.trim();
    final alt = accountInfo.altPhoneNumber.trim();
    if (phone.isNotEmpty) phones.add(phone);
    if (alt.isNotEmpty) phones.add(alt);
    return phones.isNotEmpty ? phones.toList() : [''];
  }

  /// True when first device's TN equals accountInfo.primaryPhoneNumber.
  ///
  /// Controls dropdown mode:
  ///   true  → show all numbers (customer can switch)
  ///   false → show only first device's TN (single item)
  static bool isPrimary(
    AccountInfoModel? accountInfo,
    List<DeviceLimitsModel> devices,
  ) {
    if (accountInfo == null) return false;
    final deviceTn = getFirstDeviceTn(devices);
    if (deviceTn.isEmpty) return false;
    return deviceTn == accountInfo.primaryPhoneNumber.trim();
  }

  /// Numbers the dropdown should render.
  ///   isPrimary → full deduplicated list
  ///   !isPrimary, device available → [deviceTn] only
  ///   no device → full list (graceful fallback)
  static List<String> getVisibleNumbers(
    AccountInfoModel? accountInfo,
    List<DeviceLimitsModel> devices,
  ) {
    final deviceTn = getFirstDeviceTn(devices);
    if (deviceTn.isEmpty) return getPhoneNumbers(accountInfo);
    return isPrimary(accountInfo, devices)
        ? getPhoneNumbers(accountInfo)
        : [deviceTn];
  }

  /// The number to auto-select and mark with the primary badge.
  ///
  /// Return value is ALWAYS contained in getVisibleNumbers(), so it is safe
  /// to use as DropdownButton2.value without triggering the uniqueness assert.
  static String getPrimaryPhone(
    AccountInfoModel? accountInfo,
    List<DeviceLimitsModel> devices,
  ) {
    if (accountInfo == null) return '';

    // Use visibleNumbers as the source of truth so the returned value is
    // always a valid dropdown item regardless of isPrimary mode.
    final visibleNums = getVisibleNumbers(accountInfo, devices);

    final deviceTn = getFirstDeviceTn(devices);
    if (deviceTn.isNotEmpty && visibleNums.contains(deviceTn)) return deviceTn;

    final primary = accountInfo.primaryPhoneNumber.trim();
    if (primary.isNotEmpty && visibleNums.contains(primary)) return primary;

    final phone = accountInfo.phoneNumber.trim();
    if (phone.isNotEmpty && visibleNums.contains(phone)) return phone;

    final alt = accountInfo.altPhoneNumber.trim();
    if (alt.isNotEmpty && visibleNums.contains(alt)) return alt;

    return visibleNums.isNotEmpty ? visibleNums.first : '';
  }
}
