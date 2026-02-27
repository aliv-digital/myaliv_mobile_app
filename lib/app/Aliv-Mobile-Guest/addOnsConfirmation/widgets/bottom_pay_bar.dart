// import 'package:flutter/material.dart';
// import '../theme/add_ons_confirmation_theme.dart';
//
// class BottomPayBar extends StatelessWidget {
//   final double total;
//   final VoidCallback onPayNow;
//
//   const BottomPayBar({
//     super.key,
//     required this.total,
//     required this.onPayNow,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 76,
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 18,
//             offset: Offset(0, -10),
//             color: AddOnsConfirmationTheme.shadow,
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Left total
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 '\$ ${total.toStringAsFixed(2)}',
//                 style: AddOnsConfirmationTheme.t(18, weight: FontWeight.w900),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 'vat inclusive',
//                 style: AddOnsConfirmationTheme.t(
//                   11,
//                   weight: FontWeight.w700,
//                   color: AddOnsConfirmationTheme.textGrey,
//                 ),
//               ),
//             ],
//           ),
//
//           const Spacer(),
//
//           // Pay now button
//           SizedBox(
//             height: 44,
//             width: 170,
//             child: ElevatedButton(
//               onPressed: onPayNow,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AddOnsConfirmationTheme.purple,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(999),
//                 ),
//               ),
//               child: Text(
//                 'pay now',
//                 style: AddOnsConfirmationTheme.t(
//                   14,
//                   weight: FontWeight.w900,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
