import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

import '../../PlanScreen/view/start_plan_bottom_sheet.dart';
import '../bloc/home_plans_postpaid_bloc.dart';
import '../bloc/home_plans_postpaid_event.dart';
import '../bloc/home_plans_postpaid_state.dart';
import '../repository/home_plans_postpaid_repository.dart';
import '../widgets/home_plans_postpaid_plan_card.dart';

class HomePlansPostPaidScreen extends StatelessWidget {
  const HomePlansPostPaidScreen({super.key});

  static const Color purple = Color(0xFF645D9C);
  static const Color bg = Color(0xFFF1F1FA);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => HomePlansPostPaidRepository(
        networkService: instance<NetworkService>(),
        authManager: instance<AuthManager>(),
      ),
      child: BlocProvider(
        create: (ctx) => HomePlansPostPaidBloc(
          repository: ctx.read<HomePlansPostPaidRepository>(),
        )..add(const HomePlansPostPaidStarted()),
        child: const _HomePlansPostPaidView(),
      ),
    );
  }
}

class _HomePlansPostPaidView extends StatelessWidget {
  const _HomePlansPostPaidView();

  void _showStartPlanBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const StartPlanBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomePlansPostPaidBloc, HomePlansPostPaidState>(
      listenWhen: (previous, current) {
        return previous.pendingToast?.id != current.pendingToast?.id;
      },
      listener: (context, state) {
        final toast = state.pendingToast;
        if (toast == null) {
          return;
        }

        AppToast.show(
          message: toast.message,
          type: ToastType.error,
        );
        context.read<HomePlansPostPaidBloc>().add(
              const HomePlansPostPaidToastConsumed(),
            );
      },
      child: Scaffold(
        backgroundColor: HomePlansPostPaidScreen.bg,
        appBar: AppBar(
          backgroundColor: HomePlansPostPaidScreen.purple,
          elevation: 0,
          centerTitle: false,
          title: const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              'roaming data add-ons',
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<HomePlansPostPaidBloc, HomePlansPostPaidState>(
            builder: (context, state) {
              if (state.status == HomePlansPostPaidStatus.loading ||
                  state.status == HomePlansPostPaidStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == HomePlansPostPaidStatus.failure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      state.errorMessage ?? 'Something went wrong',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(24),
                children: <Widget>[
                  const Text(
                    'choose a roaming data add-on. these add-ons will only work in the usa, canada and or digicel caribbean countries.',
                    style: TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...state.plans.map((plan) {
                    if(plan.planName.toLowerCase().contains("test")){
                      return SizedBox.shrink(); // to avoid demo data
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: HomePlansPostPaidPlanCard(
                        plan: plan,
                        expanded: state.isExpanded(plan.planId),
                        onToggle: () {
                          context.read<HomePlansPostPaidBloc>().add(
                                HomePlansPostPaidToggleExpanded(plan.planId),
                              );
                        },
                        onPurchaseNow: () => _showStartPlanBottomSheet(context),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
