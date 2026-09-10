import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/save_card_on_receipt_section.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/save_new_card_on_receipt_section.dart';
import 'package:myaliv_mobile_app/core/utils/app_session.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/user_profile_receipt_bloc.dart';
import '../bloc/user_profile_receipt_event.dart';
import '../bloc/user_profile_receipt_state.dart';
import '../models/user_profile_receipt_route_args.dart';
import '../repository/user_profile_receipt_repository.dart';
import '../theme/user_profile_receipt_theme.dart';
import '../widgets/user_profile_receipt_success_card.dart';

class UserProfileReceiptScreen extends StatelessWidget {
  final UserProfileReceiptRouteArgs args;

  const UserProfileReceiptScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => UserProfileReceiptRepository(),
      child: BlocProvider(
        create: (ctx) => UserProfileReceiptBloc(
          repository: ctx.read<UserProfileReceiptRepository>(),
        )..add(UserProfileReceiptStarted(args)),
        child: _UserProfileReceiptView(
          cardToSave: args.cardToSave,
          orderId: args.orderId,
        ),
      ),
    );
  }
}

class _UserProfileReceiptView extends StatelessWidget {
  const _UserProfileReceiptView({required this.cardToSave, this.orderId});

  final NewCardDetails? cardToSave;
  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserProfileReceiptBloc, UserProfileReceiptState>(
      listenWhen: (previous, current) =>
          previous.backHomeRequestId != current.backHomeRequestId,
      listener: (context, state) {
        if (state.backHomeRequestId == 0) return;

        // Clear legacy top-up flags before leaving this reusable receipt.
        AppSession.resetAppRoute();
        AppSession.resetFlagForTopUp();
        context.go(AppRoutes.home);
      },
      child: Scaffold(
        backgroundColor: UserProfileReceiptTheme.screenBackground,
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DefaultAppBar(
                  backgroundColor: UserProfileReceiptTheme.appBarColor,
                  showBackArrow: false,
                  title: '   my receipt',
                  onBack: () {},
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 29, 24, 30),
                  child:
                      BlocBuilder<
                        UserProfileReceiptBloc,
                        UserProfileReceiptState
                      >(
                        builder: (context, state) {
                          final data = state.data;
                          if (data == null) return const SizedBox.shrink();

                          return UserProfileReceiptSuccessCard(
                            data: data,
                            onBackHome: () {
                              context.read<UserProfileReceiptBloc>().add(
                                const UserProfileReceiptBackHomePressed(),
                              );
                            },
                            saveCardSection: orderId != null
                                ? SaveNewCardOnReceiptSection(
                                    orderId: orderId!,
                                  )
                                : SaveCardOnReceiptSection(
                                    details: cardToSave,
                                  ),
                          );
                        },
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
