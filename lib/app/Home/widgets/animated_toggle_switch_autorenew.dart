import 'package:flutter/material.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class AnimatedAutoRenewToggle extends StatefulWidget {
  const AnimatedAutoRenewToggle({super.key});

  @override
  State<AnimatedAutoRenewToggle> createState() => _AnimatedAutoRenewToggleState();
}

class _AnimatedAutoRenewToggleState extends State<AnimatedAutoRenewToggle> {
  bool isOn = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedToggleSwitch<bool>.dual(
          current: isOn,
          first: false,
          second: true,
          height: 28,
          spacing: 6,
          // borderRadius: BorderRadius.circular(1000),
          onChanged: (val) => setState(() => isOn = val),

          style: const ToggleStyle(
            backgroundColor: Color(0xFFFDFDFD),
            borderColor: Color(0xFFDBDBDB),
            // borderWidth: 0.83,
          ),

          styleBuilder: (value) => ToggleStyle(
            indicatorColor:
            value ? const Color(0xFF645D9C) : const Color(0xFF6F6F6F),
          ),

          iconBuilder: (value) => Icon(
            value ? Icons.check : Icons.close,
            size: 14,
            color: Colors.white,
          ),

          textBuilder: (value) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              value ? 'on' : 'off',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
                color: value ? Colors.black : const Color(0xFF7A7A7A),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        const Text(
          'Auto Renew',
          style: TextStyle(
            color: Color(0xFF222222),
            fontSize: 14,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
