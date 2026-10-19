import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/theme/guest_splash_theme.dart';

class GuestSplashButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double width;

  const GuestSplashButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          elevation: WidgetStateProperty.all(0),
        ),
        child: Text(label, style: GuestSplashTheme.optionButtonText),
      ),
    );
  }
}
