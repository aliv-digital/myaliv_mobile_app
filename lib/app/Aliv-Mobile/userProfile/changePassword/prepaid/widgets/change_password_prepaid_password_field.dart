import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../../../../login/widgets/focused_input_border_wrapper.dart';
import '../theme/change_password_prepaid_theme.dart';

class ChangePasswordPrepaidPasswordField extends StatefulWidget {
  final String hint;
  final String value;
  final bool obscure;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggle;
  final FocusNode? focusNode;

  const ChangePasswordPrepaidPasswordField({
    super.key,
    required this.hint,
    required this.value,
    required this.obscure,
    required this.onChanged,
    required this.onToggle,
    this.errorText,
    this.focusNode,
  });

  @override
  State<ChangePasswordPrepaidPasswordField> createState() =>
      _ChangePasswordPrepaidPasswordFieldState();
}

class _ChangePasswordPrepaidPasswordFieldState
    extends State<ChangePasswordPrepaidPasswordField> {
  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _isFocused = _effectiveFocusNode.hasFocus;
    _effectiveFocusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant ChangePasswordPrepaidPasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)?.removeListener(
        _onFocusChanged,
      );
      _effectiveFocusNode.addListener(_onFocusChanged);
      _isFocused = _effectiveFocusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    (widget.focusNode ?? _internalFocusNode)?.removeListener(_onFocusChanged);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_isFocused != _effectiveFocusNode.hasFocus) {
      setState(() {
        _isFocused = _effectiveFocusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final iconColor = hasError
        ? ChangePasswordPrepaidTheme.error
        : ChangePasswordPrepaidTheme.brand;
    final textColor = hasError
        ? ChangePasswordPrepaidTheme.error
        : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FocusedInputBorderWrapper(
          isFocused: !hasError && _isFocused,
          unfocusedBorderColor: hasError
              ? ChangePasswordPrepaidTheme.error
              : Colors.transparent,
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
                SvgPicture.asset(
                  AssetConstant.lockPassSVG2,
                  colorFilter: hasError
                      ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                      : null,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    focusNode: _effectiveFocusNode,
                    obscureText: widget.obscure,
                    onChanged: widget.onChanged,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: widget.hint,
                      hintStyle: TextStyle(
                        fontFamily: 'CircularPro',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: hasError
                            ? ChangePasswordPrepaidTheme.error
                            : ChangePasswordPrepaidTheme.hint,
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textColor,
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
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.topLeft,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    widget.errorText!,
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ChangePasswordPrepaidTheme.error,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
