import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// class CommonSwitchButtonLarge extends StatefulWidget {
//   final bool initialValue;
//   final ValueChanged<bool>? onChanged;
//
//   const CommonSwitchButtonLarge({
//     super.key,
//     this.initialValue = false,
//     this.onChanged,
//   });
//
//   @override
//   State<CommonSwitchButtonLarge> createState() =>
//       _CommonSwitchButtonLargeState();
// }

// class _CommonSwitchButtonLargeState extends State<CommonSwitchButtonLarge> {
//   late bool isOn;
//
//   @override
//   void initState() {
//     super.initState();
//     isOn = widget.initialValue;
//   }

  // void _toggle() {
  //   setState(() => isOn = !isOn);
  //   widget.onChanged?.call(isOn);
  // }
class CommonSwitchButtonLarge extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const CommonSwitchButtonLarge({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // TOGGLE BUTTON
        GestureDetector(
          // onTap: _toggle,
          onTap: () => onChanged?.call(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 28.0, // 🔥 FIXED HEIGHT
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFDFD),
              borderRadius: BorderRadius.circular(832.5),
              border: Border.all(width: 0.83, color: const Color(0xFFDBDBDB)),
            ),
            child: value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      const SizedBox(width: 3),

                      Text(
                        'on',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 2),
                      SvgPicture.asset(
                        'assets/icons/tikIcon.svg',
                        height: 20,
                        width: 20,
                      ),
                      const SizedBox(width: 3),

                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      const SizedBox(width: 3),

                      SvgPicture.asset(
                        'assets/icons/cross.svg',
                        height: 20,
                        width: 20,
                        // color: const Color(0xFF707070),
                      ),

                      const SizedBox(width: 2),
                      Text(
                        'off',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF707070),
                          fontSize: 15,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 3),

                    ],
                  ),
            // child: Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     SizedBox(
            //       width: 20, // 🔥 FIXED
            //       child: Text(
            //         isOn ? 'on' : 'off',
            //         textAlign: TextAlign.center,
            //         style: const TextStyle(
            //           color: Colors.black,
            //           fontSize: 12,
            //           fontFamily: 'CircularPro',
            //           fontWeight: FontWeight.w400, // closest to 450
            //         ),
            //       ),
            //     ),
            //
            //     const SizedBox(width: 4),
            //
            //     AnimatedContainer(
            //       duration: const Duration(milliseconds: 180),
            //       width: 20,
            //       height: 20,
            //       decoration: BoxDecoration(
            //         color: isOn
            //             ? const Color(0xFF645D9C)
            //             : const Color(0xFFEAEAEA),
            //         borderRadius: BorderRadius.circular(832.5),
            //       ),
            //       alignment: Alignment.center,
            //       child: isOn
            //           ? SvgPicture.asset(
            //               'assets/icons/tikIcon.svg',
            //               width: 8.33,
            //               height: 8.33,
            //             )
            //           : SvgPicture.asset(
            //               'assets/icons/cross.svg',
            //               width: 8.33,
            //               height: 8.33,
            //             ),
            //     ),
            //   ],
            // ),
          ),
        ),
      ],
    );
  }
}
