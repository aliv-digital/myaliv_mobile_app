import 'package:flutter/material.dart';

import '../top_up_prepaid_number_postpaid_amount_box.dart';

class TopUpPrepaidNumberPostPaidAmountSection extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const TopUpPrepaidNumberPostPaidAmountSection({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TopUpPrepaidNumberPostPaidAmountBox(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
