import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import '../../../../../../resources/widgets/default_app_bar.dart';
import '../../../../../../router/app_routes.dart';
import '../bloc/rev_prepaid_bloc.dart';
import '../bloc/rev_prepaid_event.dart';
import '../bloc/rev_prepaid_state.dart';
import '../repository/rev_prepaid_repository_impl.dart';
import '../theme/rev_prepaid_theme.dart';
import '../widgets/rev_amount_field.dart';
import '../widgets/rev_app_bar_sliver.dart';
import '../widgets/rev_labeled_section.dart';
import '../widgets/rev_name_with_submit_field.dart';
import '../widgets/rev_primary_button.dart';
import '../widgets/rev_readonly_field.dart';
import '../widgets/rev_text_field.dart';

class RevPrepaidScreen extends StatelessWidget {
  const RevPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RevPrepaidBloc(repository: RevPrepaidRepositoryImpl())
            ..add(const RevPrepaidStarted()),
      child: const _RevPrepaidView(),
    );
  }
}

class _RevPrepaidView extends StatelessWidget {
  const _RevPrepaidView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RevPrepaidBloc, RevPrepaidState>(
      listenWhen: (p, c) => p.navTarget != c.navTarget,
      listener: (context, state) {
        if (state.navTarget != RevNavTarget.none) {
          // navigation hook kept (pattern)
          context.read<RevPrepaidBloc>().add(const RevNavigationConsumed());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: RevPrepaidTheme.bg,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: RevAppBarSliver(
                    height: RevPrepaidTheme.appBarHeight,
                    child: DefaultAppBar(
                      title: state.title,
                      height: RevPrepaidTheme.appBarHeight,
                      backgroundColor: RevPrepaidTheme.appBarBg,
                      showBackArrow: true,
                      centerTitle: false,
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    RevPrepaidTheme.contentHorizontalPadding,
                    RevPrepaidTheme.contentTopPadding,
                    RevPrepaidTheme.contentHorizontalPadding,
                    RevPrepaidTheme.contentBottomPadding,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RevLabeledSection(
                          label: 'service',
                          child: RevReadonlyField(text: state.service),
                        ),
                        const SizedBox(height: RevPrepaidTheme.sectionVerticalGap),
                        RevLabeledSection(
                          label: 'Account Number',
                          child: RevTextField(
                            value: state.accountNumber,
                            hintText: 'enter number',
                            keyboardType: TextInputType.number,
                            onChanged: (v) => context
                                .read<RevPrepaidBloc>()
                                .add(RevAccountNumberChanged(v)),
                          ),
                        ),

                        const SizedBox(height: RevPrepaidTheme.sectionVerticalGap),

                        RevLabeledSection(
                          label: 'Name',
                          child: RevNameWithSubmitField(
                            value: state.name,
                            hintText: 'enter name',
                            canSubmit: state.canSubmit,
                            submitting: state.submitting,
                            onChanged: (v) => context
                                .read<RevPrepaidBloc>()
                                .add(RevNameChanged(v)),
                            onSubmit: () => context.read<RevPrepaidBloc>().add(
                              const RevSubmitPressed(),
                            ),
                          ),
                        ),

                        const SizedBox(height: RevPrepaidTheme.sectionVerticalGap),

                        RevLabeledSection(
                          label: 'Account Status',
                          child: RevReadonlyField(
                            text: state.accountStatusText,
                          ),
                        ),

                        const SizedBox(height: RevPrepaidTheme.sectionVerticalGap),

                        Text('amount due', style: RevPrepaidTheme.fieldTitle),
                        const SizedBox(height: RevPrepaidTheme.labelToFieldGap),
                        Text(
                          state.accountBalanceText,
                          style: TextStyle(
                            fontFamily: RevPrepaidTheme.fontFamily,
                            fontSize: 14,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                            color: HexColor.fromHex('#707070'),
                          ),
                        ), //style: RevPrepaidTheme.value),
                        const SizedBox(height: RevPrepaidTheme.sectionVerticalGap),
                        RevLabeledSection(
                          label: 'enter a custom amount',
                          child: RevAmountField(
                            value: state.amountInputText,
                            onChanged: (v) => context
                                .read<RevPrepaidBloc>()
                                .add(RevAmountChanged(v)),
                          ),
                        ),
                        const SizedBox(height: RevPrepaidTheme.proceedButtonTopGap),
                        RevPrimaryButton(
                          text: 'proceed',
                          enabled: state.canProceed,
                          onTap: () {
                            context.read<RevPrepaidBloc>().add(
                              const RevProceedPressed(),
                            );
                            context.push(
                              AppRoutes.revConfirmationPrepaidScreen,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
