import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../theme/create_password_theme.dart';

class PasswordInput extends StatefulWidget {
  const PasswordInput({
    super.key,
    required this.hint,
    required this.obscureText,
    required this.onChanged,
    required this.onToggle,
  });

  final String hint;
  final bool obscureText;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggle;

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
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
    final innerRadius = (CreatePasswordTheme.inputRadius -
            CreatePasswordTheme.inputBorderWidth)
        .clamp(0.0, CreatePasswordTheme.inputRadius);

    return Container(
      decoration: BoxDecoration(
        gradient:
            _hasFocus ? CreatePasswordTheme.focusedInputBorderGradient : null,
        border: _hasFocus
            ? null
            : Border.all(
                width: CreatePasswordTheme.inputBorderWidth,
                color: CreatePasswordTheme.inputBorderColor,
              ),
        borderRadius: BorderRadius.circular(CreatePasswordTheme.inputRadius),
      ),
      padding: const EdgeInsets.all(CreatePasswordTheme.inputBorderWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: Container(
          height: CreatePasswordTheme.inputHeight,
          padding: CreatePasswordTheme.inputHorizontalPadding,
          color: CreatePasswordTheme.inputBackgroundColor,
          child: Row(
            children: [
              SvgPicture.asset(
                AssetConstant.lockPassSVG,
                width: CreatePasswordTheme.inputIconSize,
                height: CreatePasswordTheme.inputIconSize,
                colorFilter: const ColorFilter.mode(
                  CreatePasswordTheme.inputIconColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: CreatePasswordTheme.iconToFieldGap),

              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  onChanged: widget.onChanged,
                  style: CreatePasswordTheme.inputText,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: CreatePasswordTheme.inputHint,
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),

              const SizedBox(width: CreatePasswordTheme.iconToFieldGap),

              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onToggle,
                child: SizedBox(
                  width: CreatePasswordTheme.suffixIconTapSize,
                  height: CreatePasswordTheme.suffixIconTapSize,
                  child: Icon(
                    widget.obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: CreatePasswordTheme.inputIconSize,
                    color: CreatePasswordTheme.inputIconColor,
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
