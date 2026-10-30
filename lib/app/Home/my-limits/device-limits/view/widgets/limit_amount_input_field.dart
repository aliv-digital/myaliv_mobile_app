import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/widgets/focused_input_border_wrapper.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revBill/prepaid/theme/rev_prepaid_theme.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';

import '../../logic/credit_limit_value_validation.dart';

/// Input field for limit amount with dollar prefix
class LimitAmountInputField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const LimitAmountInputField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<LimitAmountInputField> createState() => _LimitAmountInputFieldState();
}

class _LimitAmountInputFieldState extends State<LimitAmountInputField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant LimitAmountInputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_hasFocus != _focusNode.hasFocus) {
      setState(() => _hasFocus = _focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FocusedInputBorderWrapper(
        isFocused: _hasFocus,
        unfocusedBorderColor: RevPrepaidTheme.inputFieldBorderColor,
        radius: RevPrepaidTheme.inputFieldRadius,
        borderWidth: RevPrepaidTheme.inputFieldBorderWidth,
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F8),
            borderRadius: BorderRadius.circular(
              RevPrepaidTheme.inputFieldRadius,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Row(
            children: [
              const Text(
                r'$',
                style: TextStyle(
                  color: Color(0xFF344054),
                  fontSize: 14,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: RevPrepaidTheme.input,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: RevPrepaidTheme.hintText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Limit field with label and controller
class LimitFieldWithController extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool validateValue;

  const LimitFieldWithController({
    super.key,
    required this.label,
    required this.controller,
    this.validateValue = false,
  });

  @override
  State<LimitFieldWithController> createState() =>
      _LimitFieldWithControllerState();
}

class _LimitFieldWithControllerState extends State<LimitFieldWithController> {
  bool _hasEdited = false;

  @override
  Widget build(BuildContext context) {
    final error = _hasEdited || widget.validateValue
        ? validateCreditLimitValue(widget.controller.text)
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              color: Color(0xFF1C1C1C),
              fontSize: 14,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 10),
          LimitAmountInputField(
            value: widget.controller.text,
            onChanged: (value) {
              widget.controller.text = value;
              setState(() => _hasEdited = true);
            },
          ),
          if (error != null) ...[
            const SizedBox(height: 6),
            Text(
              error,
              style: TextStyle(
                color: ColorManager.redColor,
                fontFamily: RevPrepaidTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
