import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verified_result.dart';
import 'package:myaliv_mobile_app/core/appConfig/active_device.dart';

/// Form-local data only; never passed through the OTP route or persisted.
class AutoTopUpSubmissionSnapshot {
  AutoTopUpSubmissionSnapshot({
    required this.attemptId,
    required this.deviceId,
    required this.balanceThreshold,
    required this.autoTopUpAmount,
    required this.cardToken,
    required this.signature,
  });

  final Object attemptId;
  final int deviceId;
  final double balanceThreshold;
  final double autoTopUpAmount;
  final String cardToken;
  final String signature;
}

/// Writes the mutation after a one-use OTP capability has already been
/// obtained upstream (Setup tab) and handed in via [verifiedResult].
class AutoTopUpSubmission {
  AutoTopUpSubmission({required this.deviceLimitsCubit});

  final DeviceLimitsCubit deviceLimitsCubit;
  AutoTopUpSubmissionSnapshot? _pending;
  bool _closed = false;

  /// Null means cancelled/stale; false means the mutation failed.
  Future<bool?> submit({
    required AutoTopUpSubmissionSnapshot snapshot,
    required bool Function(AutoTopUpSubmissionSnapshot) isCurrent,
    required ActionVerifiedResult<ProtectedAccountAction> verifiedResult,
  }) async {
    if (_closed || _pending != null || deviceLimitsCubit.state.isUpdating) {
      return null;
    }
    if (snapshot.deviceId <= 0 || ActiveDevice.id() != snapshot.deviceId) {
      return false;
    }
    if (!identical(verifiedResult.attemptId, snapshot.attemptId) ||
        verifiedResult.purpose != ProtectedAccountAction.autoTopUp) {
      return null;
    }
    _pending = snapshot;
    try {
      if (_closed ||
          !identical(_pending, snapshot) ||
          !isCurrent(snapshot) ||
          ActiveDevice.id() != snapshot.deviceId ||
          !verifiedResult.consume()) {
        return null;
      }
      return await deviceLimitsCubit.updateBalanceThresholdSettings(
        balanceThreshold: snapshot.balanceThreshold,
        autoTopUpAmount: snapshot.autoTopUpAmount,
        cardToken: snapshot.cardToken,
      );
    } finally {
      if (identical(_pending, snapshot)) {
        _pending = null;
      }
    }
  }

  void close() {
    _closed = true;
    _pending = null;
  }
}
