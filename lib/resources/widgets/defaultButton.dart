import 'package:flutter/material.dart';
import '../../resources/color_manager.dart'; // তোমার ColorManager এর path

class DefaultButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  /// height change করতে চাইলে override করতে পারবে (default: 52)
  final double height;

  /// background color override করার দরকার হলে
  final Color? backgroundColor;

  /// text color override করার দরকার হলে
  final Color? textColor;

  /// border radius override করতে চাইলে
  final BorderRadiusGeometry borderRadius;

  const DefaultButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.height = 52,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? ColorManager.defaultButtonColor;
    final Color fgColor = textColor ?? Colors.white;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
          elevation: 0,
        ),
        // loading হলে আর onPressed null হলে বাটন disable
        onPressed: (isLoading || onPressed == null) ? null : onPressed,
        child: isLoading ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ) : Text(
          label, style: TextStyle(
            fontSize: 17,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
            color: fgColor,
            height: 1.80
          ),
        ),
      ),
    );
  }
}
