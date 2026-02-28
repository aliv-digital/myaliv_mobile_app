import 'package:flutter/material.dart';
import '../../resources/color_manager.dart';

class DefaultButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  /// Overrides button height. Default: 52.
  final double height;

  /// Overrides button background color.
  final Color? backgroundColor;

  /// Overrides button text color.
  final Color? textColor;

  /// Optional border for outlined or bordered button variants.
  final BorderSide? borderSide;

  /// Optional elevation override (defaults to 0).
  final double elevation;

  /// Optional custom padding for the button child.
  final EdgeInsetsGeometry? contentPadding;

  final TextStyle? textStyle;
  final FontWeight fontWeight;
  final double fontSize;

  /// Overrides border radius. Default: pill shape.
  final BorderRadiusGeometry borderRadius;

  const DefaultButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.height = 52,
    this.fontSize = 17,
    this.fontWeight = FontWeight.w700,
    this.backgroundColor,
    this.textColor,
    this.borderSide,
    this.elevation = 0,
    this.contentPadding,
    this.textStyle,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? ColorManager.defaultButtonColor;
    final Color resolvedTextColor =
        textColor ?? textStyle?.color ?? Colors.white;
    final TextStyle resolvedTextStyle = (textStyle ??
            TextStyle(
              fontSize: fontSize,
              fontFamily: 'CircularPro',
              fontWeight: fontWeight,

              height: 1.80,
            ))
        .copyWith(color: resolvedTextColor);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return bgColor.withValues(alpha: 0.7);
            }
            return bgColor;
          }),
          elevation: WidgetStateProperty.all(elevation),
          side: WidgetStateProperty.all(borderSide),
          padding: contentPadding == null
              ? null
              : WidgetStateProperty.all(contentPadding),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: borderRadius),
          ),
        ),
        // Disable button while loading or when callback is null.
        onPressed: (isLoading || onPressed == null) ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: resolvedTextStyle,
              ),
      ),
    );
  }
}
