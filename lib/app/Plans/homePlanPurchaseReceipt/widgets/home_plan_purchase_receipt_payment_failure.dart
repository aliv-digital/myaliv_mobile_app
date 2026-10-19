import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanPurchaseReceipt/theme/home_plan_purchase_receipt_theme.dart';

import 'home_plan_purchase_receipt_ticket_divider.dart';

/// Full-height ticket used by the payment-failure receipt screen.
class HomePlanPurchaseReceiptPaymentFailedTicket extends StatelessWidget {
  const HomePlanPurchaseReceiptPaymentFailedTicket({
    super.key,
    this.message = 'There was a problem processing\nyour order.',
    this.buttonText = 'back to login page',
    required this.onPressed,
  });

  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  static const double _cornerRadius = 14;
  static const double _notchRadius = 10;
  static const double _notchCenterY = 208;
  static const double _horizontalContentPadding = 18;

  static const String _iconBackgroundAsset =
      'assets/icons/payment_failure_icon_background.svg';
  static const String _iconAsset = 'assets/icons/payment_failure_icon.svg';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : 600.0;

        return SizedBox(
          width: double.infinity,
          height: height,
          child: CustomPaint(
            foregroundPainter: const _TicketBorderPainter(
              borderColor: Color(0xFFFDA29B),
              cornerRadius: _cornerRadius,
              notchRadius: _notchRadius,
              notchCenterY: _notchCenterY,
            ),
            child: ClipPath(
              clipper: const _TicketSideNotchClipper(
                cornerRadius: _cornerRadius,
                notchRadius: _notchRadius,
                notchCenterY: _notchCenterY,
              ),
              child: ColoredBox(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _horizontalContentPadding,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              _iconBackgroundAsset,
                              width: 56,
                              height: 56,
                            ),
                            SvgPicture.asset(_iconAsset, width: 32, height: 32),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(
                        height: 24,
                        child: Center(
                          child: Text(
                            'Payment Failed',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFCC3F3F),
                              fontSize: 18,
                              fontFamily: 'CircularPro',
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 48,
                        child: Center(
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF121212),
                              fontSize: 16,
                              fontFamily: 'CircularPro',
                              fontWeight: FontWeight.w400,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: HomePlanPurchaseReceiptTicketDivider(
                          height: 22,
                          dashColor: HomePlanPurchaseReceiptTheme.redDashColor,
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: 176,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: onPressed,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFF2F1F9)),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            buttonText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF645D9C),
                              fontSize: 15,
                              fontFamily: 'CircularPro',
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

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
    final ticket = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(cornerRadius),
        ),
      );
    final notches = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(0, notchCenterY), radius: notchRadius),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width, notchCenterY),
          radius: notchRadius,
        ),
      );

    return Path.combine(PathOperation.difference, ticket, notches);
  }

  @override
  bool shouldReclip(covariant _TicketSideNotchClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.notchRadius != notchRadius ||
        oldClipper.notchCenterY != notchCenterY;
  }
}

class _TicketBorderPainter extends CustomPainter {
  const _TicketBorderPainter({
    required this.borderColor,
    required this.cornerRadius,
    required this.notchRadius,
    required this.notchCenterY,
  });

  final Color borderColor;
  final double cornerRadius;
  final double notchRadius;
  final double notchCenterY;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _TicketSideNotchClipper(
      cornerRadius: cornerRadius,
      notchRadius: notchRadius,
      notchCenterY: notchCenterY,
    ).getClip(size);
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TicketBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.notchRadius != notchRadius ||
        oldDelegate.notchCenterY != notchCenterY;
  }
}
