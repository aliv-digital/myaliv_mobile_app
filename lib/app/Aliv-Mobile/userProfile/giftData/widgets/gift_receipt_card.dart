import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/gift_data_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/gift_data_ticket_divider.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

/// Notched ticket card that renders the "Data Gift Transfer Successful!" screen.
class GiftReceiptCard extends StatelessWidget {
  const GiftReceiptCard({
    super.key,
    required this.data,
    required this.onGiftAgain,
    required this.onBackHome,
  });

  final GiftDataReceiptData data;
  final VoidCallback onGiftAgain;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      clipper: const _TicketSideNotchClipper(
        cornerRadius: GiftDataTheme.receiptCardRadius,
        notchRadius: GiftDataTheme.receiptNotchRadius,
        notchCenterY: GiftDataTheme.receiptNotchTopOffset - 14.0,
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            top: GiftDataTheme.receiptNotchTopOffset - 14.0,
            left: GiftDataTheme.receiptNotchRadius,
            right: GiftDataTheme.receiptNotchRadius,
            child: const GiftDataTicketDivider(height: 1),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: Column(
              children: [
                _SuccessBadge(),
                const SizedBox(height: 16),
                const Text(
                  'Data Gift Transfer Successful!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppConstants.defaultFontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: GiftDataTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 85.0),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'It may take a few moments before the order is processed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppConstants.defaultFontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: GiftDataTheme.textMuted,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _DetailRow(
                  label: 'recipient number',
                  value: data.recipientNumber,
                ),
                _DetailRow(
                  label: 'order reference',
                  value: data.orderReference,
                ),
                _DetailRow(label: 'date', value: data.dateText),
                _DetailRow(label: 'time', value: data.timeText),
                _DetailRow(label: 'total data', value: data.totalDataLabel),
                _DetailRow(
                  label: 'remaining data',
                  value: data.remainingDataLabel,
                ),
                _DetailRow(
                  label: 'data gifted',
                  value: data.dataGiftedLabel,
                  valueBold: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: GiftDataTheme.ctaHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GiftDataTheme.primaryPurple,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    onPressed: onGiftAgain,
                    child: const Text(
                      'gift data again',
                      style: GiftDataTheme.ctaLabel,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: GiftDataTheme.ctaHeight,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFF1F1F8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    onPressed: onBackHome,
                    child: const Text(
                      'back to home page',
                      style: TextStyle(
                        fontFamily: AppConstants.defaultFontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: GiftDataTheme.primaryPurple,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: GiftDataTheme.receiptIconHalo,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: GiftDataTheme.receiptIconFill,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  final String label;
  final String value;
  final bool valueBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppConstants.defaultFontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: GiftDataTheme.textMuted,
                height: 1.4,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppConstants.defaultFontFamily,
              fontSize: valueBold ? 16 : 15,
              fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
              color: GiftDataTheme.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cuts matching semicircular notches into the left/right edges of the card.
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
