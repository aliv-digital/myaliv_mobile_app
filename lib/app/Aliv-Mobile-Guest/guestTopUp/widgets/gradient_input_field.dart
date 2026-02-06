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
  bool _isFormatting = false;

  @override
  void initState() {
    super.initState();
    _controller.text = '\$15.00';
  }

  void _handleInputChange(String raw) {
    if (_isFormatting) return;

    final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) {
      _isFormatting = true;
      _controller.clear();
      _isFormatting = false;
      widget.onChanged('');
      return;
    }

    _isFormatting = true;
    _controller.text = '\$${cleaned}';
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    _isFormatting = false;
    widget.onChanged(cleaned);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth = (constraints.maxWidth - 136).clamp(200.0, constraints.maxWidth);

        return Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: fieldWidth,
                height: 68,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: SweepGradient(
                      colors: [
                        GuestTopUpTheme.yellow,
                        GuestTopUpTheme.blue,
                        GuestTopUpTheme.purple,
                        GuestTopUpTheme.lightPink,
                        GuestTopUpTheme.orange,
                        GuestTopUpTheme.yellow,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _controller,
                        maxLines: 1,
                        style: GuestTopUpTheme.amountInput,
                        onChanged: _handleInputChange,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: (68 - 32) / 2 + 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'enter top up amount',
                style: GuestTopUpTheme.amountHelper,
              ),
            ],
          ),
        );
      },
    );
  }
}
