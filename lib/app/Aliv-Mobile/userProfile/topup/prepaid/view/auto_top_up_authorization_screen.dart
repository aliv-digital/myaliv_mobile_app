import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/purchases/prepaid/widgets/currency_amount_input.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/theme/top_up_prepaid_theme.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/core/utils/user_display_name.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class AutoTopUpAuthorizationScreen extends StatefulWidget {
  final double balanceThreshold;
  final double autoTopUpAmount;
  final String cardToken;
  final String cardLastDigits;

  const AutoTopUpAuthorizationScreen({
    super.key,
    required this.balanceThreshold,
    required this.autoTopUpAmount,
    required this.cardToken,
    required this.cardLastDigits,
  });

  @override
  State<AutoTopUpAuthorizationScreen> createState() => _AutoTopUpAuthorizationScreenState();
}

class _AutoTopUpAuthorizationScreenState extends State<AutoTopUpAuthorizationScreen> {
  final _nameController = TextEditingController();
  bool _isSubmitting = false;

  String get _expectedName => resolveUserDisplayName();

  bool get _isNameValid => _nameController.text == _expectedName;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter your name.');
      return;
    }
    if (!_isNameValid) {
      _showError('Name does not match. Please enter your name exactly as displayed.');
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await instance<DeviceLimitsCubit>().updateBalanceThresholdSettings(
      balanceThreshold: widget.balanceThreshold,
      autoTopUpAmount: widget.autoTopUpAmount,
      cardToken: widget.cardToken,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      AppToast.show(
        message: "We're working on it! Auto top-up takes a few minutes to update. Thank you for your patience.",
        type: ToastType.success,
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) context.go(AppRoutes.home);
      });
    } else {
      _showError('Failed to update settings. Please try again.');
    }
  }

  void _showError(String msg) {
    AppToast.show(message: msg.toString(),type: ToastType.error);
    //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: TopUpPrepaidTheme.purple,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: TopUpPrepaidTheme.purple,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'auto top-up authorization form',
          style: TextStyle(color: Colors.white, fontSize: 17, fontFamily: 'CircularPro', fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'by providing my credit card ending *${widget.cardLastDigits} as payment method, '
              'I authorize ALIV and/or its agents to store my payment method '
              'information and to automatically charge plan renewal costs of '
              'qualifying plans for all subscriber lines on my account. '
              'I am certifying I am the payment method owner or have '
              'authorization to use the payment method information provided '
              'for the automatic charging of plan renewal costs.',
              style: TextStyle(fontFamily: 'CircularPro', fontSize: 14, height: 1.5, color: Color(0xFF707070)),
            ),
            const SizedBox(height: 12),
            const Text(
              'electronic communication consent',
              style: TextStyle(fontFamily: 'CircularPro', fontSize: 16, fontWeight: FontWeight.w700, height: 1.25, color: Color(0xFF707070)),
            ),
            const SizedBox(height: 12),
            const Text(
              'by entering my pin, full name matching the name displayed and '
              'clicking agree, I am providing my electronic signature as '
              'evidence that I understand the terms I am agreeing. '
              'In addition, I understand this automatic payment authorization '
              'will remain in effect until canceled by me via the myALIV app. '
              'The complete ALIV automatic payment policy will be sent to your '
              'account email address.',
              style: TextStyle(fontFamily: 'CircularPro', fontSize: 14, height: 1.5, color: Color(0xFF707070)),
            ),
            const SizedBox(height: 24),
            Text(_expectedName, style: const TextStyle(fontSize: 14, fontFamily: 'CircularPro', fontWeight: FontWeight.w700, height: 1.43)),
            const SizedBox(height: 24),
            const Text('name', style: TextStyle(color: Color(0xFF1C1C1C), fontSize: 14, fontFamily: 'CircularPro', fontWeight: FontWeight.w700, height: 1.43)),
            const SizedBox(height: 8),
            TopUpFormInputField(
              hint: 'type your name exactly as it appears on your account',
              fitHint: true,
              isAmountType: false,
              controller: _nameController,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TopUpPrepaidTheme.purple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('submit', style: TextStyle(fontFamily: 'CircularPro', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
