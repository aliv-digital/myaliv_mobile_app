
import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUpReceipt/theme/theme.dart';

class PaymentFailedTicket extends StatelessWidget {
  const PaymentFailedTicket({
    super.key,
    this.title = 'Payment Failed',
    this.message = 'There was a problem processing your order.',
    this.helperText = 'Please contact customer service at',
    this.phone = '242-300-2548',
    this.buttonText = 'back to home page',
    required this.onPressed,
    this.borderColor = const Color(0xFFFF6B6B),
    this.titleColor = const Color(0xFFE74C3C),
    this.iconBg = const Color(0xFFFFE9E9),
    this.backgroundColor = Colors.white,
    this.cornerRadius = 14,
    this.notchRadius = 12,
    this.dashColor = const Color(0xFFFFB3B3),
  });

  final String title;
  final String message;
  final String helperText;
  final String phone;
  final String buttonText;
  final VoidCallback onPressed;

  final Color borderColor;
  final Color titleColor;
  final Color iconBg;
  final Color dashColor;
  final Color backgroundColor;

  final double cornerRadius;
  final double notchRadius;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth.clamp(260, 420).toDouble();

        return Center(
          child: SizedBox(
            width: width,
            height: 500,
            child: CustomPaint(
              painter: _TicketBorderPainter(
                borderColor: borderColor,
                cornerRadius: cornerRadius,
                notchRadius: notchRadius,
              ),
              child: ClipPath(
                clipper: _TicketClipper(
                  cornerRadius: cornerRadius,
                  notchRadius: notchRadius,
                ),
                child: Container(
                  color: backgroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // top icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: iconBg,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.error_outline,color: Colors.red,size: 32),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'CircularPro',
                          color: titleColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 16,
                          height: 1.35,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        helperText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 16,
                          height: 1.35,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        phone,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 64),

                      // dashed divider
                      SizedBox(
                        height: 12,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _DashedLinePainter(color: dashColor),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // button
                      _PillButton(
                        text: buttonText,
                        onPressed: onPressed,
                      ),
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

class _PillButton extends StatelessWidget {
  const _PillButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ReceiptTheme.failedButtonBackgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            text,
            style: TextStyle(
              color: ReceiptTheme.successButtonTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              fontFamily: 'CircularPro',
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  _TicketClipper({
    required this.cornerRadius,
    required this.notchRadius,
  });

  final double cornerRadius;
  final double notchRadius;

  @override
  Path getClip(Size size) {
    final r = cornerRadius;
    final nr = notchRadius;
    final notchCenterY = size.height * 0.50;

    final rectPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(r),
        ),
      );

    final holes = Path()
    // left notch (half outside to cut-in)
      ..addOval(Rect.fromCircle(center: Offset(0, notchCenterY), radius: nr))
    // right notch
      ..addOval(Rect.fromCircle(center: Offset(size.width, notchCenterY), radius: nr));

    return Path.combine(PathOperation.difference, rectPath, holes);
  }

  @override
  bool shouldReclip(covariant _TicketClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.notchRadius != notchRadius;
  }
}

class _TicketBorderPainter extends CustomPainter {
  _TicketBorderPainter({
    required this.borderColor,
    required this.cornerRadius,
    required this.notchRadius,
  });

  final Color borderColor;
  final double cornerRadius;
  final double notchRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _TicketClipper(
      cornerRadius: cornerRadius,
      notchRadius: notchRadius,
    ).getClip(size);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = borderColor;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TicketBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.notchRadius != notchRadius;
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({
    required this.color,
    this.dashWidth = 6,
    this.dashGap = 5,
    this.strokeWidth = 1.4,
  });

  final Color color;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    double x = 0.0;
    final double y = size.height / 2;

    while (x < size.width) {
      final double x2 = (x + dashWidth).clamp(0.0, size.width).toDouble();
      canvas.drawLine(Offset(x, y), Offset(x2, y), p);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
