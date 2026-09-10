import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/save_credit_card_button.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/save_new_card_bottom_sheet.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

/// Post-payment "save credit card" affordance for 3DS flows.
///
/// Tapping the button opens [SaveNewCardBottomSheet] where the user
/// confirms the expiry date. Hides itself after a successful save (one-shot).
class SaveNewCardOnReceiptSection extends StatefulWidget {
  const SaveNewCardOnReceiptSection({super.key, required this.orderId});

  final String orderId;

  @override
  State<SaveNewCardOnReceiptSection> createState() =>
      _SaveNewCardOnReceiptSectionState();
}

class _SaveNewCardOnReceiptSectionState
    extends State<SaveNewCardOnReceiptSection> {
  bool _saved = false;

  Future<void> _onTap() async {
    final result = await SaveNewCardBottomSheet.show(
      context,
      orderId: widget.orderId,
    );

    if (!mounted) return;

    if (result == true) {
      setState(() => _saved = true);
      AppToast.show(
        message: 'your card has been saved successfully',
        type: ToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_saved) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SaveCreditCardButton(onTap: _onTap),
    );
  }
}
