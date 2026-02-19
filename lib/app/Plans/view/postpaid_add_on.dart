import 'package:flutter/cupertino.dart' show SizedBox;
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Plans/view/start_plan_bottom_sheet.dart';

class RoamingAddOnCard extends StatefulWidget {
  final String title;
  final String duration;
  final String data;
  final String price;

  const RoamingAddOnCard({
    super.key,
    required this.title,
    required this.duration,
    required this.data,
    required this.price,
  });


  @override
  State<RoamingAddOnCard> createState() => _RoamingAddOnCardState();
}

class _RoamingAddOnCardState extends State<RoamingAddOnCard>
    with TickerProviderStateMixin {
  bool _expanded = false;

  void _toggle() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 16,
              offset: Offset(8, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Header(expanded: _expanded, onToggle: _toggle, title:widget.title,duration:widget.duration),
            const SizedBox(height: 12),
            _BalanceRow(data: widget.data),
            if (_expanded) ...[
              const SizedBox(height: 12),
              _Description(desc: widget.data),
            ],
            const SizedBox(height: 16),
            _Actions(
              expanded: _expanded,
              onToggle: _toggle,
            ),
          ],
        ),
      ),
    );
  }
}
class _Header extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final String title;
  final String duration;
  const _Header({
    required this.expanded,
    required this.onToggle, required this.title, required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
             Text(title,
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: AnimatedRotation(
                turns: expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          duration,
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 10,
            color: Color(0xFF707070),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],

    );
  }
}

class _BalanceRow extends StatelessWidget {
  final String data;

  const _BalanceRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // const Icon(Icons.wifi, size: 18, color: Color(0xFFFF6C36)),
        SvgPicture.asset('assets/icons/Rss.svg'),
        const Text(
          'data balance',
          style: TextStyle(
            color: Color(0xFFFF6C36),
            fontSize: 18,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
         Text(
          data,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'CircularPro',
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F6),
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Text(
            '\$ 18.18',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'CircularPro',
            ),
          ),
        ),
      ],
    );
  }
}
class _Description extends StatelessWidget {
  const _Description({required String desc});

  @override
  Widget build(BuildContext context)
  {
    return const Text(
      'The ALIV Freedom 6 Plan provides users with unlimited talk and text within the Bahamas, ensuring you can stay connected with friends, family, and colleagues without worrying about running out of minutes or messages. The ALIV Freedom 6 Plan is ideal for individuals or families looking for a reliable, cost-effective mobile phone service with the flexibility to adapt to their lifestyle and communication needs.',
      style: TextStyle(
        fontSize: 10,
        height: 1.38,
        fontFamily: 'CircularPro',
        fontWeight: FontWeight.w500,
        color: Color(0xFF222222),

      ),
    );
  }
}
class _Actions extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  const _Actions({
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onToggle,
            style: OutlinedButton.styleFrom(
              shape: const StadiumBorder(),
              side: const BorderSide(color: Color(0xFFF1F1F8)),
            ),
            child: Text(
              expanded ? 'hide details' : 'view details',
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 13,
                color: Color(0xFF645D9C),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {

              showStartPlanBottomSheet(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF645D9C),
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'purchase now',
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 13,
                color: Color(0xFFF1F1F8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showStartPlanBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, // ⭐ THIS IS THE FIX
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) {
        return const StartPlanBottomSheet();
      },
    );
  }
}

// class AddOnCard extends StatelessWidget {
//   final String title;
//   final String duration;
//   final String data;
//   final String price;
//
//   const AddOnCard({
//     super.key,
//     required this.title,
//     required this.duration,
//     required this.data,
//     required this.price,
//   });
//
//   static const Color purple = Color(0xFF645D9C);
//   static const Color orange = Color(0xFFFF6C36);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x0C000000),
//             blurRadius: 16,
//             offset: Offset(8, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// HEADER
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontFamily: 'CircularPro',
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const Icon(Icons.keyboard_arrow_down),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             duration,
//             style: const TextStyle(
//               fontFamily: 'CircularPro',
//               fontSize: 10,
//               color: Color(0xFF707070),
//             ),
//           ),
//
//           const SizedBox(height: 12),
//
//           /// DATA + PRICE
//           Row(
//             children: [
//               Expanded(
//                 child: Row(
//                   children: [
//                     const Icon(Icons.wifi, color: orange, size: 18),
//                     const SizedBox(width: 4),
//                     const Text(
//                       'data balance',
//                       style: TextStyle(
//                         fontFamily: 'CircularPro',
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                         color: orange,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       data,
//                       style: const TextStyle(
//                         fontFamily: 'CircularPro',
//                         fontSize: 24,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF222222),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF3F3F6),
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: Text(
//                   price,
//                   style: const TextStyle(
//                     fontFamily: 'CircularPro',
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 16),
//
//           /// ACTIONS
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () {
//                     // view details
//                   },
//                   style: OutlinedButton.styleFrom(
//                     shape: const StadiumBorder(),
//                     side: const BorderSide(color: Color(0xFFF1F1F8)),
//                   ),
//                   child: const Text(
//                     'view details',
//                     style: TextStyle(
//                       fontFamily: 'CircularPro',
//                       fontSize: 13,
//                       color: purple,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // purchase now
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: purple,
//                     shape: const StadiumBorder(),
//                     elevation: 0,
//                   ),
//                   child: const Text(
//                     'purchase now',
//                     style: TextStyle(
//                       fontFamily: 'CircularPro',
//                       fontSize: 13,
//                       color: Color(0xFFF1F1F8),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
