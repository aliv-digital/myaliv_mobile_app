import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanPurchaseReceipt/theme/home_plan_purchase_receipt_theme.dart';
import 'home_plan_purchase_receipt_ticket_divider.dart';

/// Ticket-shaped payment failure card — pixel-matched to the "Payment Failed"
/// receipt design.
///
/// Layout (all heights fixed so the notch stays precisely at the divider):
///
///   cardPad(18) + topSpacer(30) + icon(56) + gapIcon(14) +
///   titleH(26) + gapTitle(10) + subtitleH(48) + gapDiv(30) +
///   dividerH/2(11)  →  notchCenterY = 243
class HomePlanPurchaseReceiptPaymentFailedTicket extends StatelessWidget {
  const HomePlanPurchaseReceiptPaymentFailedTicket({
    super.key,
    this.message = 'There was a problem processing\nyour order.',
    this.buttonText = 'back to home page',
    required this.onPressed,
  });

  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  // ─── Layout constants (must match the notchCenterY formula) ───────────────
  static const double _cardPad = 18;
  static const double _cornerRadius = 16;
  static const double _notchRadius = 10;

  static const double _topSpacer = 30;
  static const double _iconSize = 80; // outer pink circle
  static const double _innerCircleSize = 44;
  static const double _gapAfterIcon = 14;
  static const double _titleH = 26; // fixed to lock notch
  static const double _gapAfterTitle = 10;
  static const double _subtitleH = 48; // fixed to lock notch (2 lines × ~24pt)
  static const double _gapBeforeDiv = 30;
  static const double _dividerH = 22;

  // notchCenterY = _cardPad + _topSpacer + _iconSize + _gapAfterIcon +
  //                _titleH + _gapAfterTitle + _subtitleH + _gapBeforeDiv +
  //                _dividerH / 2
  static const double _notchCenterY = _cardPad +
      _topSpacer +
      _iconSize +
      _gapAfterIcon +
      _titleH +
      _gapAfterTitle +
      _subtitleH +
      _gapBeforeDiv +
      _dividerH / 2; // = 243

  // ─── Design tokens ────────────────────────────────────────────────────────
  static const _iconColor = Color(0xFFE57373); // salmon-red circle border + icon
  static const _iconBgColor = Color(0xFFFDE8E8); // light-pink outer circle fill
  static const _titleRed = Color(0xFFE53935);
  static const _titleYellow = Color(0xFFFFF176); // "Failed" word highlight
  static const _subtitleGrey = Color(0xFF707070);
  static const _buttonTextColor = Color(0xFF655C9A); // purple

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      clipper: _TicketSideNotchClipper(
        cornerRadius: _cornerRadius,
        notchRadius: _notchRadius,
        notchCenterY: _notchCenterY,
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      // Subtle pinkish shadow — visible "red glow" around the failure card.
      shadowColor: const Color(0x55FDA29B),
      color: Colors.white,
      child: DecoratedBox(
        // Pink border painted on top of content (clipped by PhysicalShape at
        // the notches, which creates the correct notched-border appearance).
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border.all(
            color: HomePlanPurchaseReceiptTheme.redDashColor,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(_cornerRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(_cardPad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top spacer ────────────────────────────────────────────────
              const SizedBox(height: _topSpacer),

              // ── Alert icon: large pink bg circle + inner red border circle ─
              Container(
                width: _iconSize,
                height: _iconSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _iconBgColor,
                ),
                alignment: Alignment.center,
                child: Container(
                  width: _innerCircleSize,
                  height: _innerCircleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _iconColor, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.priority_high,
                    color: _iconColor,
                    size: 22,
                  ),
                ),
              ),

              const SizedBox(height: _gapAfterIcon),

              // ── Title: "Payment " plain + "Failed" with yellow highlight ──
              SizedBox(
                height: _titleH,
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Payment ',
                        style: const TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _titleRed,
                          height: 1.0,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 1,
                        ),
                        child: const Text(
                          'Failed',
                          style: TextStyle(
                            fontFamily: 'CircularPro',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _titleRed,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: _gapAfterTitle),

              // ── Subtitle ─────────────────────────────────────────────────
              SizedBox(
                height: _subtitleH,
                child: Center(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _subtitleGrey,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: _gapBeforeDiv),

              // ── Dashed divider (notch aligns here) ───────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: HomePlanPurchaseReceiptTicketDivider(
                  height: _dividerH,
                  dashColor: HomePlanPurchaseReceiptTheme.redDashColor,
                ),
              ),

              const SizedBox(height: 28),

              // ── Back button — narrow, centered ────────────────────────────
              Center(
                child: SizedBox(
                  width: 160,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: onPressed,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFF1F1F8),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      backgroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontFamily: 'CircularPro',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _buttonTextColor,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Empty bottom space (receipt ticket aesthetic) ─────────────
              const SizedBox(height: 160),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Clipper (same pattern as success card) ───────────────────────────────────

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
  bool shouldReclip(covariant _TicketSideNotchClipper old) =>
      old.cornerRadius != cornerRadius ||
      old.notchRadius != notchRadius ||
      old.notchCenterY != notchCenterY;
}
