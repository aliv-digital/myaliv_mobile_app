import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/checkout_card_bottom_sheet.dart';

/// Feature-local entry point for collecting a new card's details.
///
/// The shared checkout sheet owns the UI and validation. This wrapper keeps
/// the add/edit-cards feature decoupled from payment-specific call sites.
class AddCardDetailsBottomSheet {
  AddCardDetailsBottomSheet._();

  static Future<NewCardDetails?> show(BuildContext context) {
    return CheckoutCardBottomSheet.showForAddCard(context);
  }
}
