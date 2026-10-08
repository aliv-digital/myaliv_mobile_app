import 'package:myaliv_mobile_app/app/common/verification/action_verified_result.dart';

import '../cubit/device_limits_cubit.dart';
import '../models/update_limits_request.dart';

/// Keeps the existing limits mutation behind an attempt-bound, one-use result.
class UpgradeCreditLimitSubmission {
  UpgradeCreditLimitSubmission({required this.deviceLimitsCubit});
  final DeviceLimitsCubit deviceLimitsCubit;
  bool _pending = false;
  bool _closed = false;

  Future<bool> submit({
    required int deviceId,
    required UpdateLimitsRequest request,
    required bool Function() isOwnerActive,
    required Future<ActionVerifiedResult<ProtectedAccountAction>?> Function(
      Object,
    )
    verifyAction,
  }) async {
    if (_closed || _pending || deviceLimitsCubit.state.isUpdating) {
      return false;
    }
    _pending = true;
    final attemptId = Object();
    try {
      final verified = await verifyAction(attemptId);
      if (_closed ||
          !isOwnerActive() ||
          deviceLimitsCubit.state.deviceLimits?.deviceId != deviceId ||
          verified == null ||
          !identical(verified.attemptId, attemptId) ||
          verified.purpose != ProtectedAccountAction.upgradeCreditLimit ||
          !verified.consume()) {
        return false;
      }
      return await deviceLimitsCubit.updateLimits(
        deviceAccountId: deviceId,
        request: request,
      );
    } finally {
      _pending = false;
    }
  }

  void close() => _closed = true;
}
