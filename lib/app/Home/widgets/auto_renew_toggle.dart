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
      children: [
        // TOGGLE BUTTON
        GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
            decoration: BoxDecoration(
              color: isOn
                  ? const  Color(0xFFF4F4F4)//Color(0xFF645D9C) // ON → dark
                  : const Color(0xFFEAEAEA), // OFF → light grey
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOn ? Colors.transparent : const Color(0xFFBDBDBD),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isOn
                    ? Icon(
                        IconsaxPlusLinear.tick_circle,
                        size: 16,
                        color: Color(0xFFEE3434),
                      )
                    : SvgPicture.asset(
                        'assets/icons/clock_toggle.svg',
                        height: 16,
                        width: 16,
                      ),
                // Icon(
                //   isOn
                //       ? IconsaxPlusLinear.tick_circle
                //       : IconsaxPlusLinear.close_circle,
                //   size: 14,
                //   color: isOn ? Colors.white : Colors.grey,
                // ),
                const SizedBox(width: 6),
                Text(
                  isOn ? 'on' : 'off',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isOn ? Colors.black : const Color(0xFF707070),
                    fontSize: 12,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

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
