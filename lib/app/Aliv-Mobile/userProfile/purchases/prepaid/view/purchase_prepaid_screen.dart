import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../login/widgets/login_bottom_stripes.dart';
import '../bloc/purchase_prepaid_bloc.dart';
import '../bloc/purchase_prepaid_event.dart';
import '../bloc/purchase_prepaid_state.dart';
import '../model/purchase_prepaid_models.dart';
import '../repository/purchase_prepaid_repository.dart';
import '../theme/purchase_prepaid_theme.dart';
import '../widgets/purchase_prepaid_menu_list.dart';

class PurchasesPrepaidScreen extends StatelessWidget {
  const PurchasesPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PurchasePrepaidBloc(
          repo: PurchasePrepaidRepository()
      )..add(const PurchasePrepaidStarted()),
      child: const _PurchasePrepaidView(),
    );
  }
}

class _PurchasePrepaidView extends StatelessWidget {
  const _PurchasePrepaidView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PurchasePrepaidBloc, PurchasePrepaidState>(
      listenWhen: (p, c) => p.navigateTo != c.navigateTo || p.errorMessage != c.errorMessage,
      listener: (context, state) {
        final err = state.errorMessage;
        if (err != null && err.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(err)));
        }

        final nav = state.navigateTo;
        if (nav != null) {
          _handleNavigation(context, nav);
          context.read<PurchasePrepaidBloc>().add(const PurchasePrepaidNavigationConsumed());
        }
      },
      child: Scaffold(
        backgroundColor: PurchasePrepaidTheme.pageBg,
        body: SafeArea(
          child: BlocBuilder<PurchasePrepaidBloc, PurchasePrepaidState>(
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  // App bar as in your project
                  SliverToBoxAdapter(
                    child: DefaultAppBar(
                      title: 'purchases',
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                  ),

                  if (state.status == PurchasePrepaidLoadStatus.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.status == PurchasePrepaidLoadStatus.failure)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(state.errorMessage ?? 'Something went wrong'),
                      ),
                    )
                  else ...[
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 6),
                        sliver: SliverToBoxAdapter(
                          child: PurchasePrepaidMenuList(
                            items: state.items,
                            onTapItem: (item) {
                              context.read<PurchasePrepaidBloc>().add(PurchasePrepaidItemTapped(item.action));
                            },
                          ),
                        ),
                      ),

                      // Bottom stripes pinned feel (like screenshot)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: BottomStripes(),
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

  void _handleNavigation(BuildContext context, PurchasePrepaidAction action) {
    // TODO: integrate GoRouter routes here
    // Example:
    switch (action) {
      case PurchasePrepaidAction.addEditCreditCards:
        context.push(AppRoutes.addOrEditCardsPrepaidScreen);
        break;
      case PurchasePrepaidAction.topUpPrepaidNumber:
        context.push(AppRoutes.topUpPrepaidNumberPostpaidScreen);
        break;
      case PurchasePrepaidAction.buyPlans:
        // TODO: Handle this case.
        break;
      case PurchasePrepaidAction.futurePlans:
        // TODO: Handle this case.
        break;
      case PurchasePrepaidAction.myLimits:
        // TODO: Handle this case.
        break;
      case PurchasePrepaidAction.reviewInvoices:
        context.push(AppRoutes.enterPasswordReviewInvoicePostpaidScreen);
        break;
      case PurchasePrepaidAction.autoRenew:
        context.push(AppRoutes.autoRenewPrepaidScreen);
        break;
      case PurchasePrepaidAction.transactionHistory:
        context.push(AppRoutes.callLogs);
        break;
      case PurchasePrepaidAction.makePayment:
        context.push(AppRoutes.makePaymentConfirmationPostpaidScreen);
        break;
      case PurchasePrepaidAction.topUp:
        context.push(AppRoutes.topUpPrepaidScreen);
        break;
    }
    //   case PurchasePrepaidAction.topUpPrepaidNumber:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case PurchasePrepaidAction.buyPlans:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case PurchasePrepaidAction.futurePlans:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case PurchasePrepaidAction.myLimits:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case PurchasePrepaidAction.reviewInvoices:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case PurchasePrepaidAction.transactionHistory:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case PurchasePrepaidAction.makePayment:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    // }

    // For now: debug
    debugPrint('Navigate to: $action');
  }
}
