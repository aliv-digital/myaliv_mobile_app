import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';

import '../bloc/make_payment_postpaid_bloc.dart';
import '../bloc/make_payment_postpaid_event.dart';
import '../bloc/make_payment_postpaid_state.dart';
import '../repository/make_payment_postpaid_repository_impl.dart';
import '../theme/make_payment_postpaid_theme.dart';
import '../widgets/mp_content_body.dart';
import '../widgets/mp_header.dart';
import '../widgets/mp_pay_bottom_bar.dart';
import 'make_payment_postpaid_side_effects.dart';

/// Postpaid make-payment flow. This screen only wires the bloc and page
/// shell; all rendering, gestures, and side-effects live in dedicated
/// files so each concern can evolve independently:
///
/// - [MpHeader] / [MpContentBody] / [MpPayBottomBar] — UI sections.
/// - `MakePaymentPostPaidPayFlow` — pay-now → sheet → dispatch confirmation.
/// - [MakePaymentPostPaidSideEffects] — toast + one-shot receipt navigation.
/// - `resolveMpAmountToCharge` — shared amount computation.
class MakePaymentPostPaidScreen extends StatelessWidget {
  const MakePaymentPostPaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MakePaymentPostPaidBloc>(
      create: (_) {
        final bloc = MakePaymentPostPaidBloc(
          repository: MakePaymentPostPaidRepositoryImpl(),
        );
        bloc.add(const MakePaymentPostPaidStarted());
        instance<SavedCardsCubit>().fetchSavedCards();
        return bloc;
      },
      child: const _MakePaymentPostPaidPage(),
    );
  }
}

class _MakePaymentPostPaidPage extends StatelessWidget {
  const _MakePaymentPostPaidPage();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MakePaymentPostPaidBloc, MakePaymentPostPaidState>(
      listenWhen: (previous, current) =>
          previous.navTarget != current.navTarget ||
          previous.errorMessage != current.errorMessage ||
          previous.status != current.status,
      listener: MakePaymentPostPaidSideEffects.onState,
      builder: (context, state) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: Scaffold(
          backgroundColor: MakePaymentPostPaidTheme.bg,
          bottomNavigationBar: MpPayBottomBar(state: state),
          body: Column(
            children: [
              MpHeader(title: state.title),
              Expanded(child: MpContentBody(state: state)),
            ],
          ),
        ),
      ),
    );
  }
}
