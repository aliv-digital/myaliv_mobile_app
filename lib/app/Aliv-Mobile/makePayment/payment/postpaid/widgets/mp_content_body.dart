import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/widgets/terms_and_conditions_modal.dart';

import '../bloc/make_payment_postpaid_bloc.dart';
import '../bloc/make_payment_postpaid_event.dart';
import '../bloc/make_payment_postpaid_state.dart';
import 'mp_payment_due_card.dart';
import 'mp_payment_method_section.dart';
import 'mp_terms_checkbox.dart';

/// Scrollable body of the make-payment screen. Composes the three stacked
/// sections (amount → terms → payment method) and forwards their events
/// back to the bloc. All spacing constants live here so the layout can be
/// tuned without touching the shell.
class MpContentBody extends StatelessWidget {
  const MpContentBody({super.key, required this.state});

  static const EdgeInsets _contentPadding = EdgeInsets.fromLTRB(29, 24, 29, 22);
  static const double _paymentDueToTermsGap = 14;
  static const double _termsToMethodsGap = 17;
  static const double _bottomScrollSpacer = 90;

  final MakePaymentPostPaidState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MakePaymentPostPaidBloc>();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: _contentPadding,
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _amountCard(bloc),
                const SizedBox(height: _paymentDueToTermsGap),
                _termsRow(context, bloc),
                const SizedBox(height: _termsToMethodsGap),
                _methodSection(bloc),
                const SizedBox(height: _bottomScrollSpacer),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _amountCard(MakePaymentPostPaidBloc bloc) {
    return MpPaymentDueCard(
      amountText: state.paymentDueAmount,
      selectedOption: state.amountOption,
      customAmount: state.customAmount,
      onOptionChanged: (option) => bloc.add(MpAmountOptionChanged(option)),
      onCustomAmountChanged: (text) => bloc.add(MpCustomAmountChanged(text)),
    );
  }

  Widget _termsRow(BuildContext context, MakePaymentPostPaidBloc bloc) {
    return MpTermsCheckbox(
      value: state.termsAccepted,
      onChanged: (accepted) => bloc.add(MpTermsToggled(accepted)),
      onTermsTap: () async {
        await showTermsAndConditionsModal(
          context,
          badgeSize: 48,
          badgeInnerSize: 34,
          badgeCoreSize: 24,
          badgeIconWidth: 16,
          badgeIconHeight: 16,
          closeButtonSize: 30,
        );
      },
    );
  }

  Widget _methodSection(MakePaymentPostPaidBloc bloc) {
    return MpPaymentMethodSection(
      selectedToken: state.selectedMethodToken,
      payWithCardSelected: state.paymentMode == MpPaymentMode.payWithCard,
      onCardSelected: (card) => bloc.add(MpPaymentMethodSelected(card.token)),
      onPayWithCardSelected: () => bloc.add(const MpPayWithCardSelected()),
    );
  }
}
