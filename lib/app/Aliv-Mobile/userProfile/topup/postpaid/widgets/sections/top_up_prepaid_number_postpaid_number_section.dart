import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/top_up_prepaid_number_postpaid_theme.dart';

class TopUpPrepaidNumberPostPaidNumberSection extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const TopUpPrepaidNumberPostPaidNumberSection({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('enter number to top up', style: TopUpPrepaidNumberPostPaidTheme.label()),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          decoration: TopUpPrepaidNumberPostPaidTheme.fieldDecoration(hintText: 'eg: 2428999999'),
        ),
      ],
    );
  }
}
