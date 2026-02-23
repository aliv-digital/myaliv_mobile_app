import 'package:flutter/material.dart';
import '../theme/top_up_prepaid_theme.dart';

class TopUpPrepaidPrimaryButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const TopUpPrepaidPrimaryButton({
    super.key,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: TopUpPrepaidTheme.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        onPressed: (!enabled || loading) ? null : onTap,
        child: loading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : Text('top-up now', style: TopUpPrepaidTheme.buttonText()),
      ),
    );
  }
}
