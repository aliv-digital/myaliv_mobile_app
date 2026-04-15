import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/widgets/focused_input_border_wrapper.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revBill/prepaid/theme/rev_prepaid_theme.dart';

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
            borderRadius: BorderRadius.circular(RevPrepaidTheme.inputFieldRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: RevPrepaidTheme.input,
            decoration: InputDecoration(
              prefixText:
                  _hasFocus || _controller.text.isNotEmpty ? '\$ ' : null,
              prefixStyle: const TextStyle(
                color: Color(0xFF344054),
                fontSize: 14,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
              ),
              isDense: true,
              border: InputBorder.none,
              hintText: _hasFocus ? ' 0.00' : '\$ 0.00',
              hintStyle: RevPrepaidTheme.hintText,
            ),
          ),
        ),
      ),
    );
  }
}

/// Limit field with label and controller
class LimitFieldWithController extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const LimitFieldWithController({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
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
            value: controller.text,
            onChanged: (value) => controller.text = value,
          ),
        ],
      ),
    );
  }
}
