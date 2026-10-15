import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verified_result.dart';

/// Form-local data only; never passed through the OTP route or persisted.
class AutoTopUpSubmissionSnapshot {
  AutoTopUpSubmissionSnapshot({
    required this.deviceId,
    required this.balanceThreshold,
    required this.autoTopUpAmount,
    required this.cardToken,
    required this.signature,
  });

  final Object attemptId = Object();
  final int deviceId;
  final double balanceThreshold;
  final double autoTopUpAmount;
  final String cardToken;
  final String signature;
}

/// Adds verification without changing the existing configuration operation.
class AutoTopUpSubmission {
  AutoTopUpSubmission({required this.deviceLimitsCubit});

  final DeviceLimitsCubit deviceLimitsCubit;
  AutoTopUpSubmissionSnapshot? _pending;
  bool _closed = false;

  /// Null means cancelled/stale; false means the original mutation failed.
  Future<bool?> submit({
    required AutoTopUpSubmissionSnapshot snapshot,
    required bool Function(AutoTopUpSubmissionSnapshot) isCurrent,
    required Future<ActionVerifiedResult<ProtectedAccountAction>?> Function(
      AutoTopUpSubmissionSnapshot,
    )
    verifyAction,
  }) async {
    if (_closed || _pending != null || deviceLimitsCubit.state.isUpdating) {
      return null;
    }
    if (snapshot.deviceId <= 0 ||
        deviceLimitsCubit.state.deviceLimits?.deviceId != snapshot.deviceId) {
      return false;
    }
    _pending = snapshot;
    try {
      final verified = await verifyAction(snapshot);
      if (_closed ||
          !identical(_pending, snapshot) ||
          !isCurrent(snapshot) ||
          deviceLimitsCubit.state.deviceLimits?.deviceId != snapshot.deviceId ||
          verified == null ||
          !identical(verified.attemptId, snapshot.attemptId) ||
          verified.purpose != ProtectedAccountAction.autoTopUp ||
          !verified.consume()) {
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
