import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/bloc/guest_purchase_plan_receipt_state.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

import '../../app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bill-receipts/widgets/receipt_detail_row.dart';
import '../../app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bill-receipts/widgets/receipt_ticket_divider.dart';

class DefaultReceiptSuccessCard extends StatelessWidget {
  const DefaultReceiptSuccessCard({
    super.key,
    required this.data,
    required this.onBackHome,
    required this.pageBackground,
    this.statusMessage =
        'It will take a few moments for the plan to appears on the account.',
  });

  final GuestPurchasePlanReceiptData data;
  final VoidCallback onBackHome;
  final Color pageBackground;
  final String statusMessage;

  String _money(double v) => '\$ ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    // keep these constants stable for pixel-perfect notch position
    const double cardPad = 18;
    const double cornerRadius = 12;

    const double iconSize = 56;
    const double gapAfterIcon = 14;
    const double titleBoxH = 24; // fixed height to lock notch Y
    const double gapAfterTitle = 16;
    const double dividerH = 22;

    const double notchRadius = 10;

    // Notch should align with the FIRST divider center (after Payment Success!)
    final double notchCenterY = cardPad + iconSize + gapAfterIcon + titleBoxH + gapAfterTitle + (dividerH / 2);

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
        padding: const EdgeInsets.fromLTRB(cardPad, cardPad, cardPad, cardPad),
        child: Column(
          children: [
            // success icon
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xFFE4F3ED),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF23A26D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: gapAfterIcon),

            // fixed title height (so notch stays exactly aligned)
            const SizedBox(
              height: titleBoxH,
              child: Center(
                child: Text(
                  'Payment Success!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppConstants.defaultFontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: gapAfterTitle),

            // dashed divider (slightly inset like screenshot)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: ReceiptTicketDivider(height: dividerH),
            ),

            const SizedBox(height: 10),

            Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: AppConstants.defaultFontFamily,
                color: const Color(0xFF707070),
                fontWeight: FontWeight.w400,
              ),
            ),

            // Figma: 16px visual gap before first detail row.
            // ReceiptDetailRow has 7px top padding, so this is set to 9.
            const SizedBox(height: 9),

            //  Dynamic details
            // - data.details controls how many rows are shown
            // - label/value/valueBold all driven by incoming data
            for (final item in data.details)
              ReceiptDetailRow(
                label: item.label,
                value: item.value,
                valueBold: item.valueBold,
              ),

            const SizedBox(height: 6),

            // second divider (NO notches needed; this is just dashed)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: ReceiptTicketDivider(height: dividerH),
            ),

            const SizedBox(height: 6),

            // amount row (kept separate, bold value)
            ReceiptDetailRow(
              label: 'amount',
              value: _money(data.amount),
              valueBold: true,
            ),

            const SizedBox(height: 32),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE9E9EE)),
            const SizedBox(height: 32),

            _BackToLoginButton(onTap: onBackHome),
            const SizedBox(height: 52),
          ],
        ),
      ),
    );
  }
}

class _BackToLoginButton extends StatelessWidget {
  const _BackToLoginButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      height: 40,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFF1F1F8),
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'back to login page',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    color: Color(0xFF645D9C),
                    fontSize: 13,
                    fontFamily: AppConstants.defaultFontFamily,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// This actually CUTS the card sides (no overlay circles)
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
