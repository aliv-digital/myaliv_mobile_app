import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

/// Reusable country-code + phone input row with inline submit button.
///
/// This follows the same structure as `CustomCountryPhoneInputRow`, but the
/// right input container includes a submit action button (e.g. "submit").
class CustomCountryPhoneInputSubmitRow extends StatefulWidget {
  const CustomCountryPhoneInputSubmitRow({
    super.key,
    required this.hintText,
    required this.flagEmoji,
    required this.dialCode,
    required this.onChanged,
    required this.onSubmit,
    required this.submitEnabled,
    required this.submitLoading,
    this.countryIsoCode,
    this.labelText,
    this.onTapCountryPicker,
    this.enableCountryPicker = true,
    this.showCountryArrow = true,
    this.keyboardType = TextInputType.phone,
    this.inputFormatters,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.onSubmitted,
    this.backgroundColor = const Color(0xFFF2F1F9),
    this.unfocusedBorderColor = const Color(0xFFE0E0E0),
    this.hideUnfocusedInputBorder = false,
    this.focusedBorderGradient = _defaultFocusedBorderGradient,
    this.borderRadius = 8,
    this.borderWidth = 1,
    this.fieldHeight = 50,
    this.countryPickerWidth = 96,
    this.countryToPhoneGap = 10,
    this.countryPickerPadding = const EdgeInsets.symmetric(horizontal: 10),
    this.showCountryPickerBorder = false,
    this.countryPickerBorderColor = Colors.transparent,
    this.countryPickerBorderWidth = 1,
    this.inputContainerPadding = const EdgeInsets.all(8),
    this.phoneInputPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.countryFlagToDialGap = 6,
    this.countryDialToArrowGap = 4,
    this.countryArrowIconSize = 18,
    this.countryArrowColor = const Color(0xFF5A5796),
    this.countryArrowIcon = Icons.keyboard_arrow_down_rounded,
    this.submitButtonHeight = 34,
    this.submitButtonHorizontalPadding = 14,
    this.submitButtonBorderRadius = 100,
    this.submitButtonBackgroundColor = const Color(0xFF5A5796),
    this.submitButtonTextColor = Colors.white,
    this.submitText = 'submit',
    this.submitTextStyle,
    this.submitDisabledMessage = 'Please enter required details first.',
    this.submitButtonGap = 8,
    this.labelToRowGap = 8,
    this.labelStyle,
    this.flagStyle,
    this.dialCodeStyle,
    this.phoneInputStyle,
    this.phoneHintStyle,
  });

  final String? labelText;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  final bool submitEnabled;
  final bool submitLoading;
  final String submitText;
  final TextStyle? submitTextStyle;
  final String submitDisabledMessage;

  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool readOnly;
  final ValueChanged<String>? onSubmitted;

  final String flagEmoji;
  final String dialCode;
  final String? countryIsoCode;
  final VoidCallback? onTapCountryPicker;
  final bool enableCountryPicker;
  final bool showCountryArrow;

  final Color backgroundColor;
  final Color unfocusedBorderColor;
  // If true, the phone input border is hidden in neutral/unfocused state.
  final bool hideUnfocusedInputBorder;
  final LinearGradient focusedBorderGradient;
  final double borderRadius;
  final double borderWidth;

  final double fieldHeight;
  final double countryPickerWidth;
  final double countryToPhoneGap;
  final EdgeInsets countryPickerPadding;
  final bool showCountryPickerBorder;
  final Color countryPickerBorderColor;
  final double countryPickerBorderWidth;
  final EdgeInsets inputContainerPadding;
  final EdgeInsets phoneInputPadding;
  final double countryFlagToDialGap;
  final double countryDialToArrowGap;
  final double countryArrowIconSize;
  final Color countryArrowColor;
  final IconData countryArrowIcon;
  final double submitButtonHeight;
  final double submitButtonHorizontalPadding;
  final double submitButtonBorderRadius;
  final Color submitButtonBackgroundColor;
  final Color submitButtonTextColor;
  final double submitButtonGap;
  final double labelToRowGap;

