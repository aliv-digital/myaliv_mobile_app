import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../../../../login/widgets/focused_input_border_wrapper.dart';
import '../theme/enter_password_prepaid_theme.dart';

class EnterPasswordPrepaidPasswordInput extends StatefulWidget {
  final String value;
  final bool obscure;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggle;

  const EnterPasswordPrepaidPasswordInput({
    super.key,
    required this.value,
    required this.obscure,
    required this.onChanged,
    required this.onToggle,
  });

  @override
  State<EnterPasswordPrepaidPasswordInput> createState() =>
      _EnterPasswordPrepaidPasswordInputState();
}

class _EnterPasswordPrepaidPasswordInputState
    extends State<EnterPasswordPrepaidPasswordInput> {
  final FocusNode _passwordFocusNode = FocusNode();
  bool _hasPasswordFocus = false;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _passwordFocusNode.removeListener(_onFocusChanged);
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_hasPasswordFocus != _passwordFocusNode.hasFocus) {
      setState(() {
        _hasPasswordFocus = _passwordFocusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusedInputBorderWrapper(
      isFocused: _hasPasswordFocus,
      unfocusedBorderColor: EnterPasswordPrepaidTheme.inputBorder,
      radius: 6,
      borderWidth: 1,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, size: 20, color: Color(0xFF6B7280)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                focusNode: _passwordFocusNode,
                obscureText: widget.obscure,
                onChanged: widget.onChanged,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: 'enter your password',
                  hintStyle: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                    color: Color(0xFF707070),
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 11),
            InkWell(
              onTap: widget.onToggle,
              borderRadius: BorderRadius.circular(999),
              child: SvgPicture.asset(
                widget.obscure
                    ? AssetConstant.hideIconSVG
                    : AssetConstant.viewIconSVG,
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
