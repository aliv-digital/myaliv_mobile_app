import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import '../bloc/guest_purchase_plan_bloc.dart';
import '../bloc/guest_purchase_plan_event.dart';
import '../bloc/guest_purchase_plan_state.dart';
import '../repository/guest_purchase_plan_repository.dart';
import '../widgets/plan_card.dart';
import '../widgets/plan_tabs.dart';



class GuestPurchasePlanScreen extends StatelessWidget {
  const GuestPurchasePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return BlocProvider(
      create: (_) => GuestPurchasePlanBloc(
          GuestPurchasePlanRepository())..add(
          GuestPurchasePlanStarted()
      ),
      child: const _GuestPurchasePlanView(),
    );
  }
}

class _GuestPurchasePlanView extends StatelessWidget {
  const _GuestPurchasePlanView();

  static const Color _topBar = Color(0xFF5D5A8B);
  static const Color _bg = Color(0xFFF6F6F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            DefaultAppBar(
                title: 'plans',
                onBack: (){
                  context.pop();
                }
            ),
            // _TopBar(
            //   title: 'plans',
            //   onBack: () => Navigator.of(context).maybePop(),
            // ),
            BlocBuilder<GuestPurchasePlanBloc, GuestPurchasePlanState>(
              buildWhen: (p, c) => p.selectedTab != c.selectedTab,
              builder: (context, state) {
                return PlanTabs(
                  selected: state.selectedTab,
                  onChanged: (tab) => context
                      .read<GuestPurchasePlanBloc>()
                      .add(GuestPurchasePlanTabChanged(tab)),
                );
              },
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.only(top: 24,bottom: 15,left: 31),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'choose a prepaid monthly primary plan',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: BlocBuilder<GuestPurchasePlanBloc, GuestPurchasePlanState>(
                builder: (context, state) {
                  if (state.status == GuestPurchasePlanStatus.loading ||
                      state.status == GuestPurchasePlanStatus.initial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == GuestPurchasePlanStatus.failure) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Something went wrong',
                        style: const TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 14),
                    itemCount: state.plans.length,
                    itemBuilder: (context, index) {
                      final plan = state.plans[index];
                      final expanded = state.expandedPlanIds.contains(plan.id);

                      return PlanCard(
                        plan: plan,
                        expanded: expanded,
                        onToggle: () => context.read<GuestPurchasePlanBloc>()
                            .add(GuestPurchasePlanToggleExpanded(plan.id)),

                        // ✅ view details চাপলেও expand/collapse হবে (buttons always visible)
                        onViewDetails: () => context.read<GuestPurchasePlanBloc>()
                            .add(GuestPurchasePlanToggleExpanded(plan.id)),

                        onPurchaseNow: () {
                          context.read<GuestPurchasePlanBloc>()
                              .add(GuestPurchasePlanPurchaseNowPressed(plan));
                          // navigate purchase flow here
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.onBack,
  });

  static const Color _topBar = Color(0xFF5D5A8B);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: _topBar,
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(22),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
