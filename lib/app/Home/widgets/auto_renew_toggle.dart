import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class AutoRenewToggle extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const AutoRenewToggle({
    super.key,
    this.initialValue = false,
    this.onChanged,
  });

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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isOn
                  ? const Color(0xFF5A5A5A) // ON → dark
                  : const Color(0xFFEAEAEA), // OFF → light grey
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOn
                    ? Colors.transparent
                    : const Color(0xFFBDBDBD),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isOn
                      ? IconsaxPlusLinear.tick_circle
                      : IconsaxPlusLinear.close_circle,
                  size: 14,
                  color: isOn ? Colors.white : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  isOn ? 'on' : 'off',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isOn ? Colors.white : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        // LABEL
        const Text(
          'auto renew',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
