import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/enable_auto_payment_sheet.dart';
import 'package:myaliv_mobile_app/app/Home/balance/view/balance_amount_text.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class PostpaidBillingCard extends StatelessWidget {
  const PostpaidBillingCard({super.key});

  static const Color purple = Color(0xFF645D9C);
  static const Color border = Color(0xFFE6E6EE);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountInfoCubit, AccountInfoState>(
      bloc: instance<AccountInfoCubit>(),
      buildWhen: (previous, current) =>
          previous.autoPayInvoice != current.autoPayInvoice ||
          previous.isTogglingAutoPayInvoice != current.isTogglingAutoPayInvoice,
      builder: (context, state) {
        return _PostpaidBillingCardContent(
          autoPayEnabled: state.autoPayInvoice,
          isLoading: state.isTogglingAutoPayInvoice,
        );
      },
    );
  }
}

class _PostpaidBillingCardContent extends StatefulWidget {
  const _PostpaidBillingCardContent({
    required this.autoPayEnabled,
    required this.isLoading,
  });

  final bool autoPayEnabled;
  final bool isLoading;

  @override
  State<_PostpaidBillingCardContent> createState() =>
      _PostpaidBillingCardContentState();
}

class _PostpaidBillingCardContentState
    extends State<_PostpaidBillingCardContent> {
  late bool _localValue;

  static const Color purple = Color(0xFF645D9C);
  static const Color border = Color(0xFFE6E6EE);

  @override
  void initState() {
    super.initState();
    _localValue = widget.autoPayEnabled;
  }

  @override
  void didUpdateWidget(covariant _PostpaidBillingCardContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoPayEnabled != oldWidget.autoPayEnabled) {
      _localValue = widget.autoPayEnabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= AUTO PAY ROW =================
            Row(
              children: [
                Text(
                  'auto pay',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.32,
                  ),
                ),
                const Spacer(),
                Opacity(
                  opacity: widget.isLoading ? 0.6 : 1.0,
                  child: _FigmaToggle(
                    value: _localValue,
                    onChanged: widget.isLoading ? null : _onChanged,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ================= BALANCE DUE =================
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/wallet.svg'),
                const SizedBox(width: 14),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'balance due',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w600,
                          height: 1.18,
                          letterSpacing: 0.06,
                        ),
                      ),
                      Text(
                        'payment is due the 15th of each\nmonth',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          height: 1.30,
                          letterSpacing: 0.06,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount (wallet balance shown as "balance due" for postpaid)
                const BalanceAmountText(type: BalanceType.wallet),
              ],
            ),

            // ================= PAY NOW BUTTON (hidden when auto-pay is ON) =================
            if (!_localValue) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push(
                      AppRoutes.makePaymentConfirmationPostpaidScreen,
                    );
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/card-add.svg',
                    height: 18,
                    width: 18,
                  ),
                  label: const Text(
                    'pay now',
                    style: TextStyle(
                      color: Color(0xFFF1F1F8),
                      fontSize: 15,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _onChanged(bool value) async {
    if (value) {
      // Toggle OFF → ON: Show bottom sheet to navigate to auth screen
      setState(() => _localValue = true);
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => const EnableAutoPaymentSheet(),
      ).then((_) {
        // Revert if bottom sheet dismissed without enabling
        if (mounted) {
          setState(() => _localValue = widget.autoPayEnabled);
        }
      });
    } else {
      // Toggle ON → OFF: confirm via bottom sheet before hitting the disable API.
      final confirmed = await showModalBottomSheet<bool>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (_) => const DisableAutoPayBottomSheet(),
      );
      if (!mounted) return;
      if (confirmed != true) {
        setState(() => _localValue = widget.autoPayEnabled);
        return;
      }

      setState(() => _localValue = false);

      final success =
          await instance<AccountInfoCubit>().disableAutoPayInvoice();

      if (!success && mounted) {
        setState(() => _localValue = true);
        AppToast.show(
          message: 'Failed to disable auto-pay',
          type: ToastType.error,
        );
      } else if (success) {
        AppToast.show(
          message: 'your account will not auto pay',
          type: ToastType.success,
        );
      }
    }
  }
}

class _FigmaToggle extends StatelessWidget {
  final bool value;
  final void Function(bool)? onChanged;

  const _FigmaToggle({required this.value, required this.onChanged});

  static const double _width = 55;
  static const double _height = 28;
  static const double _knobSize = 24;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _width,
        height: _height,
        padding: EdgeInsets.only(left: value ? 10 : 3, right: value ? 3 : 10),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF645D9C) : Color(0xFF979797),
          borderRadius: BorderRadius.circular(35.71),
          border: value
              ? null
              : Border.all(width: 0.71, color: const Color(0xFFE2E2E2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: value
              ? [
                  /// ON TEXT
                  const SizedBox(
                    width: 12,
                    child: Text(
                      'On',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFE4E0FF),
                        fontSize: 8,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  /// KNOB
                  _knob(),
                ]
              : [
                  /// KNOB
                  _knob(withShadow: true),

                  /// OFF TEXT
                  const SizedBox(
                    width: 14,
                    child: Text(
                      'Off',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white, //Color(0xFFF4F4F4),
                        fontSize: 8,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
        ),
      ),
    );
  }

  static Widget _knob({bool withShadow = false}) {
    return Container(
      width: _knobSize,
      height: _knobSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: withShadow
            ? [
                const BoxShadow(
                  color: Color(0x25000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
    );
  }
}
