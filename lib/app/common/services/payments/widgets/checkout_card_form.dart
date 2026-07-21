import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/theme/auto_renew_prepaid_theme.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/card_input_helpers.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

/// Card details form for the Checkout sheet. Pure UI: collects four inputs,
/// validates them, and hands a [NewCardDetails] back via [onSubmit] when the
/// confirm button is tapped.
class CheckoutCardForm extends StatefulWidget {
  final ValueChanged<NewCardDetails> onSubmit;
  final String submitLabel;
  final bool useSavedCardNumberRules;

  const CheckoutCardForm({
    super.key,
    required this.onSubmit,
    this.submitLabel = 'confirm payment',
    this.useSavedCardNumberRules = false,
  });

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
    final number = widget.useSavedCardNumberRules
        ? CardValidators.savedCardNumber(_number.text)
        : CardValidators.cardNumber(_number.text);
    final expiry = CardValidators.expiryToApi(_expiry.text);
    final cvv = CardValidators.cvv(_cvv.text);
    final name = CardValidators.holderName(_holder.text);

    final next =
        (number != null && expiry != null && cvv != null && name != null)
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
        _field(_holder, hint: 'name on card', keyboard: TextInputType.name),
        const SizedBox(height: 16),
        const _Label('card number'),
        _field(
          _number,
          hint: '0000 0000 0000 0000',
          keyboard: TextInputType.number,
          prefix: const _VisaPrefix(),
          formatters: [
            CardNumberFormatter(
              maxDigits: widget.useSavedCardNumberRules ? 16 : 19,
            ),
          ],
        ),
        const SizedBox(height: 16),
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
            const SizedBox(width: 16),
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
          height: 50,
          child: ElevatedButton(
            onPressed:
                _details == null ? null : () => widget.onSubmit(_details!),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shadowColor: Colors.transparent,
              backgroundColor: const Color(0xFF645D9C),
              disabledBackgroundColor: const Color(0x4D645D9C),
              foregroundColor: const Color(0xFFF1F1F8),
              disabledForegroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: Text(
              widget.submitLabel,
              style: _CheckoutCardFormStyles.button,
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
    Widget? prefix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      inputFormatters: formatters,
      style: _CheckoutCardFormStyles.input,
      cursorColor: const Color(0xFF645D9C),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: _CheckoutCardFormStyles.hint,
        filled: true,
        fillColor: const Color(0xFFF3F1FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        isDense: true,
        constraints: const BoxConstraints.tightFor(height: 48),
        // The fill container is sized by contentPadding + the 20px text
        // line, not by `constraints`: 14 + 20 + 14 = the full 48px height.
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        prefixIcon: prefix,
        // The prefix sizes itself (12 + 34 + 8); the decorator centers it
        // vertically within the 48px field.
        prefixIconConstraints: const BoxConstraints(),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: _CheckoutCardFormStyles.label),
    );
  }
}

class _VisaPrefix extends StatelessWidget {
  const _VisaPrefix();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      // The asset's 46x32 viewBox is a hair wider than Figma's fixed
      // 34x24 box; the tight SizedBox + fill keep it exactly 34x24.
      child: SizedBox(
        width: 34,
        height: 24,
        child: SvgPicture.asset(
          AssetConstant.visaCardSVG,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

class _CheckoutCardFormStyles {
  const _CheckoutCardFormStyles._();

  static const TextStyle label = TextStyle(
    color: Color(0xFF222222),
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
  );

  static const TextStyle input = TextStyle(
    color: Color(0xFF1C1C1C),
    fontSize: 14,
    fontFamily: AutoRenewPrepaidTheme.fontFamily,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  static const TextStyle hint = TextStyle(
    color: Color(0x661C1C1C),
    fontSize: 14,
    fontFamily: AutoRenewPrepaidTheme.fontFamily,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
}
