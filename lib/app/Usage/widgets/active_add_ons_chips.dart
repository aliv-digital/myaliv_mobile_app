import 'package:flutter/material.dart';

/// Static "active add-ons" chip row shown above the prepaid usage list.
/// Currently a placeholder until the chip data is wired to
/// `PlansCubit.state.addOns`.
class ActiveAddOnsChips extends StatelessWidget {
  const ActiveAddOnsChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'active add-ons',
          style: TextStyle(
            color: Color(0xFF222222),
            fontSize: 12,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: const [
            _Chip('voice'),
            _Chip('sms'),
            _Chip('data'),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: ShapeDecoration(
        color: const Color(0xFFF4F4F6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF222222),
          fontSize: 14,
          fontFamily: 'CircularPro',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
