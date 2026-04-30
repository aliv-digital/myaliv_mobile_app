import 'device_limits_model.dart';

/// Request model for updating balance threshold settings.
///
/// Used with PUT /v1/MyAliv/device/{deviceAccountId}/balance-threshold-settings
class BalanceThresholdSettingsRequest {
  final double roamingLowBalanceThreshold;
  final double balanceThreshold;
  final double roamingTopUpAmount;
  final double autoTopUpAmount;
  final String autoTopUp;
  final String token;

  const BalanceThresholdSettingsRequest({
    required this.roamingLowBalanceThreshold,
    required this.balanceThreshold,
    required this.roamingTopUpAmount,
    required this.autoTopUpAmount,
    required this.autoTopUp,
    required this.token,
  });

  /// Build request from DeviceLimitsModel + user inputs.
  ///
  /// [deviceLimits] - Existing device limits data from API
  /// [balanceThreshold] - User-entered threshold ("when balance falls below")
  /// [autoTopUpAmount] - User selected grid value or custom amount
  /// [cardToken] - Token from selected card in dropdown; also assigned to autoTopUp
  factory BalanceThresholdSettingsRequest.fromDeviceLimits({
    required DeviceLimitsModel deviceLimits,
    required double balanceThreshold,
    required double autoTopUpAmount,
    required String cardToken,
  }) {
    return BalanceThresholdSettingsRequest(
      roamingLowBalanceThreshold: deviceLimits.roamingLowBalanceThreshold,
      balanceThreshold: balanceThreshold,
      roamingTopUpAmount: deviceLimits.roamingTopUpAmount,
      autoTopUpAmount: autoTopUpAmount,
      autoTopUp: cardToken,
      token: cardToken,
    );
  }

  Map<String, dynamic> toJson() => {
        'RoamingLowBalanceThreshold': roamingLowBalanceThreshold,
        'BalanceThreshold': balanceThreshold,
        'RoamingTopUpAmount': roamingTopUpAmount,
        'AutoTopUpAmount': autoTopUpAmount,
        'AutoTopUp': autoTopUp,
        'token': token,
      };
}
