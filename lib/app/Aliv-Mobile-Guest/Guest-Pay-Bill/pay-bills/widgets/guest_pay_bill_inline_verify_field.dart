import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

import '../theme/guest_pay_bill_theme.dart';
import 'guest_pay_bill_focused_input_border_wrapper.dart';

class GuestPayBillInlineVerifyField extends StatefulWidget {
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;
  final bool loading;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  const GuestPayBillInlineVerifyField({
    super.key,
    required this.hint,
    required this.keyboardType,
    required this.enabled,
    required this.loading,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  State<GuestPayBillInlineVerifyField> createState() =>
      _GuestPayBillInlineVerifyFieldState();
}

class _GuestPayBillInlineVerifyFieldState
    extends State<GuestPayBillInlineVerifyField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
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
    return GuestPayBillFocusedInputBorderWrapper(
      isFocused: _hasFocus,
      unfocusedBorderColor: GuestPayBillTheme.unfocusedInputBorderColor,
      child: Container(
        height: GuestPayBillTheme.inlineVerifyFieldHeight,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: GuestPayBillTheme.fieldBg,
          borderRadius: BorderRadius.circular(GuestPayBillTheme.radius),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                onChanged: widget.onChanged,
                style: GuestPayBillTheme.inputTextStyle,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  hintStyle: TextStyle(
                    color: GuestPayBillTheme.placeholder,
                    fontSize: 13,
                    fontFamily: AppConstants.defaultFontFamily,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ).copyWith(hintText: widget.hint),
              ),
            ),
            const SizedBox(width: 8),
            GuestPayBillInlineSubmitButton(
              loading: widget.loading,
              enabled: widget.enabled,
              onTap: widget.onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class GuestPayBillInlineSubmitButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const GuestPayBillInlineSubmitButton({
    super.key,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Keep the button visually active from initial state, then guard invalid submits.
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: GuestPayBillTheme.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        onPressed: loading
            ? null
            : () {
                if (enabled) {
                  onTap();
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please enter required details first.',
                      style: TextStyle(
                        fontFamily: AppConstants.defaultFontFamily,
                      ),
                    ),
                  ),
                );
              },
        child: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'submit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: AppConstants.defaultFontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
