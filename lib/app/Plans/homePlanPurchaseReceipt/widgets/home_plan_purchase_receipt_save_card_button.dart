import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

/// Primary action button that opens the "save credit card" bottom sheet.
class HomePlanPurchaseReceiptSaveCardButton extends StatelessWidget {
  const HomePlanPurchaseReceiptSaveCardButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  static const Color _buttonColor = Color(0xFF645D9C);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _buttonColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              AssetConstant.addCardIconSVG,
              width: 16,
              height: 16,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
