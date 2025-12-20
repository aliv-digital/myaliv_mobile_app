import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUpReceipt/theme/theme.dart';
import '../bloc/guest_top_up_receipt_state.dart';
import 'receipt_ticket_divider.dart';
import 'receipt_back_button.dart';

class ReceiptFailureCard extends StatelessWidget {
  const ReceiptFailureCard({
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
    // Constants for card layout
    const double cardPad = 18;
    const double cornerRadius = 16;
    const double iconSize = 54;
    const double gapAfterIcon = 14;
    const double titleBoxH = 24;
    const double gapAfterTitle = 16;
    const double dividerH = 22;
    const double notchRadius = 10;

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
            const SizedBox(height: 25),
            // Failure icon (red background with exclamation mark)
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ReceiptTheme.circleBackground, // light red circle
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      //color: Color(0xFFFB2F2F), // red icon background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: gapAfterIcon),

            // Title: Payment Failed
            const SizedBox(
              height: titleBoxH,
              child: Center(
                child: Text(
                  'Payment Failed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFB2F2F), // red color for text
                  ),
                ),
              ),
            ),

            const SizedBox(height: gapAfterTitle),

            // Dashed line divider (no notch for the bottom line)
           // const Padding(
           //   padding: EdgeInsets.symmetric(horizontal: 6),
           //   child: ReceiptTicketDivider(height: dividerH),
           // ),

            const SizedBox(height: 10),
            const Text(
              'There was a problem processing \nyour order.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'CircularPro',
                height: 1.25,
                color: Color(0xFF7A7A7A),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 40),

            // Customer service contact info
            const Text(
              'Please contact customer service at',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 16,
                height: 1.25,
                color: Color(0xFF7A7A7A),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              data.phoneNumber,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 16,
                height: 1.25,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            // Details section (same as success card)
            //ReceiptDetailRow(label: 'top up', value: data.rightType, valueBold: true),
            //ReceiptDetailRow(label: 'date', value: data.dateText, valueBold: true),
            //ReceiptDetailRow(label: 'time', value: data.timeText, valueBold: true),
            //ReceiptDetailRow(label: 'phone no.', value: data.phoneNumber, valueBold: true),
            //ReceiptDetailRow(label: 'payment method', value: data.paymentMethod, valueBold: true),

            const SizedBox(height: 32),

            // Dashed line (no notches) at the bottom
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: ReceiptTicketDivider(
                height: dividerH,
                dashColor: ReceiptTheme.redDashColor,
              ),
            ),

           // const SizedBox(height: 6),



            //const SizedBox(height: 10),

            const SizedBox(height: 32),

            // Back button to home
            ReceiptBackButton(onTap: onBackHome),
            const SizedBox(height: 250)
          ],
        ),
      ),
    );
  }
}

/// Custom clipper for notch on both left and right sides of the card
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



