import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bill-receipts/theme/theme.dart';
import '../bloc/guest_pay_bill_receipt_state.dart';
import 'receipt_detail_row.dart';
import 'receipt_ticket_divider.dart';
import 'receipt_back_button.dart';

class ReceiptSuccessCard extends StatelessWidget {
  const ReceiptSuccessCard({
    super.key,
    required this.data,
    required this.onBackHome,
  });

  final GuestPayBillReceiptData data;
  final VoidCallback onBackHome;

  String _money(double v) => '\$ ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    // Figma-aligned paddings
    const double horizontalPad = 24;
    const double topPad = 32;
    const double bottomPad = 32;
    const double cornerRadius = 16;

    const double iconSize = 54;
    const double gapAfterIcon = 20;
    const double titleBoxH = 24; // fixed height to lock notch Y
    const double gapAfterTitle = 32;
    const double gapAfterFirstDivider = 32;
    const double gapAfterMessage = 24;
    const double dividerH = 22;

    const double notchRadius = 10;

    // Notch should align with the FIRST divider center (after Payment Success!)
    final double notchCenterY = topPad +
        iconSize +
        gapAfterIcon +
        titleBoxH +
        gapAfterTitle +
        (dividerH / 2);

    return PhysicalShape(
      clipper: _TicketSideNotchClipper(
        cornerRadius: cornerRadius,
        notchRadius: notchRadius,
        notchCenterY: notchCenterY,
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 10,
      shadowColor: const Color(0x22000000),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          horizontalPad,
          topPad,
          horizontalPad,
          bottomPad,
        ),
        child: Column(
          children: [
            // success icon
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: GuestPayBillReceiptTheme.successIconOuter,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: GuestPayBillReceiptTheme.successIconInner,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: gapAfterIcon),

            // fixed title height (so notch stays exactly aligned)
            SizedBox(
              height: titleBoxH,
              child: Center(
                child: Text(
                  'Payment Success!',
                  style: GuestPayBillReceiptTheme.successTitle,
                ),
              ),
            ),

            const SizedBox(height: gapAfterTitle),

            // ✅ dashed divider (slightly inset like screenshot)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: ReceiptTicketDivider(height: dividerH),
            ),

            const SizedBox(height: gapAfterFirstDivider),
            Text(
              'It will take a few moments for the top-up\nto appear on the account.',
              textAlign: TextAlign.center,
              style: GuestPayBillReceiptTheme.successBody,
            ),
            const SizedBox(height: gapAfterMessage),

            // details
            ReceiptDetailRow(
                label: data.leftType, value: data.rightType, valueBold: false),
            ReceiptDetailRow(
                label: 'date', value: data.dateText, valueBold: false),
            ReceiptDetailRow(
                label: 'time', value: data.timeText, valueBold: false),
            ReceiptDetailRow(
              label: data.identifierLabel,
              value: data.phoneNumber,
              valueBold: false,
            ),
            ReceiptDetailRow(
                label: 'payment method',
                value: data.paymentMethod,
                valueBold: false),

            const SizedBox(height: 6),

            // second divider (NO notches needed; this is just dashed)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: ReceiptTicketDivider(height: dividerH),
            ),

            const SizedBox(height: 8),

            ReceiptDetailRow(
              label: 'amount',
              value: _money(data.amount),
              valueBold: true,
            ),

            const SizedBox(height: 32),
            ReceiptBackButton(onTap: onBackHome),
          ],
        ),
      ),
    );
  }
}

///  This actually CUTS the card sides (no overlay circles)
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
