import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUpReceipt/theme/theme.dart';
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
                child: Text(
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
                  child: Text(
                    'It will take a few moments for the top-up '
                    'to appear on the account.',
                    textAlign: TextAlign.center,
                    style: ReceiptTheme.successBody,
                  ),
                );
              },
            ),
            const SizedBox(height: ReceiptTheme.successGapAfterMessage),

            // details
            ReceiptDetailRow(
                label: 'top up', value: data.rightType, valueBold: false),
            ReceiptDetailRow(
                label: 'date', value: data.dateText, valueBold: false),
            ReceiptDetailRow(
                label: 'time', value: data.timeText, valueBold: false),
            ReceiptDetailRow(
                label: 'phone no.', value: data.phoneNumber, valueBold: false),
            ReceiptDetailRow(
                label: 'payment method',
                value: data.paymentMethod,
                valueBold: false),

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

            ReceiptBackButton(onTap: onBackHome, text: 'back to login page'),
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
        Rect.fromCircle(
          center: Offset(0, notchCenterY),
          radius: notchRadius,
        ),
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
