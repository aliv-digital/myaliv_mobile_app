// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/theme/guest_topup_theme.dart';
//
// class GradientInputField extends StatelessWidget {
//   final String label;
//   final String hint;
//   final ValueChanged<String> onChanged;
//
//   const GradientInputField({super.key,
//     required this.label,
//     required this.hint,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 68,right: 68),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,  // Center everything horizontally
//         children: [
//           Container(
//             color: Colors.white,
//             width: double.infinity,  // Ensuring label stretches across
//             padding: const EdgeInsets.symmetric(horizontal: 14),
//             child: SizedBox.shrink(),
//           ),
//           SizedBox(height: 8),
//           Container(
//             width: double.infinity,
//             height: 68,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(width: 3, color: Colors.transparent),
//               gradient: LinearGradient(
//                 colors: [
//                   GuestTopUpTheme.yellow,
//                   GuestTopUpTheme.blue,
//                   GuestTopUpTheme.purple,
//                   GuestTopUpTheme.lightPink,
//                   GuestTopUpTheme.purple,
//                   GuestTopUpTheme.orange
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: TextField(
//               maxLines: 1,
//               style: TextStyle(
//                 fontSize: 40 ,
//                 fontWeight: FontWeight.w700,
//                 color: GuestTopUpTheme.amountTextColor,  // Same text color as the label
//               ),
//               onChanged: onChanged, // onChanged event passed here
//               keyboardType: TextInputType.number,  // Ensure numeric input
//               textAlign: TextAlign.center,  // Center the text inside the field
//               decoration: InputDecoration(
//                 prefixText: ' \$', // Add dollar sign before the value
//                 prefixStyle: TextStyle(
//                   fontSize: 40,
//                   fontWeight: FontWeight.w700,
//                   color: GuestTopUpTheme.amountTextColor,  // Same text color as the label
//                 ),
//                 hintText: hint,
//                 hintStyle: TextStyle(
//                   fontSize: 40 ,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.deepPurple.withValues(alpha: .2),  // Same text color as the label
//                 ),
//                 filled: true,
//                 fillColor: Colors.white, // White background
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide.none, // Hide default border
//                 ),
//                 contentPadding: EdgeInsets.only( top: 5, bottom: 5,right: 10),
//               ),
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'enter top up amount',  // Text displayed below input
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w400,
//               color: Colors.black,  // Same text color as label
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/theme/guest_topup_theme.dart';

class GradientInputField extends StatefulWidget {
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  const GradientInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<StatefulWidget> createState() {
    return _GradientInputFieldState();
  }


}

class _GradientInputFieldState extends State<GradientInputField> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 68, right: 68),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SizedBox.shrink(),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(width: 3, color: Colors.transparent),
              gradient: LinearGradient(
                colors: [
                  GuestTopUpTheme.yellow,
                  GuestTopUpTheme.blue,
                  GuestTopUpTheme.purple,
                  GuestTopUpTheme.lightPink,
                  GuestTopUpTheme.purple,
                  GuestTopUpTheme.orange
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 1,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: GuestTopUpTheme.amountTextColor,
              ),
              onChanged: widget.onChanged,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start, // Start text alignment for the input field
              decoration: InputDecoration(
                prefixIcon: _controller.text.isEmpty ? Padding(
                  padding: const EdgeInsets.only(left: 50), // Center the prefix '$'
                  child: Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: GuestTopUpTheme.amountTextColor,
                    ),
                  ),
                ) : null,
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.deepPurple.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.only(top:1, bottom: 1, right: 10),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'enter top up amount',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: GuestTopUpTheme.simpleTxt,
              fontFamily: 'CircularPro'
            ),
          ),
        ],
      ),
    );
  }
}
