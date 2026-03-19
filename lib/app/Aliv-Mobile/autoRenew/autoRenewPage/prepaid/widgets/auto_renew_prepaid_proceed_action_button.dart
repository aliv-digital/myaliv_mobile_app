import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/appConfig/app_ui_config_cubit.dart';
import '../theme/auto_renew_prepaid_theme.dart';

class AutoRenewPrepaidProceedActionButton extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const AutoRenewPrepaidProceedActionButton({
    super.key,
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  // ==================== Button Layout ====================
  // Keep primary action visuals consistent across the flow.
  @override
  Widget build(BuildContext context) {
    final isPostpaid = context.watch<AppUiConfigCubit>().state.isPostpaid;

    return SizedBox(
      height: AutoRenewPrepaidTheme.primaryButtonHeight,
      width: double.infinity,
      child: ElevatedButton(
        style: AutoRenewPrepaidTheme.primaryPillButtonStyle(
          backgroundColor: AutoRenewPrepaidTheme.primaryActionColor(
            enabled: isEnabled,
          ),
        ),
        onPressed: isEnabled ? onPressed : null,
        child: _buildButtonChild(isPostpaid: isPostpaid),
      ),
    );
  }

  // ==================== Button Child ====================
  // Show spinner during submission, otherwise render call-to-action text.
  Widget _buildButtonChild({required bool isPostpaid}) {
    if (isLoading) {
      return const SizedBox(
        width: AutoRenewPrepaidTheme.loaderSize,
        height: AutoRenewPrepaidTheme.loaderSize,
        child: CircularProgressIndicator(
          strokeWidth: AutoRenewPrepaidTheme.loaderStrokeWidth,
          color: AutoRenewPrepaidTheme.white,
        ),
      );
    }

    return Text(
      _resolveButtonText(isPostpaid: isPostpaid),
      style: AutoRenewPrepaidTheme.primaryButtonTextStyle,
    );
  }

  // ==================== Button Label ====================
  // Keep label decision centralized to avoid duplicate conditional text logic.
  String _resolveButtonText({required bool isPostpaid}) {
    return isPostpaid ? 'use for auto pay' : 'proceed';
  }
}
