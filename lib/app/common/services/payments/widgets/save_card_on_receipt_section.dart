import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/change_bundle_request_factory.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_request.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_success.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/screens/payment_iframe_screen.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/save_credit_card_button.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/save_new_card_bottom_sheet.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

/// Post-payment "save credit card" affordance. Renders nothing unless
/// [details] is non-null (signals a new card was used for the payment).
/// Hides itself permanently after a successful save (one-shot).
///
/// Opens a 3DS WebView via [PaymentIFrameScreen] → POST /CreditCard/add,
/// then auto-calls POST /CreditCard/savenew on the callback.
class SaveCardOnReceiptSection extends StatefulWidget {
  const SaveCardOnReceiptSection({super.key, required this.details});

  final NewCardDetails? details;

  @override
  State<SaveCardOnReceiptSection> createState() =>
      _SaveCardOnReceiptSectionState();
}

class _SaveCardOnReceiptSectionState extends State<SaveCardOnReceiptSection> {
  bool _saved = false;

  Future<void> _onTap() async {
    if (widget.details == null) return;

    // Step 1: capture expiry before opening the iframe.
    final expirationDate =
        await SaveNewCardBottomSheet.showForExpiryCapture(context);
    if (!mounted || expirationDate == null) return;

    final cubit = instance<SavedCardsCubit>();
    final navigator = Navigator.of(context);

    navigator.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PaymentIFrameScreen(
          request: PaymentRequest(
            url: Api.addCreditCard,
            body: ChangeBundleRequestFactory.addCardBodyFor3DS(),
            redirectScheme: 'myaliv',
          ),
          title: 'add card',
          appBarBgColor: Colors.white,
          onSuccess: (PaymentSuccess success) async {
            navigator.pop();
            final orderId = int.tryParse(success.orderId ?? '');
            if (orderId == null) {
              AppToast.show(
                message: 'Failed to save card. Try again.',
                type: ToastType.error,
              );
              return;
            }
            final ok = await cubit.saveNewCard(
              orderId: orderId,
              expirationDate: expirationDate, // captured before iframe
            );
            if (ok) {
              if (mounted) setState(() => _saved = true);
              final serverMsg = success.queryParams['Message']?.trim();
              AppToast.show(
                message: (serverMsg != null && serverMsg.isNotEmpty)
                    ? serverMsg
                    : 'your card has been saved successfully',
                type: ToastType.success,
              );
            } else {
              final msg = cubit.state.errorMessage?.trim();
              AppToast.show(
                message: (msg == null || msg.isEmpty)
                    ? 'Failed to save card. Try again.'
                    : msg,
                type: ToastType.error,
              );
            }
          },
          onFailure: (String msg) {
            navigator.pop();
            AppToast.show(message: msg, type: ToastType.error);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.details == null || _saved) return const SizedBox.shrink();

    return BlocProvider<SavedCardsCubit>.value(
      value: instance<SavedCardsCubit>(),
      child: BlocBuilder<SavedCardsCubit, SavedCardsState>(
        buildWhen: (prev, curr) => prev.isAddingCard != curr.isAddingCard,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SaveCreditCardButton(
              onTap: _onTap,
              isLoading: state.isAddingCard,
            ),
          );
        },
      ),
    );
  }
}
