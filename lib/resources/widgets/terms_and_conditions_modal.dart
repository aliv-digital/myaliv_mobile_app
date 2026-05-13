import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

Future<void> showTermsAndConditionsModal(
  BuildContext context, {
  double badgeSize = 32,
  double badgeInnerSize = 24,
  double? badgeCoreSize,
  double badgeIconWidth = 18,
  double badgeIconHeight = 18.75,
  double closeButtonSize = 24,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: TermsAndConditionsDialog(
          badgeSize: badgeSize,
          badgeInnerSize: badgeInnerSize,
          badgeCoreSize: badgeCoreSize,
          badgeIconWidth: badgeIconWidth,
          badgeIconHeight: badgeIconHeight,
          closeButtonSize: closeButtonSize,
        ),
      );
    },
  );
}

class TermsAndConditionsDialog extends StatelessWidget {
  const TermsAndConditionsDialog({
    super.key,
    this.badgeSize = 32,
    this.badgeInnerSize = 24,
    this.badgeCoreSize,
    this.badgeIconWidth = 18,
    this.badgeIconHeight = 18.75,
    this.closeButtonSize = 24,
  });

  final double badgeSize;
  final double badgeInnerSize;
  final double? badgeCoreSize;
  final double badgeIconWidth;
  final double badgeIconHeight;
  final double closeButtonSize;

  static const TextStyle _titleStyle = TextStyle(
    color: Color(0xFF222222),
    fontSize: 18,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
    height: 28 / 18,
  );

  static const TextStyle _bodyStyle = TextStyle(
    color: Color(0xFF707070),
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w500,
    height: 20 / 14,
  );

  static const String _introText =
      'Welcome to the bealiv.com website, which is operated by Cable Bahamas '
      'Group Ltd (“CBL”, “Bealiv”, “ALIV” “MyAliv App,” “we,” “us” or “our”). '
      'Please read these Terms of Use carefully, as they describe the terms '
      'and conditions applicable to bealiv.com in addition to any related '
      'websites, domains, portals, mobile applications, or online services '
      'which may be offered by our affiliate companies, including, but not '
      'limited to, https://portal.newcomobile.com/myaliv/login.aspx, '
      '(collectively, the “Site”). By accessing and using this site, you agree '
      'to comply with and be bound by the following terms of use. Please review '
      'the following terms carefully. If you do not agree to these terms, you '
      'should not use this site.';

  static const String _useOfSiteText =
      'ALIV grants you a limited license to access and make personal use of '
      'this site. You are not permitted to download (other than page caching) '
      'or modify the site, or any portion of it, except with express written '
      'consent of ALIV. This license does not include any resale or commercial '
      'use of this site or its contents; any collection and use of any product '
      'listings, descriptions, or prices; any derivative use of this site or '
      'its contents; any downloading or copying of account information for the '
      'benefit of another merchant; or any use of data mining, robots, or '
      'similar data gathering and extraction tools.';

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight - 48),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Material(
          color: Colors.white,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TermsShieldBadge(
                      size: badgeSize,
                      innerSize: badgeInnerSize,
                      coreSize: badgeCoreSize,
                      iconWidth: badgeIconWidth,
                      iconHeight: badgeIconHeight,
                    ),
                    const SizedBox(height: 20),
                    const Text('Terms & Conditions', style: _titleStyle),
                    const SizedBox(height: 20),
                    const Text(_introText, style: _bodyStyle),
                    const SizedBox(height: 20),
                    const Text('Use of Site', style: _titleStyle),
                    const SizedBox(height: 20),
                    const Text(_useOfSiteText, style: _bodyStyle),
                  ],
                ),
              ),
              Positioned(
                top: 29,
                right: 26,
                child: TermsDialogCloseButton(
                  size: closeButtonSize,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TermsShieldBadge extends StatelessWidget {
  const TermsShieldBadge({
    super.key,
    this.size = 32,
    this.innerSize = 24,
    this.coreSize,
    this.iconWidth = 18,
    this.iconHeight = 18.75,
  });

  final double size;
  final double innerSize;
  final double? coreSize;
  final double iconWidth;
  final double iconHeight;

  @override
  Widget build(BuildContext context) {
    final resolvedCoreSize = coreSize;

    Widget child = Container(
      width: innerSize,
      height: innerSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: HexColor.fromHex('#EDEBF7'),
      ),
      child: SvgPicture.asset(
        AssetConstant.roundedTikSVG,
        width: iconWidth,
        height: iconHeight,
      ),
    );

    if (resolvedCoreSize != null) {
      child = Container(
        width: innerSize,
        height: innerSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: HexColor.fromHex('#F9F5FF'),
        ),
        child: Container(
          width: resolvedCoreSize,
          height: resolvedCoreSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: HexColor.fromHex('#F9F5FF'),
          ),
          child: SvgPicture.asset(
            AssetConstant.roundedTikSVG,
            width: iconWidth,
            height: iconHeight,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: HexColor.fromHex('#F9F5FF')
        // color: resolvedCoreSize == null
        //     ? const Color(0xFFEDE8FA)
        //     : const Color(0xFFF7F3FF),
      ),
      child: child,
    );
  }
}

class TermsDialogCloseButton extends StatelessWidget {
  const TermsDialogCloseButton({
    super.key,
    required this.onTap,
    this.size = 24,
  });

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SvgPicture.asset(
        AssetConstant.blackRoundedCrossSVG,
        width: 22,
        height: 22,
      ),
    );
  }
}
