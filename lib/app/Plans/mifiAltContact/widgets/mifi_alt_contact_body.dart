import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/widgets/mifi_alt_contact_card.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/widgets/mifi_alt_contact_styles.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/widgets/mifi_marketing_radio_row.dart';

class MifiAltContactBody extends StatelessWidget {
  const MifiAltContactBody({
    super.key,
    required this.busy,
    required this.marketingOptIn,
    required this.phoneField,
    required this.onMarketingChanged,
  });

  final bool busy;
  final bool? marketingOptIn;
  final Widget phoneField;
  final ValueChanged<bool> onMarketingChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MifiAltContactCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'we would like to stay connected. please provide a '
                  'mobile number that is not your mifi number.',
                  style: MifiAltContactStyles.bodyText,
                ),
                const SizedBox(height: 16),
                const Text(
                  'mobile number:',
                  style: MifiAltContactStyles.fieldLabel,
                ),
                const SizedBox(height: 8),
                phoneField,
              ],
            ),
          ),
          const SizedBox(height: 16),
          MifiAltContactCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Text(
                    'would you like to receive plan discounts and '
                    'other device offers from aliv?',
                    style: MifiAltContactStyles.bodyText,
                  ),
                ),
                MifiMarketingRadioRow(
                  label: 'yes',
                  selected: marketingOptIn == true,
                  onTap: busy ? null : () => onMarketingChanged(true),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE6E8F2),
                ),
                MifiMarketingRadioRow(
                  label: 'no',
                  selected: marketingOptIn == false,
                  onTap: busy ? null : () => onMarketingChanged(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
