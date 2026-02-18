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
            padding: const EdgeInsets.fromLTRB(2, 2, 4, 2),
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
                      const SizedBox(width: 2),
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

                      const SizedBox(width: 2),
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
        const SizedBox(width: 5),

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
