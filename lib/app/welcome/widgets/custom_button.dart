import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white), // Light purple color
          padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 10, horizontal: 24)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          elevation: WidgetStateProperty.all(0),  // No shadow
        ),
        child: Text(
          label,
          style: TextStyle(
            color: ColorManager.welcomeScreenBloc,  // Text color
            fontSize: 13,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,  // Font weight
          ),
        ),
      ),
    );
  }
}
