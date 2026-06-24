import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/theme/home_plan_confirmation_theme.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/widgets/mifi_alt_contact_styles.dart';

class MifiMarketingRadioRow extends StatelessWidget {
  const MifiMarketingRadioRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: MifiAltContactStyles.radioLabel,
              ),
            ),
            _RadioDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    const double size = 20;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? HomePlanConfirmationTheme.purple
              : const Color(0xFFB8BACB),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: HomePlanConfirmationTheme.purple,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
