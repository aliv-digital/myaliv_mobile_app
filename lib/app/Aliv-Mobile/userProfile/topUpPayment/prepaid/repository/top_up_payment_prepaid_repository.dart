import 'dart:async';

import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/change_bundle_result.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/top_up_payment_service.dart';

abstract class TopUpPaymentPrepaidRepository {
  Future<bool> payWithSavedCard({
    required double amount,
    required String primaryPhoneNumber,
    required String cardToken,
  });

  Future<bool> payWithNewCard({
    required double amount,
    required String primaryPhoneNumber,
    required NewCardDetails details,
  });
}

/// Thin adapter: delegates to the shared [TopUpPaymentService]. Failure
/// messages bubble up as `Exception` so the bloc's `try/catch` continues to
/// map them onto `errorMessage`.
class TopUpPaymentPrepaidRepositoryImpl
    implements TopUpPaymentPrepaidRepository {
  TopUpPaymentPrepaidRepositoryImpl({TopUpPaymentService? service})
    : _service = service ?? instance<TopUpPaymentService>();

  final TopUpPaymentService _service;

  @override
  Future<bool> payWithSavedCard({
    required double amount,
    required String primaryPhoneNumber,
    required String cardToken,
  }) async {
    final result = await _service.payWithSavedCard(
      amount: amount,
      primaryPhoneNumber: primaryPhoneNumber,
      cardToken: cardToken,
    );
    return _unwrap(result);
  }

  @override
  Future<bool> payWithNewCard({
    required double amount,
    required String primaryPhoneNumber,
    required NewCardDetails details,
  }) async {
    final result = await _service.payWithNewCard(
      amount: amount,
      primaryPhoneNumber: primaryPhoneNumber,
      details: details,
    );
    return _unwrap(result);
  }

  bool _unwrap(ChangeBundleResult result) {
    switch (result) {
      case ChangeBundleSuccess():
        return true;
      case ChangeBundleFailure(:final message):
        throw Exception(message);
    }
  }
}
