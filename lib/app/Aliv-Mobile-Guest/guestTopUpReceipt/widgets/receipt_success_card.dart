import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUpReceipt/theme/theme.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../core/utils/app_session.dart';
import '../bloc/guest_top_up_receipt_state.dart';
import 'receipt_detail_row.dart';
import 'receipt_ticket_divider.dart';
import 'receipt_back_button.dart';

class ReceiptSuccessCard extends StatelessWidget {
  const ReceiptSuccessCard({
    super.key,
    required this.data,
    required this.onBackHome,
    required this.pageBackground,
  });

  final GuestTopUpReceiptData data;
  final VoidCallback onBackHome;
  final Color pageBackground;

  String _money(double v) => '\$ ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    const double titleBoxH = 24; // Fixed height keeps notch alignment stable.

    return PhysicalShape(
      clipper: _TicketSideNotchClipper(
        cornerRadius: ReceiptTheme.successCardCornerRadius,
        notchRadius: ReceiptTheme.successCardNotchRadius,
        notchCenterY: ReceiptTheme.successCardNotchTopOffset,
      ),
      clipBehavior: Clip.antiAlias,
      elevation: ReceiptTheme.successCardElevation,
      shadowColor: ReceiptTheme.successCardShadowColor,
      color: ReceiptTheme.successCardBackgroundColor,
      child: Padding(
        padding: ReceiptTheme.successCardPadding,
        child: Column(
          children: [
            // success icon
            SizedBox(
              width: ReceiptTheme.successIconOuterSize,
              height: ReceiptTheme.successIconOuterSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ReceiptTheme.successIconOuter,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: ReceiptTheme.successIconInnerSize,
                    height: ReceiptTheme.successIconInnerSize,
                    decoration: BoxDecoration(
                      color: ReceiptTheme.successIconInner,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: ReceiptTheme.successIconCheckSize,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: ReceiptTheme.successGapAfterIcon),

            // fixed title height (so notch stays exactly aligned)
            SizedBox(
              width: ReceiptTheme.successCardContentWidth,
              height: titleBoxH,
              child: Center(
                child: (AppSession.appRoute == 'sendTopUp')
                    ? Text(
                        'Wallet Transfer Successful!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : Text(
                        'Payment Success!',
                        textAlign: TextAlign.center,
                        style: ReceiptTheme.successTitle,
                      ),
              ),
            ),

            const SizedBox(height: ReceiptTheme.successGapAfterTitle),

            // ✅ dashed divider (slightly inset like screenshot)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ReceiptTheme.successDashedDividerHorizontalInset,
              ),
              child: ReceiptTicketDivider(
                height: ReceiptTheme.successDashedDividerStrokeWidth,
              ),
            ),

            const SizedBox(height: ReceiptTheme.successGapAfterTitle),
            LayoutBuilder(
              builder: (context, constraints) {
                final helperTextWidth =
                    constraints.maxWidth < ReceiptTheme.successCardContentWidth
                    ? constraints.maxWidth
                    : ReceiptTheme.successCardContentWidth;

                return SizedBox(
                  width: helperTextWidth,
                  child: (AppSession.appRoute == 'sendTopUp')
                      ? Text(
                          'It may take a few moments before the order is processed.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF707070),
                            fontSize: 16,
                            fontFamily: 'CircularPro',
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Text(
                          'It will take a few moments for the top-up '
                          'to appear on the account.',
                          textAlign: TextAlign.center,
                          style: ReceiptTheme.successBody,
                        ),
                );
              },
            ),
            const SizedBox(height: ReceiptTheme.successGapAfterMessage),
            if (AppSession.appRoute == 'sendTopUp')
              ReceiptDetailRow(
                label: 'transferred number',
                value: data.phoneNumber,
                valueBold: false,
              ),
            if (AppSession.appRoute == 'sendTopUp')
              ReceiptDetailRow(
                label: 'subtotal',
                value: '\$ 15.00',
                valueBold: false,
              ),
            if (AppSession.appRoute == 'sendTopUp')
              ReceiptDetailRow(
                label: 'vat',
                value: '\$ 0.00',
                valueBold: false,
              ),

            // details
            if (AppSession.appRoute == '')
              ReceiptDetailRow(
                label: 'top-up',
                value: data.rightType,
                valueBold: false,
              ),
            if (AppSession.appRoute == '')
              ReceiptDetailRow(
                label: 'date',
                value: data.dateText,
                valueBold: false,
              ),
            if (AppSession.appRoute == '')
              ReceiptDetailRow(
                label: 'time',
                value: data.timeText,
                valueBold: false,
              ),
            if (AppSession.appRoute == '')
              ReceiptDetailRow(
                label: 'phone no.',
                value: data.phoneNumber,
                valueBold: false,
              ),

            if (AppSession.appRoute == '' )
              ReceiptDetailRow(
                label: 'payment method',
                value: data.paymentMethod,
                valueBold: false,
              ),

            const SizedBox(height: ReceiptTheme.successGapBeforeAmount),

            // second divider (NO notches needed; this is just dashed)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ReceiptTheme.successDashedDividerHorizontalInset,
              ),
              child: ReceiptTicketDivider(
                height: ReceiptTheme.successDashedDividerStrokeWidth,
              ),
            ),

            const SizedBox(height: ReceiptTheme.successGapBeforeAmount),

            if (AppSession.appRoute == 'sendTopUp')
              ReceiptDetailRow(
                label: 'will be transferred',
                value: _money(15.00),
                valueBold: true,
              ),

            if (AppSession.appRoute == '')
              ReceiptDetailRow(
                label: 'amount',
                value: _money(data.amount),
                valueBold: true,
              ),

            const SizedBox(height: ReceiptTheme.successGapAfterAmount),
            Divider(
              height: ReceiptTheme.successBottomDividerThickness,
              thickness: ReceiptTheme.successBottomDividerThickness,
              color: ReceiptTheme.successCardBottomDividerColor,
            ),
            const SizedBox(height: ReceiptTheme.successGapAfterBottomDivider),

            (AppSession.appRoute == 'sendTopUp' ||
                    AppSession.isTopUp == true ||
                    AppSession.appRoute == 'prepaidPlanPurchase')
                ? ReceiptBackButton(
                    onTap: () {
                      context.go(AppRoutes.home);
                      AppSession.resetAppRoute();
                      if (AppSession.isTopUp == true) {
                        AppSession.resetFlagForTopUp();
                      }
                    },
                    text: 'back to home page',
                  )
                : ReceiptBackButton(
                    onTap: onBackHome,
                    text: 'back to login page',
                  ),
            const SizedBox(height: ReceiptTheme.successGapAfterButton),
          ],
        ),
      ),
    );
  }
}

/// ✅ This actually CUTS the card sides (no overlay circles)
class _TicketSideNotchClipper extends CustomClipper<Path> {
  const _TicketSideNotchClipper({
    required this.cornerRadius,
    required this.notchRadius,
    required this.notchCenterY,
  });

  final double cornerRadius;
  final double notchRadius;
  final double notchCenterY;

  @override
  Path getClip(Size size) {
    final base = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(cornerRadius),
        ),
      );

    // notch circles centered on the side edges (x=0, x=width) so they cut inward
    final holes = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(0, notchCenterY), radius: notchRadius),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width, notchCenterY),
          radius: notchRadius,
        ),
      );

    return Path.combine(PathOperation.difference, base, holes);
  }

  @override
  bool shouldReclip(covariant _TicketSideNotchClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.notchRadius != notchRadius ||
        oldClipper.notchCenterY != notchCenterY;
  }
}
