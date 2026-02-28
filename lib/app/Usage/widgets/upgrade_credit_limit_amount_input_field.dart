import 'package:flutter/material.dart';

import '../../Aliv-Mobile-Guest/guestTopUp/widgets/focused_input_border_wrapper.dart';
import '../../Aliv-Mobile/revBillPay/revBill/prepaid/theme/rev_prepaid_theme.dart';

class AmountInputField extends StatefulWidget {
  final String value; // formatted "$ 0.00"
  final ValueChanged<String> onChanged;

  const AmountInputField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField> {
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
  void didUpdateWidget(covariant AmountInputField oldWidget) {
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
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,//RevPrepaidTheme.inputFieldHeight,
      child: FocusedInputBorderWrapper(
        isFocused: _hasFocus,
        unfocusedBorderColor: RevPrepaidTheme.inputFieldBorderColor,
        radius: RevPrepaidTheme.inputFieldRadius,
        borderWidth: RevPrepaidTheme.inputFieldBorderWidth,
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFFF1F1F8),
            borderRadius: BorderRadius.circular(
              RevPrepaidTheme.inputFieldRadius,
            ),
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
              // prefix: Text(
              //   '\$ ',
              //   style: TextStyle(
              //     color: Colors.black,
              //     fontSize: 16,
              //     fontFamily: 'CircularPro',
              //     fontWeight: FontWeight.w500,
              //     height: 1.25,
              //   ),
              // ),
              prefixText: _hasFocus  || _controller.text.isNotEmpty ? '\$ ':null,
              prefixStyle: const TextStyle(
                color: Color(0xFF344054),
                fontSize: 14,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
              ),
              isDense: true,
              border: InputBorder.none,
              hintText: _hasFocus ? ' 0.00':'\$ 0.00',
              hintStyle: RevPrepaidTheme.hintText,
            ),
          ),
        ),
      ),
    );
  }
}