  final TextStyle? labelStyle;
  final TextStyle? flagStyle;
  final TextStyle? dialCodeStyle;
  final TextStyle? phoneInputStyle;
  final TextStyle? phoneHintStyle;

  static const LinearGradient _defaultFocusedBorderGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      Color(0xFFFFC627),
      Color(0xFF00B3E3),
      Color(0xFF4B298C),
      Color(0xFFFF9BB1),
      Color(0xFFFF6C36),
    ],
  );

  @override
  State<CustomCountryPhoneInputSubmitRow> createState() =>
      _CustomCountryPhoneInputSubmitRowState();
}

class _CustomCountryPhoneInputSubmitRowState
    extends State<CustomCountryPhoneInputSubmitRow> {
  late FocusNode _effectiveFocusNode;
  late bool _ownsFocusNode;
  bool _hasPhoneFocus = false;

  @override
  void initState() {
    super.initState();
    _bindFocusNode(widget.focusNode);
  }

  @override
  void didUpdateWidget(covariant CustomCountryPhoneInputSubmitRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _unbindFocusNode();
      _bindFocusNode(widget.focusNode);
    }
  }

  @override
  void dispose() {
    _unbindFocusNode();
    super.dispose();
  }

  void _bindFocusNode(FocusNode? externalFocusNode) {
    _effectiveFocusNode = externalFocusNode ?? FocusNode();
    _ownsFocusNode = externalFocusNode == null;
    _hasPhoneFocus = _effectiveFocusNode.hasFocus;
    _effectiveFocusNode.addListener(_onPhoneFocusChanged);
  }

  void _unbindFocusNode() {
    _effectiveFocusNode.removeListener(_onPhoneFocusChanged);
    if (_ownsFocusNode) {
      _effectiveFocusNode.dispose();
    }
  }

  void _onPhoneFocusChanged() {
    if (_hasPhoneFocus != _effectiveFocusNode.hasFocus) {
      setState(() {
        _hasPhoneFocus = _effectiveFocusNode.hasFocus;
      });
    }
  }

  Widget _buildCountryFlag(TextStyle resolvedFlagStyle) {
    final String? isoCode = widget.countryIsoCode;
    if (isoCode != null && isoCode.isNotEmpty) {
      final String assetIsoCode =
          isoCode.toUpperCase() == 'AC' ? 'SH' : isoCode.toUpperCase();
      return Image.asset(
        'assets/${assetIsoCode.toLowerCase()}.png',
        package: 'country_pickers',
        width: 26,
        height: 20,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Text(widget.flagEmoji, style: resolvedFlagStyle);
        },
      );
    }
    return Text(widget.flagEmoji, style: resolvedFlagStyle);
  }

  void _onSubmitTapped() {
    if (widget.submitLoading) {
      return;
    }
    if (widget.submitEnabled) {
      widget.onSubmit();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.submitDisabledMessage,
          style: const TextStyle(fontFamily: AppConstants.defaultFontFamily),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle resolvedLabelStyle = widget.labelStyle ??
        const TextStyle(
          fontSize: 14,
          height: 1.43,
          fontFamily: AppConstants.defaultFontFamily,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        );
    final TextStyle resolvedFlagStyle = widget.flagStyle ??
        const TextStyle(
          fontSize: 18,
          fontFamily: AppConstants.defaultFontFamily,
        );
    final TextStyle resolvedDialStyle = widget.dialCodeStyle ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: AppConstants.defaultFontFamily,
          color: Color(0xFF111111),
        );
    final TextStyle resolvedPhoneInputStyle = widget.phoneInputStyle ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: AppConstants.defaultFontFamily,
          color: Color(0xFF000000),
        );
    final TextStyle resolvedPhoneHintStyle = widget.phoneHintStyle ??
        const TextStyle(
          color: Color(0xB3707070),
          fontSize: 14,
          height: 1.43,
          fontFamily: AppConstants.defaultFontFamily,
          fontWeight: FontWeight.w500,
        );
    final TextStyle resolvedSubmitStyle = widget.submitTextStyle ??
        TextStyle(
          color: widget.submitButtonTextColor,
          fontSize: 12,
          fontFamily: AppConstants.defaultFontFamily,
          fontWeight: FontWeight.w600,
        );

    final Widget row = Row(
      children: [
        InkWell(
          onTap: widget.enableCountryPicker ? widget.onTapCountryPicker : null,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Container(
            height: widget.fieldHeight,
            width: widget.countryPickerWidth,
            padding: widget.countryPickerPadding,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              border: widget.showCountryPickerBorder
                  ? Border.all(
                      color: widget.countryPickerBorderColor,
                      width: widget.countryPickerBorderWidth,
                    )
                  : null,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCountryFlag(resolvedFlagStyle),
                  SizedBox(width: widget.countryFlagToDialGap),
                  Text(widget.dialCode, style: resolvedDialStyle),
                  if (widget.showCountryArrow) ...[
                    SizedBox(width: widget.countryDialToArrowGap),
                    Icon(
                      widget.countryArrowIcon,
                      size: widget.countryArrowIconSize,
                      color: widget.countryArrowColor,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: widget.countryToPhoneGap),
        Expanded(
          child: _FocusedInputBorderWrapper(
            isFocused: _hasPhoneFocus,
            unfocusedBorderColor: widget.unfocusedBorderColor,
            hideUnfocusedBorder: widget.hideUnfocusedInputBorder,
            focusedBorderGradient: widget.focusedBorderGradient,
            radius: widget.borderRadius,
            borderWidth: widget.borderWidth,
            child: Container(
              height: widget.fieldHeight,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              padding: widget.inputContainerPadding,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _effectiveFocusNode,
                      controller: widget.controller,
                      autofocus: widget.autofocus,
                      readOnly: widget.readOnly,
                      style: resolvedPhoneInputStyle,
                      keyboardType: widget.keyboardType,
                      inputFormatters: widget.inputFormatters,
                      onSubmitted: (value) {
                        widget.onSubmitted?.call(value);
                      },
                      decoration: InputDecoration(
                        fillColor: widget.backgroundColor,
                        filled: true,
                        border: InputBorder.none,
                        hintText: widget.hintText,
                        hintStyle: resolvedPhoneHintStyle,
                        isCollapsed: true,
                        contentPadding: widget.phoneInputPadding,
                      ),
                      onChanged: widget.onChanged,
                    ),
                  ),
                  SizedBox(width: widget.submitButtonGap),
                  SizedBox(
                    height: widget.submitButtonHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.submitButtonBackgroundColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            widget.submitButtonBorderRadius,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.submitButtonHorizontalPadding,
                        ),
                      ),
                      onPressed: _onSubmitTapped,
                      child: widget.submitLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(widget.submitText, style: resolvedSubmitStyle),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if ((widget.labelText ?? '').isEmpty) {
      return row;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.labelText!, style: resolvedLabelStyle),
        SizedBox(height: widget.labelToRowGap),
        row,
      ],
    );
  }
}

class _FocusedInputBorderWrapper extends StatelessWidget {
  const _FocusedInputBorderWrapper({
    required this.child,
    required this.isFocused,
    required this.unfocusedBorderColor,
    required this.hideUnfocusedBorder,
    required this.focusedBorderGradient,
    required this.radius,
    required this.borderWidth,
  });

  final Widget child;
  final bool isFocused;
  final Color unfocusedBorderColor;
  final bool hideUnfocusedBorder;
  final LinearGradient focusedBorderGradient;
  final double radius;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isFocused ? focusedBorderGradient : null,
        border: isFocused
            ? null
            : (hideUnfocusedBorder
                ? null
                : Border.all(
                    color: unfocusedBorderColor,
                    width: borderWidth,
                  )),
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: EdgeInsets.all(borderWidth),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular((radius - borderWidth).clamp(0.0, radius)),
        child: child,
      ),
    );
  }
}
