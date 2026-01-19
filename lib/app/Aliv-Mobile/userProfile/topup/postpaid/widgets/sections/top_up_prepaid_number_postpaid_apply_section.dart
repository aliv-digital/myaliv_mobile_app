import 'package:flutter/material.dart';

import '../../theme/top_up_prepaid_number_postpaid_theme.dart';

class TopUpPrepaidNumberPostPaidApplySection extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const TopUpPrepaidNumberPostPaidApplySection({
    super.key,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = enabled ? TopUpPrepaidNumberPostPaidTheme.primary : TopUpPrepaidNumberPostPaidTheme.primary.withOpacity(0.45);

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        onPressed: enabled && !loading ? onTap : null,
        child: loading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Text(
          'apply',
          style: TextStyle(
            fontFamily: TopUpPrepaidNumberPostPaidTheme.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
