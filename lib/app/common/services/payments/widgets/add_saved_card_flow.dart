import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

import '../change_bundle_request_factory.dart';
import '../models/payment_request.dart';
import '../models/payment_success.dart';
import '../screens/payment_iframe_screen.dart';
import 'save_new_card_bottom_sheet.dart';

/// Adds a real saved card through hosted 3DS entry and expiry confirmation.
/// [SavedCardsCubit] saves the result and refreshes the shared card list.
class AddSavedCardFlow {
  const AddSavedCardFlow({required SavedCardsCubit savedCardsCubit})
    : _savedCardsCubit = savedCardsCubit;

  final SavedCardsCubit _savedCardsCubit;

  Future<bool> open(BuildContext context, {required Color appBarColor}) async {
    final ownerRoute = ModalRoute.of(context);
    final navigator = Navigator.of(context);
    String? gatewayError;
    late final MaterialPageRoute<PaymentSuccess> gatewayRoute;
    gatewayRoute = MaterialPageRoute<PaymentSuccess>(
      builder: (_) => PaymentIFrameScreen(
        request: PaymentRequest(
          url: Api.addCreditCard,
          body: ChangeBundleRequestFactory.addCardBodyFor3DS(),
          redirectScheme: 'myaliv',
        ),
        title: 'add card',
        appBarBgColor: appBarColor,
        onSuccess: (success) {
          if (gatewayRoute.isCurrent) {
            navigator.pop(success);
          }
        },
        onFailure: (message) {
          if (gatewayRoute.isCurrent) {
            gatewayError = message;
            navigator.pop();
          }
        },
      ),
    );

    final success = await navigator.push(gatewayRoute);
    if (!context.mounted || ownerRoute?.isCurrent == false) {
      return false;
    }
    if (success == null) {
      if (gatewayError != null) {
        AppToast.show(message: gatewayError!, type: ToastType.error);
      }
      return false;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    final expirationDate = await SaveNewCardBottomSheet.showForExpiryCapture(
      context,
      rejectPastExpiry: true,
    );
    if (!context.mounted ||
        ownerRoute?.isCurrent == false ||
        expirationDate == null) {
      return false;
    }

    final orderId = int.tryParse(success.orderId ?? '');
    if (orderId == null) {
      AppToast.show(
        message: 'Failed to save card. Try again.',
        type: ToastType.error,
      );
      return false;
    }

    final saved = await _savedCardsCubit.saveNewCard(
      orderId: orderId,
      expirationDate: expirationDate,
    );
    if (!context.mounted || ownerRoute?.isCurrent == false) {
      return saved;
    }
    if (saved) {
      AppToast.show(
        message: 'Payment method added successfully!',
        type: ToastType.success,
      );
    } else {
      final message = _savedCardsCubit.state.errorMessage?.trim();
      AppToast.show(
        message: message == null || message.isEmpty
            ? 'Failed to save card. Try again.'
            : message,
        type: ToastType.error,
      );
    }
    return saved;
  }
}
