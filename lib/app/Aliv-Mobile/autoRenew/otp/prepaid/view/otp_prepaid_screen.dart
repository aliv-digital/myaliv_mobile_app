import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../login/widgets/login_bottom_stripes.dart';
import '../bloc/otp_prepaid_bloc.dart';
import '../bloc/otp_prepaid_state.dart';
import '../repository/otp_prepaid_repository.dart';
import '../theme/otp_prepaid_theme.dart';
import '../widgets/otp_prepaid_bottom_action.dart';
import '../widgets/otp_prepaid_code_fields.dart';
import '../widgets/otp_prepaid_header.dart';

class OtpAutoRenewPrepaidScreen extends StatelessWidget {
  const OtpAutoRenewPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpAutoRenewPrepaidBloc(
        repository: OtpAutoRenewPrepaidRepository(),
      ),
      child: const _OtpAutoRenewPrepaidView(),
    );
  }
}

class _OtpAutoRenewPrepaidView extends StatelessWidget {
  const _OtpAutoRenewPrepaidView();

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: OtpAutoRenewPrepaidTheme.scaffoldBackground,

      // ✅ keep default keyboard behavior (auto resize + auto scroll)
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: BlocListener<OtpAutoRenewPrepaidBloc, OtpAutoRenewPrepaidState>(
          listener: (context, state) {
            // if (state.status == OtpAutoRenewPrepaidStatus.failure &&
            //     state.errorMessage != null) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(content: Text(state.errorMessage!)),
            //   );
            // }

            // success হলে next screen এ যাওয়ার logic এখানে দিতে পারো
            // if (state.status == OtpAutoRenewPrepaidStatus.success) { ... }
          },
          child: Column(
            children: [
              // ---------- Scrollable content ----------
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    const SliverToBoxAdapter(
                      child: OtpAutoRenewPrepaidHeader(),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            OtpAutoRenewPrepaidTheme.contentHorizontalPadding,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height:
                                  OtpAutoRenewPrepaidTheme.topGapBeforeOtpBoxes,
                            ),
                            OtpAutoRenewPrepaidCodeFields(),
                            SizedBox(
                              height: OtpAutoRenewPrepaidTheme
                                  .otpBoxesToBottomActionsGap,
                            ),
                            OtpAutoRenewPrepaidBottomActions(),
                            SizedBox(
                              height: OtpAutoRenewPrepaidTheme
                                  .bottomActionsToScrollEndGap,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Bottom stripes vanish when keyboard opens
              AnimatedSwitcher(
                duration:
                    OtpAutoRenewPrepaidTheme.bottomStripeAnimationDuration,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: isKeyboardOpen
                    ? const SizedBox.shrink()
                    : const BottomStripes(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
