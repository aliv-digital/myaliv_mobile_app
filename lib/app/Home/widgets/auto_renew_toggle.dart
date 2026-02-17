import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class AutoRenewToggle extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const AutoRenewToggle({super.key, this.initialValue = false, this.onChanged});

  @override
  State<AutoRenewToggle> createState() => _AutoRenewToggleState();
}

class _AutoRenewToggleState extends State<AutoRenewToggle> {
  late bool isOn;

  @override
  void initState() {
    super.initState();
    isOn = widget.initialValue;
  }

  void _toggle() {
    setState(() => isOn = !isOn);
    widget.onChanged?.call(isOn);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // TOGGLE BUTTON
        GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            // height: 28,
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
            decoration: BoxDecoration(
              color: isOn
                  ? const Color(0xFFF4F4F4) //Color(0xFF645D9C) // ON → dark
                  : const Color(0xFFEAEAEA), // OFF → light grey
              borderRadius: BorderRadius.circular(832.50),
              border: Border.all(
                color: isOn ? Colors.transparent : const Color(0xFFBDBDBD),
              ),
            ),
            child: isOn
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'on',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      SvgPicture.asset(
                        'assets/icons/tikIcon.svg',
                        height: 14,
                        width: 14,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/cross.svg',
                        height: 14,
                        width: 14,
                        // color: const Color(0xFF707070),
                      ),

                      const SizedBox(width: 6),
                      Text(
                        'off',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF707070),
                          fontSize: 12,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        // AnimatedToggleSwitch<bool>.dual(
        //   current: isOn,
        //   first: false,
        //   second: true,
        //   height: 35, // ✅ exact height
        //   spacing: 0,
        //   // borderRadius: BorderRadius.circular(832.5), // match figma
        //   onChanged: (val) => setState(() => isOn = val),
        //
        //   style: const ToggleStyle(
        //     backgroundColor: Color(0xFFFDFDFD),
        //     borderColor: Color(0xFFDBDBDB),
        //
        //     // borderWidth: 0.83,
        //   ),
        //
        //   styleBuilder: (value) => ToggleStyle(
        //     indicatorColor:
        //     value ? const Color(0xFF645D9C) : const Color(0xFF6F6F6F),
        //     indicatorBorderRadius: BorderRadius.circular(999),
        //   ),
        //
        //   iconBuilder: (value) => Icon(
        //     value ? Icons.check : Icons.close,
        //     size: 8.33, // ✅ match figma icon size
        //     color: Colors.white,
        //   ),
        //
        //   indicatorSize: const Size(30, 24), // ✅ exact indicator size
        //
        //   textBuilder: (value) => Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 3),
        //     child: Text(
        //       value ? 'on' : 'off',
        //       style: TextStyle(
        //         fontSize: 12,
        //         fontFamily: 'Circular Pro',
        //         fontWeight: FontWeight.w400, // w450 approximated
        //         color: value
        //             ? Colors.black
        //             : const Color(0xFF7A7A7A),
        //       ),
        //     ),
        //   ),
        // ),
        const SizedBox(width: 10),

        // LABEL
        Text(
          'auto renew',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
