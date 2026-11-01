import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

/// Payment artwork in the bordered slot used by payment-method selectors.
class PaymentMethodIcon extends StatelessWidget {
  const PaymentMethodIcon.savedCard({super.key})
    : _asset = AssetConstant.savedCreditCardsPNG,
      _isWallet = false;

  const PaymentMethodIcon.addCard({super.key})
    : _asset = AssetConstant.plusAddPNG,
      _isWallet = false;

  const PaymentMethodIcon.wallet({super.key})
    : _asset = AssetConstant.walletIconSVGPayment,
      _isWallet = true;

  static const double width = 46;
  static const double height = 32;
  static const double artworkSize = 20;
  static const double textGap = 12;
  static const Color _borderColor = Color(0xFFF2F3F6);
  static const double _cornerRadius = 6;

  final String _asset;
  final bool _isWallet;

  @override
  Widget build(BuildContext context) {
    // The ALIV asset already includes its rounded badge and border.
    if (_isWallet) {
      return SvgPicture.asset(_asset, width: width, height: height);
    }

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(_cornerRadius),
      ),
      child: Image.asset(
        _asset,
        width: artworkSize,
        height: artworkSize,
        fit: BoxFit.contain,
      ),
    );
  }
}
