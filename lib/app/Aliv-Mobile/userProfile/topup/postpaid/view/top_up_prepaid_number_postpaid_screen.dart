import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/core/utils/app_session.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/top_up_prepaid_number_postpaid_bloc.dart';
import '../bloc/top_up_prepaid_number_postpaid_event.dart';
import '../bloc/top_up_prepaid_number_postpaid_state.dart';
import '../theme/top_up_prepaid_number_postpaid_theme.dart';

import '../widgets/sections/top_up_prepaid_number_postpaid_number_section.dart';
import '../widgets/sections/top_up_prepaid_number_postpaid_confirm_number_section.dart';
import '../widgets/sections/top_up_prepaid_number_postpaid_amount_section.dart';
import '../widgets/sections/top_up_prepaid_number_postpaid_apply_section.dart';

/// Screen: TopUpPrepaidNumberPostPaid
/// - Uses CustomScrollView
/// - SliverAppBar no padding
/// - Rest content padded via SliverPadding
class TopUpPrepaidNumberPostPaid extends StatelessWidget {
  const TopUpPrepaidNumberPostPaid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TopUpPrepaidNumberPostPaidBloc()
        ..add(const TopUpPrepaidNumberPostPaidStarted()),
      child: const _TopUpPrepaidNumberPostPaidView(),
    );
  }
}

class _TopUpPrepaidNumberPostPaidView extends StatelessWidget {
  const _TopUpPrepaidNumberPostPaidView();

  @override
  Widget build(BuildContext context) {
    if(kDebugMode){
      debugPrint("Screen Name : top-up a prepaid number");
      debugPrint("file name : top_up_prepaid_number_postpaid_screen.dart");
      debugPrint("location : Aliv-Mobile/userProfile/topup/postpaid/view");
    }
    return BlocListener<TopUpPrepaidNumberPostPaidBloc,
        TopUpPrepaidNumberPostPaidState>(
      listenWhen: (p, c) => p.applyStatus != c.applyStatus,
      listener: (context, state) {
        if (state.applyStatus == TopUpPrepaidNumberPostPaidApplyStatus.failure &&
            state.errorMessage != null) {
          AppToast.show(message: state.errorMessage!, type: ToastType.error);
        }
        if (state.applyStatus == TopUpPrepaidNumberPostPaidApplyStatus.success) {
          AppSession.appRoute = 'sendTopUp';
          final amountParam = state.amountValue.toStringAsFixed(2);
          final recipientParam = Uri.encodeQueryComponent(
            state.numberForApi ?? state.number.trim(),
          );
          context.push(
            '${AppRoutes.confirmation}?amount=$amountParam&recipient=$recipientParam',
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white, //TopUpPrepaidNumberPostPaidTheme.pageBg,
        body: SafeArea(
          top: false,
          child: BlocBuilder<TopUpPrepaidNumberPostPaidBloc,
              TopUpPrepaidNumberPostPaidState>(
            builder: (context, state) {
              final bloc = context.read<TopUpPrepaidNumberPostPaidBloc>();

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: TopUpPrepaidNumberPostPaidTheme.primary,
                    elevation: 0,
                    centerTitle: false,
                    systemOverlayStyle: SystemUiOverlayStyle(
                      statusBarColor: ColorManager.primaryPurple,
                      statusBarIconBrightness: Brightness.light,
                      statusBarBrightness: Brightness.dark,
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    title: const Text(
                      'top-up a prepaid number',
                      style: TextStyle(
                        fontFamily: TopUpPrepaidNumberPostPaidTheme.fontFamily,
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (state.loadStatus ==
                      TopUpPrepaidNumberPostPaidLoadStatus.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TopUpPrepaidNumberPostPaidNumberSection(
                              value: state.number,
                              onChanged: (v) => bloc.add(
                                  TopUpPrepaidNumberPostPaidNumberChanged(v)),
                            ),
                            const SizedBox(height: 16),
                            TopUpPrepaidNumberPostPaidConfirmNumberSection(
                              value: state.confirmNumber,
                              onChanged: (v) => bloc.add(
                                  TopUpPrepaidNumberPostPaidConfirmNumberChanged(
                                      v)),
                            ),
                            const SizedBox(height: 18),
                            TopUpPrepaidNumberPostPaidAmountSection(
                              value: state.amountText,
                              onChanged: (v) => bloc.add(
                                  TopUpPrepaidNumberPostPaidAmountChanged(v)),
                            ),
                            const SizedBox(height: 40),
                            TopUpPrepaidNumberPostPaidApplySection(
                              enabled: state.canApply,
                              loading: state.applyStatus == TopUpPrepaidNumberPostPaidApplyStatus.loading,
                              onTap: () => bloc.add(const TopUpPrepaidNumberPostPaidApplyPressed()),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
