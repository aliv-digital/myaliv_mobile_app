import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../../../../login/widgets/focused_input_border_wrapper.dart';
import '../theme/change_password_prepaid_theme.dart';

class ChangePasswordPrepaidPasswordField extends StatefulWidget {
  final String hint;
  final String value;
  final bool obscure;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggle;

  const ChangePasswordPrepaidPasswordField({
    super.key,
    required this.hint,
    required this.value,
    required this.obscure,
    required this.onChanged,
    required this.onToggle,
  });

  @override
  State<ChangePasswordPrepaidPasswordField> createState() =>
      _ChangePasswordPrepaidPasswordFieldState();
}

class _ChangePasswordPrepaidPasswordFieldState
    extends State<ChangePasswordPrepaidPasswordField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

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
    if (_isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusedInputBorderWrapper(
      isFocused: _isFocused,
      unfocusedBorderColor: ChangePasswordPrepaidTheme.inputBorder,
      radius: 10,
      borderWidth: 1,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: ChangePasswordPrepaidTheme.inputBg,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            SvgPicture.asset(AssetConstant.lockPassSVG2),
            // const Icon(
            //   Icons.lock_outline,
            //   size: 18,
            //   color: ChangePasswordPrepaidTheme.brand,
            // ),
            const SizedBox(width: 5),
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                obscureText: widget.obscure,
                onChanged: widget.onChanged,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: widget.hint,
                  hintStyle: const TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: ChangePasswordPrepaidTheme.hint,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            InkWell(
              onTap: widget.onToggle,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: SvgPicture.asset(
                  widget.obscure
                      ? AssetConstant.hideIconSVG
                      : AssetConstant.viewIconSVG,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    ChangePasswordPrepaidTheme.brand,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
