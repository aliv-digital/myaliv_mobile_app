import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/widgets/terms_and_conditions_modal.dart';

Future<void> showFairUsePolicyModal(
  BuildContext context, {
  double badgeSize = 48,
  double badgeInnerSize = 34,
  double? badgeCoreSize = 24,
  double badgeIconWidth = 16,
  double badgeIconHeight = 16,
  double closeButtonSize = 24,
}) {
  if (instance.isRegistered<AnalyticsService>()) {
    instance<AnalyticsService>().logScreenView(screenName: 'Fair Use Policy');
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: FairUsePolicyDialog(
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

class FairUsePolicyDialog extends StatelessWidget {
  const FairUsePolicyDialog({
    super.key,
    this.badgeSize = 48,
    this.badgeInnerSize = 34,
    this.badgeCoreSize = 24,
    this.badgeIconWidth = 16,
    this.badgeIconHeight = 16,
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

  static const TextStyle _headingStyle = TextStyle(
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

  static const String _intro1 =
      'This Fair Use Policy (“Policy”) relates to Your use of our Mobile Services. '
      'It is designed to make sure We can give You Services that are great value, '
      'fast and reliable. This Policy applies, but is not limited, to all Services '
      'offered by Us. This also includes such other Services that We might add in the future.';

  static const String _intro2 =
      'By using Our services, You agree to comply with this Policy and remain '
      'responsible to comply with it. You must make sure that any use of the '
      'Services, by Yourself or anyone else via Your account, complies with this '
      'Policy. You are responsible for all use of the Services through Your '
      'account and for any breach of this Policy whether an unacceptable use '
      'occurs or is attempted, whether You knew or should have known about it, '
      'whether or not You carried out or attempted the unacceptable use alone, '
      'contributed to or acted with others or allowed any unacceptable use to '
      'occur by omission. You agree that We are not responsible for any of '
      'Your activities in using Our network and/or Services.';

  static const String _excessiveUsage =
      'Our services are for normal person to person use from your phone and are '
      'subject to your acceptance of standard terms and conditions for monthly '
      'services. We monitor use in accordance with those terms and conditions. '
      'For MiFi plans, if you exceed 50% of your unlimited data allocation '
      'within a 30-day period, we reserve the right to throttle or reduce your '
      'available data speed. For regular unlimited plans, if you exceed 50GB in '
      'any given month on a 30-day plan or 30GB in any given week on a 7-day '
      'plan, we reserve the right to throttle or reduce your available data '
      'speed and may also suspend your services. If we discover that you talk '
      'for more than 7,500 minutes (including Aliv to Aliv calls) or send more '
      'than 4,500 text messages (including Aliv to Aliv texts) per month, we '
      'also reserve the right to restrict your access to calls and may suspend '
      'your services. Our Fair Use Policy also restricts calls and texts to no '
      'more than two hundred (200) different numbers in one month. Further, '
      'calls are restricted to a maximum of two (2) hours per call. Once a call '
      'has reached two (2) hours, it will be automatically disconnected. '
      'However, you will be able to dial the same number straight away.';

  static const String _termsAndTermination1 =
      'Your “Term” is the period for which You have agreed to maintain Service '
      'with us. After Your Term, You will become a month-to-month customer.';

  static const String _termsAndTermination2 =
      'The Early Termination Fee is part of our rates and is not a penalty. If '
      'You terminate Your Service, Your termination will be effective at the '
      'end of Your current billing cycle, and You will remain responsible for all '
      'fees and Charges for Your Service and usage through the end of that '
      'billing cycle. You will also be obligated to pay early termination '
      'charges equal to the value of Your monthly service Charges for the '
      'remaining months of this Agreement. If we terminate Your Service, we will '
      'determine the date of termination, and You will be responsible for all '
      'usage and Charges through the date of termination. If You port Your '
      'number, You may be responsible for all usage and Charges through the end '
      'of Your current billing cycle. You may upgrade or downgrade Your plan on '
      'request to us and the signing of a new contract. Payment of a fee is '
      'required for a plan downgrade. No charges are required for plan upgrades.';

  static const String _deposit =
      'An upfront deposit will be required to sign up. The deposit required is '
      '\$149.99. All deposits are retained by Aliv. However, should You terminate '
      'Your contract early, Your deposit will be applied to Your Early '
      'Termination Fee. Should You not renew Your Consumer Postpaid plan, Your '
      'deposit will be applied to cover the last month(s) of Your contract. At '
      'Aliv’s sole discretion, the payment of the deposit may be waived at sign '
      'up and/or deferred for payment at a later date.';

  static const String _policyChanges =
      'We may change or modify this Policy at any time. The changes to this '
      'Policy will be posted on Our Website at www.bealiv.com. Please check Our '
      'Website periodically for any revisions to this Policy. If We make any '
      'material changes to this Policy, We will give You thirty (30) days’ '
      'notice. You acknowledge and agree that Your access to Our Website and Your '
      'use of Our services following any posted changes to the Policy indicate '
      'Your acceptance of such changes.';

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
                    const Text('Fair Use Policy', style: _titleStyle),
                    const SizedBox(height: 20),
                    const Text(_intro1, style: _bodyStyle),
                    const SizedBox(height: 16),
                    const Text(_intro2, style: _bodyStyle),
                    const SizedBox(height: 20),
                    const Text('Excessive Network Usage', style: _headingStyle),
                    const SizedBox(height: 16),
                    const Text(_excessiveUsage, style: _bodyStyle),
                    const SizedBox(height: 20),
                    const Text(
                      'Your Term of Service and Termination Fees',
                      style: _headingStyle,
                    ),
                    const SizedBox(height: 16),
                    const Text(_termsAndTermination1, style: _bodyStyle),
                    const SizedBox(height: 12),
                    const Text(_termsAndTermination2, style: _bodyStyle),
                    const SizedBox(height: 20),
                    const Text('Postpaid Deposit', style: _headingStyle),
                    const SizedBox(height: 16),
                    const Text(_deposit, style: _bodyStyle),
                    const SizedBox(height: 20),
                    const Text('Policy Changes', style: _headingStyle),
                    const SizedBox(height: 16),
                    const Text(_policyChanges, style: _bodyStyle),
                  ],
                ),
              ),
              Positioned(
                top: 26 + (badgeSize - closeButtonSize) / 2,
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
