import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/theme/auto_renew_prepaid_theme.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/card_input_helpers.dart';

/// Card details form for the Checkout sheet. Pure UI: collects four inputs,
/// validates them, and hands a [NewCardDetails] back via [onSubmit] when the
/// confirm button is tapped.
class CheckoutCardForm extends StatefulWidget {
  final ValueChanged<NewCardDetails> onSubmit;

  const CheckoutCardForm({super.key, required this.onSubmit});

  @override
  State<CheckoutCardForm> createState() => _CheckoutCardFormState();
}

class _CheckoutCardFormState extends State<CheckoutCardForm> {
  final _holder = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  NewCardDetails? _details;

  @override
  void initState() {
    super.initState();
    for (final c in [_holder, _number, _expiry, _cvv]) {
      c.addListener(_revalidate);
    }
  }

  @override
  void dispose() {
    for (final c in [_holder, _number, _expiry, _cvv]) {
      c.dispose();
    }
    super.dispose();
  }

  void _revalidate() {
    final number = CardValidators.cardNumber(_number.text);
    final expiry = CardValidators.expiryToApi(_expiry.text);
    final cvv = CardValidators.cvv(_cvv.text);
    final name = CardValidators.holderName(_holder.text);

    final next = (number != null && expiry != null && cvv != null && name != null)
        ? NewCardDetails(
            cardNumber: number,
            cardExpiration: expiry,
            cardSecurityCode: cvv,
            cardHolderName: name,
          )
        : null;

    if (next != _details) setState(() => _details = next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _Label('card holder name'),
        _field(_holder, hint: 'Name on card', keyboard: TextInputType.name),
        const SizedBox(height: 14),
        const _Label('card number'),
        _field(
          _number,
          hint: '0000 0000 0000 0000',
          keyboard: TextInputType.number,
          formatters: [CardNumberFormatter()],
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _Label('expiry (mm/yy)'),
                  _field(
                    _expiry,
                    hint: 'MM/YY',
                    keyboard: TextInputType.number,
                    formatters: [ExpiryFormatter()],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _Label('cvv'),
                  _field(
                    _cvv,
                    hint: '123',
                    keyboard: TextInputType.number,
                    obscure: true,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: AutoRenewPrepaidTheme.walletPaymentConfirmButtonHeight,
          child: ElevatedButton(
            onPressed: _details == null ? null : () => widget.onSubmit(_details!),
            style: AutoRenewPrepaidTheme.primaryPillButtonStyle(
              backgroundColor: AutoRenewPrepaidTheme.primary,
            ),
            child: const Text(
              'confirm payment',
              style: AutoRenewPrepaidTheme.walletPaymentConfirmButtonTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller, {
    required String hint,
    required TextInputType keyboard,
    bool obscure = false,
    List<TextInputFormatter> formatters = const <TextInputFormatter>[],
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      inputFormatters: formatters,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AutoRenewPrepaidTheme.walletPaymentAmountFieldBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AutoRenewPrepaidTheme.walletPaymentAmountFieldRadius,
          ),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AutoRenewPrepaidTheme.walletPaymentAmountLabelStyle),
    );
  }
}
