import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/can_submit_order_result.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/send_topup_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/top_up_prepaid_repository.dart';

class TopUpPrepaidNumberPostPaidRepository {
  TopUpPrepaidNumberPostPaidRepository({
    SendTopupRepository? sendTopupRepo,
    TopUpPrepaidRepository? topUpRepo,
  })  : _sendTopupRepo = sendTopupRepo ?? instance<SendTopupRepository>(),
        _topUpRepo = topUpRepo ?? TopUpPrepaidRepository();

  final SendTopupRepository _sendTopupRepo;
  final TopUpPrepaidRepository _topUpRepo;

  /// Runs all three preflight gates before navigating to confirmation.
  /// Throws [TopUpPrepaidNumberException] with a user-facing message on any failure.
  Future<void> runGates({
    required String number,
    required double amount,
  }) async {
    // Gate 0: is this an Aliv number?
    final existsResult = await _sendTopupRepo.phoneNumberExists(number);
    if (existsResult == PhoneExistsResult.invalidDevice) {
      throw TopUpPrepaidNumberException(
        'this number is not registered on aliv. please verify the number.',
      );
    }
    if (existsResult == PhoneExistsResult.unknown) {
      throw TopUpPrepaidNumberException(SendTopupRepository.caseDMessage);
    }

    // Gate 2: recipient transfer eligibility.
    final transferError = await _sendTopupRepo.transferIsValid(number);
    if (transferError != null) {
      throw TopUpPrepaidNumberException(transferError);
    }

    // Gate 3: no concurrent order in flight.
    try {
      final orderResult = await _topUpRepo.canSubmitOrder(amount: amount);
      if (!orderResult.canProceed) {
        throw TopUpPrepaidNumberException(
          CanSubmitOrderResult.pendingOrdersMessage,
        );
      }
    } on TopUpPrepaidNumberException {
      rethrow;
    } on CanSubmitOrderException {
      throw TopUpPrepaidNumberException(SendTopupRepository.caseDMessage);
    }
  }
}

class TopUpPrepaidNumberException implements Exception {
  final String message;
  const TopUpPrepaidNumberException(this.message);

  @override
  String toString() => message;
}
