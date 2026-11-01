import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/theme/top_up_prepaid_theme.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/core/appConfig/active_device.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verified_result.dart';
import 'package:myaliv_mobile_app/core/utils/user_display_name.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../verification/auto_top_up_submission.dart';

class AutoTopUpAuthorizationScreen extends StatefulWidget {
  final double balanceThreshold;
  final double autoTopUpAmount;
  final String cardToken;
  final String cardLastDigits;
  final ActionVerifiedResult<ProtectedAccountAction> verifiedResult;

  const AutoTopUpAuthorizationScreen({
    super.key,
    required this.balanceThreshold,
    required this.autoTopUpAmount,
    required this.cardToken,
    required this.cardLastDigits,
    required this.verifiedResult,
  });

  @override
  State<AutoTopUpAuthorizationScreen> createState() =>
      _AutoTopUpAuthorizationScreenState();
}

class _AutoTopUpAuthorizationScreenState
    extends State<AutoTopUpAuthorizationScreen> {
  final _nameController = TextEditingController();
  bool _isSubmitting = false;
  late final AutoTopUpSubmission _submission;

  @override
  void initState() {
    super.initState();
    _submission = AutoTopUpSubmission(
      deviceLimitsCubit: instance<DeviceLimitsCubit>(),
    );
  }

  String get _expectedName => resolveUserDisplayName();

  bool get _isNameValid => _nameController.text == _expectedName;

  @override
  void dispose() {
    _submission.close();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) {
      return;
    }
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter your name.');
      return;
    }
    if (_nameController.text != name ||
        RegExp(r'[^\p{L} ]', unicode: true).hasMatch(name)) {
      _showError("Please check your signature's format and try again.");
      return;
    }
    if (!_isNameValid) {
      _showError(
        'Name does not match. Please enter your name exactly as displayed.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // ATOP-007: read before the update, which refreshes the cubit's state.
    final isNewActivation = !instance<DeviceLimitsCubit>().state.hasAutoTopUp;

    bool? success;
    try {
      final snapshot = AutoTopUpSubmissionSnapshot(
        attemptId: widget.verifiedResult.attemptId,
        deviceId: ActiveDevice.id() ?? 0,
        balanceThreshold: widget.balanceThreshold,
        autoTopUpAmount: widget.autoTopUpAmount,
        cardToken: widget.cardToken,
        signature: name,
      );
      success = await _submission.submit(
        snapshot: snapshot,
        isCurrent: (pending) =>
            mounted &&
            ModalRoute.of(context)?.isCurrent == true &&
            widget.balanceThreshold == pending.balanceThreshold &&
            widget.autoTopUpAmount == pending.autoTopUpAmount &&
            widget.cardToken == pending.cardToken &&
            _nameController.text == pending.signature &&
            _isNameValid,
        verifiedResult: widget.verifiedResult,
      );
    } catch (_) {
      if (mounted) {
        _showError('Failed to update settings. Please try again.');
      }
      return;
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }

    if (!mounted) return;

    if (success == true) {
      AppToast.show(
        // Updates to existing settings keep their current copy.
        message: isNewActivation
            ? 'auto top-up successfully started'
            : "We're working on it! Auto top-up takes a few minutes to update. Thank you for your patience.",
        type: ToastType.success,
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) context.go(AppRoutes.home);
      });
    } else {
      // The one-use OTP capability is now consumed (or the attempt is stale);
      // retrying requires a fresh apply from the Setup tab, so pop back there
      // with an error toast.
      _showError('Failed to update settings. Please try again.');
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
      }
    }
  }

  void _showError(String msg) {
    AppToast.show(message: msg.toString(), type: ToastType.error);
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
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'by providing my credit card ending *${widget.cardLastDigits} as payment method, '
                'I authorize aliv and/or its agents to store my payment method '
                'information and to automatically charge plan renewal costs of '
                'qualifying plans for all subscriber lines on my account. '
                'i am certifying i am the payment method owner or have '
                'authorization to use the payment method information provided '
                'for the automatic charging of plan renewal costs.',
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                  color: Color(0xFF707070),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'electronic communication consent',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: Color(0xFF707070),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'by entering my pin, full name matching the name displayed and '
                'clicking agree, i am providing my electronic signature as '
                'evidence that i understand the terms i am to which i am agreeing. '
                'In addition, i understand this automatic payment authorization '
                'will remain in effect until canceled by me via the myaliv app. '
                'The complete aliv automatic payment policy will be sent to your '
                'account email address.',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                  color: Color(0xFF707070),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _expectedName,
                style: const TextStyle(
                  color: Color(0xFF707070),
                  fontSize: 14,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                  height: 1.43,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'name',
                style: TextStyle(
                  color: Color(0xFF1C1C1C),
                  fontSize: 14,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                  height: 1.43,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: TopUpPrepaidTheme.formInputHeight,
                padding: TopUpPrepaidTheme.formInputHorizontalPadding,
                decoration: BoxDecoration(
                  color: TopUpPrepaidTheme.lightBg,
                  borderRadius: BorderRadius.circular(
                    TopUpPrepaidTheme.formInputRadius,
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  style: const TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hint: const FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'type your name exactly as it appears on your account',
                        style: TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 13,
                          color: Color(0xFF707070),
                        ),
                      ),
                    ),
                  ),
                ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'submit',
                          style: TextStyle(
                            fontFamily: 'CircularPro',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
