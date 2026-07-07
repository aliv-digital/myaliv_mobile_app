import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

/// Purple "save credit card" primary action. Reused by every receipt that
/// surfaces the post-payment save-card affordance so the visual stays in
/// sync as designs evolve.
class SaveCreditCardButton extends StatelessWidget {
  const SaveCreditCardButton({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  final VoidCallback onTap;
  final bool isLoading;

  static const Color _buttonColor = Color(0xFF645D9C);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _buttonColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    AssetConstant.addCardIconSVG,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'save credit card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'CircularPro',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
