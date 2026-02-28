// import 'package:flutter/material.dart';
// import '../theme/confirm_top_up_prepaid_theme.dart';
// import 'dashed_divider.dart';
// import 'ticket_clipper.dart';
//
// class PromoSummaryTicket extends StatelessWidget {
//   final TextEditingController controller;
//   final VoidCallback onApply;
//   final ValueChanged<String> onChanged;
//
//   final double subTotal;
//   final double vat;
//   final double total;
//
//   const PromoSummaryTicket({
//     super.key,
//     required this.controller,
//     required this.onApply,
//     required this.onChanged,
//     required this.subTotal,
//     required this.vat,
//     required this.total,
//   });
//
//   String _money(double v) => '\$ ${v.toStringAsFixed(2)}';
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipPath(
//       clipper: TicketClipper(radius: 9, notchCount: 11),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: ConfirmTopUpPrepaidTheme.ticket,
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: controller,
//                       onChanged: onChanged,
//                       style: ConfirmTopUpPrepaidTheme.bodyMd(context),
//                       decoration: InputDecoration(
//                         hintText: 'promo code',
//                         hintStyle: ConfirmTopUpPrepaidTheme.bodyMd(context).copyWith(color: const Color(0xFFBDBDBD)),
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: onApply,
//                     child: Text(
//                       'apply',
//                       style: ConfirmTopUpPrepaidTheme.bodyMd(context).copyWith(
//                         fontWeight: FontWeight.w800,
//                         color: ConfirmTopUpPrepaidTheme.primary,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             _row(context, 'sub total', _money(subTotal)),
//             const SizedBox(height: 10),
//             _row(context, 'vat', _money(vat)),
//             const SizedBox(height: 14),
//
//             DashedDivider(color: Colors.white.withValues(alpha: 0.55)),
//             const SizedBox(height: 14),
//
//             _row(context, 'total', _money(total), isTotal: true),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _row(BuildContext context, String left, String right, {bool isTotal = false}) {
//     final label = ConfirmTopUpPrepaidTheme.ticketLabel(context).copyWith(
//       fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
//     );
//     final value = ConfirmTopUpPrepaidTheme.ticketValue(context).copyWith(
//       fontSize: isTotal ? 15 : 13,
//     );
//
//     return Row(
//       children: [
//         Text(left, style: label),
//         const Spacer(),
//         Text(right, style: value),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Home/home/home_screen.dart';
import '../theme/confirm_top_up_prepaid_theme.dart';
import 'dashed_divider.dart';
import 'ticket_clipper.dart';

class PromoSummaryTicket extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onApply;
  final ValueChanged<String> onChanged;

  final double subTotal;
  final double vat;
  final double total;

  const PromoSummaryTicket({
    super.key,
    required this.controller,
    required this.onApply,
    required this.onChanged,
    required this.subTotal,
    required this.vat,
    required this.total,
  });

  String _money(double v) => '\$ ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Figma: card shadow is outside the clipped shape
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 10),
            color: Color(0x22000000),
          ),
        ],
      ),
      child:
      ClipPath(
        // tweak notch look
        clipper: TicketClipper(radius: 8, notchCount: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
          decoration: BoxDecoration(
            color: ConfirmTopUpPrepaidTheme.ticket,
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: AssetImage('assets/images/Promo BG.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
             if (config.isPrepaid == true)  _promoInput(context),
              if (config.isPrepaid == true) const SizedBox(height: 24),

              _row(context, 'sub total', _money(subTotal)),
              const SizedBox(height: 14),
              _row(context, 'vat', _money(vat)),
              const SizedBox(height: 24),

              // Figma: tighter dashes, lower opacity
              DashedDivider(
                color: const Color(0xFFEDEDED),
                // dashWidth: 4,
                // dashGap: 4,
                height: 1,
              ),
              const SizedBox(height: 24),

              _row(context, 'total', _money(total), isTotal: true),
              const SizedBox(height: 16),

            ],
          ),
        ),
      ),
    );
  }

  Widget _promoInput(BuildContext context) {
    return Container(
      height: 52, // match figma
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: ConfirmTopUpPrepaidTheme.bodyMd(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'promo code',
                hintStyle: TextStyle(
                  color: const Color(0xFFC9C9C9),
                  fontSize: 16,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: onApply,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Text(
                'apply',
                style: TextStyle(
                  color: const Color(0xFF645D9C),
                  fontSize: 16,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String left, String right, {bool isTotal = false}) {
    final label = ConfirmTopUpPrepaidTheme.ticketLabel(context).copyWith(
      fontWeight:   FontWeight.w500,
      fontSize: 14
    );

    final value = ConfirmTopUpPrepaidTheme.ticketValue(context).copyWith(
      fontWeight:   FontWeight.w500,
    );

    return Row(
      children: [
        Text(left, style: label),
        const Spacer(),
        Text(right, style: value),
      ],
    );
  }
}
