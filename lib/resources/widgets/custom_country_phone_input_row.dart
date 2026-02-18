import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

/// CustomCountryPhoneInputRow
/// --------------------------
/// Reusable country picker + phone input row with the same behavior/pattern
/// used in guest top-up (`guestTopUp/widgets/phone_number_input.dart`).
///
/// Usage 1: Standard row (country picker enabled)
/// ```dart
/// CustomCountryPhoneInputRow(
///   labelText: 'enter mobile number',
///   hintText: 'eg: 242-899-9999',
///   flagEmoji: country.flagEmoji,
///   dialCode: country.phoneCode,
///   countryIsoCode: country.countryCode, // Enables flat flag asset rendering.
///   onTapCountryPicker: _pickCountry,
///   onChanged: (value) => bloc.add(PhoneChanged(value)),
/// )
/// ```
///
/// Usage 2: Confirm row (fixed country, no arrow)
/// ```dart
/// CustomCountryPhoneInputRow(
///   labelText: 'confirm mobile number',
///   hintText: 'eg: 242-899-9999',
///   flagEmoji: selectedCountry.flagEmoji,
///   dialCode: selectedCountry.phoneCode,
///   countryIsoCode: selectedCountry.countryCode,
///   onChanged: (value) => bloc.add(ConfirmPhoneChanged(value)),
///   enableCountryPicker: false,
///   showCountryArrow: false,
/// )
/// ```
class CustomCountryPhoneInputRow extends StatefulWidget {
  const CustomCountryPhoneInputRow({
    super.key,
    required this.hintText,
    required this.flagEmoji,
    required this.dialCode,
    required this.onChanged,
    this.countryIsoCode,
    this.countryFlagBorderRadius = 4,
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
    this.unfocusedBorderColor = Colors.transparent,
    this.hideUnfocusedInputBorder = false,
    this.focusedBorderGradient = _defaultFocusedBorderGradient,
    this.borderRadius = 8,
    this.borderWidth = 1,
    this.fieldHeight = 48,
    this.countryPickerWidth = 76,
    this.countryToPhoneGap = 10,
    this.countryPickerPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.showCountryPickerBorder = false,
    this.countryPickerBorderColor = Colors.transparent,
    this.countryPickerBorderWidth = 1,
    this.phoneInputPadding = const EdgeInsets.symmetric(horizontal: 14),
    this.countryFlagToDialGap = 4,
    this.countryDialToArrowGap = 2,
    this.countryArrowIconSize = 16,
    this.countryArrowWidth,
    this.countryArrowHeight,
    this.countryArrowColor = const Color(0xFFB0B0B5),
    this.countryArrowIcon = Icons.keyboard_arrow_down_rounded,
    this.labelToRowGap = 8,
    this.labelStyle,
    this.flagStyle,
    this.dialCodeStyle,
    this.phoneInputStyle,
    this.phoneHintStyle,
  });

  // Optional label above the row (same structure as guest top-up).
  final String? labelText;

  // Text field behavior.
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool readOnly;
  final ValueChanged<String>? onSubmitted;

  // Country picker behavior.
  final String flagEmoji;
  final String dialCode;
  // Optional ISO2 code (e.g., "BS") to render flat flag from country_pickers assets.
  final String? countryIsoCode;
  final double countryFlagBorderRadius;
  final VoidCallback? onTapCountryPicker;
  final bool enableCountryPicker;
  final bool showCountryArrow;

  // Container/border visuals.
  final Color backgroundColor;
  final Color unfocusedBorderColor;
  // If true, the phone input border is hidden in neutral/unfocused state.
  final bool hideUnfocusedInputBorder;
  final LinearGradient focusedBorderGradient;
  final double borderRadius;
  final double borderWidth;

  // Dimensions and spacing.
  final double fieldHeight;
  final double countryPickerWidth;
  final double countryToPhoneGap;
  final EdgeInsets countryPickerPadding;
  final bool showCountryPickerBorder;
  final Color countryPickerBorderColor;
  final double countryPickerBorderWidth;
  final EdgeInsets phoneInputPadding;
  final double countryFlagToDialGap;
  final double countryDialToArrowGap;
  final double countryArrowIconSize;
  // Optional explicit arrow bounds for pixel-perfect UI (e.g. 9x6).
  final double? countryArrowWidth;
  final double? countryArrowHeight;
  final Color countryArrowColor;
  final IconData countryArrowIcon;
  final double labelToRowGap;

  // Typography overrides.
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
  State<CustomCountryPhoneInputRow> createState() =>
      _CustomCountryPhoneInputRowState();
}

class _CustomCountryPhoneInputRowState
    extends State<CustomCountryPhoneInputRow> {
  late FocusNode _effectiveFocusNode;
  late bool _ownsFocusNode;
  bool _hasPhoneFocus = false;

  @override
  void initState() {
    super.initState();
    _bindFocusNode(widget.focusNode);
  }

  @override
  void didUpdateWidget(covariant CustomCountryPhoneInputRow oldWidget) {
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
      // country_pickers does not include AC.png; use SH asset (same flag style).
      final String assetIsoCode =
          isoCode.toUpperCase() == 'AC' ? 'SH' : isoCode.toUpperCase();

      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.countryFlagBorderRadius),
        child: Image.asset(
          'assets/${assetIsoCode.toLowerCase()}.png',
          package: 'country_pickers',
          width: 26,
          height: 20,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Text(widget.flagEmoji, style: resolvedFlagStyle);
          },
        ),
      );
    }

    return Text(widget.flagEmoji, style: resolvedFlagStyle);
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
                    if (widget.countryArrowWidth != null &&
                        widget.countryArrowHeight != null)
                      SizedBox(
                        width: widget.countryArrowWidth,
                        height: widget.countryArrowHeight,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Icon(
                            widget.countryArrowIcon,
                            size: widget.countryArrowIconSize,
                            color: widget.countryArrowColor,
                          ),
                        ),
                      )
                    else
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
              padding: widget.phoneInputPadding,
              alignment: Alignment.center,
              child: TextField(
                focusNode: _effectiveFocusNode,
                controller: widget.controller,
                autofocus: widget.autofocus,
                readOnly: widget.readOnly,
                style: resolvedPhoneInputStyle,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                onSubmitted: widget.onSubmitted,
                decoration: InputDecoration(
                  fillColor: widget.backgroundColor,
                  filled: true,
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: resolvedPhoneHintStyle,
                  isCollapsed: true,
                ),
                onChanged: widget.onChanged,
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
