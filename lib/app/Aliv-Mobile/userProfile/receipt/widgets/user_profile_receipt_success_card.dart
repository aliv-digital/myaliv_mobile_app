import 'package:flutter/material.dart';

import '../models/user_profile_receipt_data.dart';
import '../models/user_profile_receipt_variant.dart';
import '../theme/user_profile_receipt_theme.dart';
import 'user_profile_receipt_back_button.dart';
import 'user_profile_receipt_detail_row.dart';
import 'user_profile_receipt_ticket_divider.dart';

class UserProfileReceiptSuccessCard extends StatelessWidget {
  const UserProfileReceiptSuccessCard({
    super.key,
    required this.data,
    required this.onBackHome,
    this.saveCardSection,
  });

  final UserProfileReceiptData data;
  final VoidCallback onBackHome;

  /// Optional slot for the "save credit card" affordance. Pass a
  /// [SaveCardOnReceiptSection]; it self-hides when there's no card to
  /// save, so this stays null on receipts that should never show it.
  final Widget? saveCardSection;

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      clipper: _TicketSideNotchClipper(
        cornerRadius: UserProfileReceiptTheme.cardCornerRadius,
        notchRadius: UserProfileReceiptTheme.cardNotchRadius,
        notchCenterY: UserProfileReceiptTheme.cardNotchTopOffset,
      ),
      clipBehavior: Clip.antiAlias,
      elevation: UserProfileReceiptTheme.cardElevation,
      shadowColor: UserProfileReceiptTheme.successCardShadowColor,
      color: UserProfileReceiptTheme.successCardBackgroundColor,
      child: Padding(
        padding: UserProfileReceiptTheme.cardPadding,
        child: Column(
          children: [
            SizedBox(
              width: UserProfileReceiptTheme.successIconOuterSize,
              height: UserProfileReceiptTheme.successIconOuterSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: UserProfileReceiptTheme.successIconOuter,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: UserProfileReceiptTheme.successIconInnerSize,
                    height: UserProfileReceiptTheme.successIconInnerSize,
                    decoration: BoxDecoration(
                      color: UserProfileReceiptTheme.successIconInner,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: UserProfileReceiptTheme.successIconCheckSize,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: UserProfileReceiptTheme.gapAfterIcon),
            SizedBox(
              width: UserProfileReceiptTheme.cardContentWidth,
              height: 24,
              child: Center(
                child: Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: UserProfileReceiptTheme.successTitle,
                ),
              ),
            ),
            const SizedBox(height: UserProfileReceiptTheme.gapAfterTitle),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    UserProfileReceiptTheme.dashedDividerHorizontalInset,
              ),
              child: UserProfileReceiptTicketDivider(
                height: UserProfileReceiptTheme.dashedDividerStrokeWidth,
              ),
            ),
            const SizedBox(height: UserProfileReceiptTheme.gapAfterTitle),
            LayoutBuilder(
              builder: (context, constraints) {
                final helperTextWidth =
                    constraints.maxWidth <
                        UserProfileReceiptTheme.cardContentWidth
                    ? constraints.maxWidth
                    : UserProfileReceiptTheme.cardContentWidth;

                return SizedBox(
                  width: helperTextWidth,
                  child: Text(
                    data.message,
                    textAlign: TextAlign.center,
                    style: UserProfileReceiptTheme.successBody,
                  ),
                );
              },
            ),
            const SizedBox(height: UserProfileReceiptTheme.gapAfterMessage),
            if (data.variant == UserProfileReceiptVariant.walletTransfer)
              _WalletTransferDetails(data: data)
            else
              _StandardReceiptDetails(data: data),
            const SizedBox(height: UserProfileReceiptTheme.gapAfterAmount),
            Divider(
              height: UserProfileReceiptTheme.bottomDividerThickness,
              thickness: UserProfileReceiptTheme.bottomDividerThickness,
              color: UserProfileReceiptTheme.successCardBottomDividerColor,
            ),
            const SizedBox(
              height: UserProfileReceiptTheme.gapAfterBottomDivider,
            ),
            ?saveCardSection,
            UserProfileReceiptBackButton(onTap: onBackHome),
            const SizedBox(height: UserProfileReceiptTheme.gapAfterButton),
          ],
        ),
      ),
    );
  }
}

class _StandardReceiptDetails extends StatelessWidget {
  const _StandardReceiptDetails({required this.data});

  final UserProfileReceiptData data;

  String _money(double value) => '\$ ${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserProfileReceiptDetailRow(
          label: data.typeLabel,
          value: data.topUpType,
        ),
        UserProfileReceiptDetailRow(label: 'date', value: data.dateText),
        UserProfileReceiptDetailRow(label: 'time', value: data.timeText),
        UserProfileReceiptDetailRow(
          label: 'phone no.',
          value: data.phoneNumber,
        ),
        UserProfileReceiptDetailRow(
          label: 'payment method',
          value: data.paymentMethod,
        ),
        const SizedBox(height: UserProfileReceiptTheme.gapBeforeAmount),
        const _ReceiptDashedDivider(),
        const SizedBox(height: UserProfileReceiptTheme.gapBeforeAmount),
        UserProfileReceiptDetailRow(
          label: 'amount',
          value: _money(data.amount),
          valueBold: true,
        ),
      ],
    );
  }
}

class _WalletTransferDetails extends StatelessWidget {
  const _WalletTransferDetails({required this.data});

  final UserProfileReceiptData data;

  String _money(double value) => '\$ ${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserProfileReceiptDetailRow(
          label: 'transferred number',
          value: data.phoneNumber,
        ),
        UserProfileReceiptDetailRow(
          label: 'subtotal',
          value: _money(data.amount),
        ),
        UserProfileReceiptDetailRow(label: 'vat', value: _money(0)),
        const SizedBox(height: UserProfileReceiptTheme.gapBeforeAmount),
        const _ReceiptDashedDivider(),
        const SizedBox(height: UserProfileReceiptTheme.gapBeforeAmount),
        UserProfileReceiptDetailRow(
          label: 'will be transferred',
          value: _money(data.amount),
          valueBold: true,
        ),
      ],
    );
  }
}

class _ReceiptDashedDivider extends StatelessWidget {
  const _ReceiptDashedDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: UserProfileReceiptTheme.dashedDividerHorizontalInset,
      ),
      child: UserProfileReceiptTicketDivider(
        height: UserProfileReceiptTheme.dashedDividerStrokeWidth,
      ),
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
    final base = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(cornerRadius),
        ),
      );

    // Match the receipt ticket shape by removing the two side notches.
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

    return Path.combine(PathOperation.difference, base, notches);
  }

  @override
  bool shouldReclip(covariant _TicketSideNotchClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.notchRadius != notchRadius ||
        oldClipper.notchCenterY != notchCenterY;
  }
}
