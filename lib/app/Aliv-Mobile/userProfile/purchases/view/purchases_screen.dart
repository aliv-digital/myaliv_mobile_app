import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
// import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
import '../../../../../core/utils/app_session.dart';
import '../bloc/purchases_bloc.dart';
import '../bloc/purchases_event.dart';
import '../bloc/purchases_state.dart';
import '../model/purchases_models.dart';
import '../repository/purchases_repository.dart';
import '../theme/purchases_theme.dart';
import '../widgets/purchases_menu_list.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isPrepaid = context.read<AppUiConfigCubit>().state.isPrepaid;

    return BlocProvider(
      create: (_) =>
          PurchasesBloc(repo: PurchasesRepository())
            ..add(PurchasesStarted(isPrepaid: isPrepaid)),
      child: const _PurchasesView(),
    );
  }
}

class _PurchasesView extends StatelessWidget {
  const _PurchasesView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PurchasesBloc, PurchasesState>(
      listenWhen: (p, c) =>
          p.navigateTo != c.navigateTo || p.errorMessage != c.errorMessage,
      listener: (context, state) {
        final err = state.errorMessage;
        if (err != null && err.isNotEmpty) {
          AppToast.show(message: err.toString(), type: ToastType.error);
          // ScaffoldMessenger.of(context)
          //   ..hideCurrentSnackBar()
          //   ..showSnackBar(SnackBar(content: Text(err)));
        }

        final nav = state.navigateTo;
        if (nav != null) {
          _handleNavigation(context, nav);
          context.read<PurchasesBloc>().add(
            const PurchasesNavigationConsumed(),
          );
        }
      },
      child: StripedScaffold(
        backgroundColor: PurchasesTheme.pageBg,
        body: SafeArea(
          top: false,
          child: BlocBuilder<PurchasesBloc, PurchasesState>(
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  // App bar as in your project
                  SliverToBoxAdapter(
                    child: DefaultAppBar(
                      title: 'purchases',
                      onBack: () => Navigator.of(context).maybePop(),
                      onHomeTap: () => context.go(AppRoutes.home),
                    ),
                  ),

                  if (state.status == PurchasesLoadStatus.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.status == PurchasesLoadStatus.failure)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          state.errorMessage ?? 'Something went wrong',
                        ),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 6),
                      sliver: SliverToBoxAdapter(
                        child: _AutoPayAwareMenuList(
                          items: state.items,
                          onTap: (item) {
                            context.read<PurchasesBloc>().add(
                              PurchasesItemTapped(item.action),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, PurchasesAction action) {
    final uiConfigCubit = context.read<AppUiConfigCubit>();

    // TODO: integrate GoRouter routes here
    // Example:
    switch (action) {
      case PurchasesAction.addEditCreditCards:
        context.push(AppRoutes.addOrEditCardsPrepaidScreen);
        break;
      case PurchasesAction.topUpPrepaidNumber:
        context.push(AppRoutes.topUpPrepaidNumberPostpaidScreen);
        break;
      case PurchasesAction.buyPlans:
        context.go(AppRoutes.plans);
        break;
      case PurchasesAction.futurePlans:
        uiConfigCubit.showFuturePlansView();
        context.go(AppRoutes.usage);
        break;
      case PurchasesAction.myLimits:
        uiConfigCubit.showMyLimitsView();
        context.go(AppRoutes.usage);
        break;
      case PurchasesAction.reviewInvoices:
        context.push(AppRoutes.reviewInvoicePostPaidScreen);
        break;
      case PurchasesAction.autoRenew:
        context.push(AppRoutes.autoRenewPrepaidScreen);
        break;
      case PurchasesAction.transactionHistory:
        context.push('${AppRoutes.callLogs}?tab=transactions');
        break;
      case PurchasesAction.makePayment:
        context.push(AppRoutes.makePaymentConfirmationPostpaidScreen);
        break;
      // case PurchasesAction.topUp:
      //   context.push(AppRoutes.topUpPrepaidScreen);
      //   break;
      // case PurchasesAction.autoTopUp:
      //   context.push(AppRoutes.topUpPrepaidScreen);
      //   break;
      // case PurchasesAction.sendTopUp:
      //   // TODO: Handle this case.
      //   context.push(AppRoutes.topUpPrepaidScreen);
      //   break;
      case PurchasesAction.topUp:
        context.push('${AppRoutes.topUpPrepaidScreen}?tab=0');
        break;

      case PurchasesAction.autoTopUp:
        context.push('${AppRoutes.topUpPrepaidScreen}?tab=1');
        break;

      case PurchasesAction.sendTopUp:
        context.push('${AppRoutes.topUpPrepaidScreen}?tab=2');
        break;

      case PurchasesAction.addOns:
        AppSession.appRoute = 'addOnsPrepaid';
        // context.read<PlansCubit>().changeTab(HomePlanTab.addOns);
        context.push(AppRoutes.purchaseAddOns);
        // context.go('${AppRoutes.plans}?tab=addOns');
        break;

      case PurchasesAction.autoPay:
        context.push(AppRoutes.autoPayPostpaidScreen);
        break;
    }
    //   case PurchasesAction.topUpPrepaidNumber:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case PurchasesAction.buyPlans:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case PurchasesAction.futurePlans:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case PurchasesAction.myLimits:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case PurchasesAction.reviewInvoices:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case PurchasesAction.transactionHistory:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case PurchasesAction.makePayment:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    // }

    // For now: debug
    debugPrint('Navigate to: $action');
  }
}

class _AutoPayAwareMenuList extends StatelessWidget {
  const _AutoPayAwareMenuList({required this.items, required this.onTap});

  final List<PurchasesMenuItem> items;
  final ValueChanged<PurchasesMenuItem> onTap;

  @override
  Widget build(BuildContext context) {
    if (!instance.isRegistered<AccountInfoCubit>()) {
      return PurchasesMenuList(
        items: items,
        showTopDivider: false,
        onTapItem: onTap,
      );
    }
    return BlocBuilder<AccountInfoCubit, AccountInfoState>(
      bloc: instance<AccountInfoCubit>(),
      buildWhen: (p, c) => p.autoPayInvoice != c.autoPayInvoice,
      builder: (context, acctState) {
        final visibleItems = acctState.autoPayInvoice
            ? items
                  .where((i) => i.action != PurchasesAction.autoPay)
                  .toList()
            : items;
        return PurchasesMenuList(
          items: visibleItems,
          showTopDivider: false,
          onTapItem: onTap,
        );
      },
    );
  }
}

// security => out browser opening
// faq => in app html view
// privacy => in app html view
