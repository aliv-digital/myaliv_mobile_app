import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/add_or_edit_cards_prepaid_bloc.dart';
import '../bloc/add_or_edit_cards_prepaid_event.dart';
import '../bloc/add_or_edit_cards_prepaid_state.dart';
import '../model/add_or_edit_cards_prepaid_models.dart';
import '../theme/add_or_edit_cards_prepaid_theme.dart';
import '../widgets/bottomsheet/add_card_bottom_sheet.dart';
import '../widgets/bottomsheet/confirm_remove_card_bottom_sheet.dart';
import '../widgets/dashed_add_card_button.dart';
import '../widgets/payment_method_section.dart';

class AddOrEditCardsPrepaidScreen extends StatefulWidget {
  const AddOrEditCardsPrepaidScreen({super.key});

  @override
  State<AddOrEditCardsPrepaidScreen> createState() =>
      _AddOrEditCardsPrepaidScreenState();
}

class _AddOrEditCardsPrepaidScreenState
    extends State<AddOrEditCardsPrepaidScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SavedCardsCubit>().fetchSavedCards();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AddOrEditCardsPrepaidBloc()..add(const AddOrEditCardsPrepaidStarted()),
      child: const _AddOrEditCardsPrepaidView(),
    );
  }
}

class _AddOrEditCardsPrepaidView extends StatelessWidget {
  const _AddOrEditCardsPrepaidView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddOrEditCardsPrepaidBloc, AddOrEditCardsPrepaidState>(
      listenWhen: (p, c) =>
      p.errorMessage != c.errorMessage || p.navTarget != c.navTarget,
      listener: (context, state) async {
        final bloc = context.read<AddOrEditCardsPrepaidBloc>();
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }

        // ✅ Handle one-shot navigation targets
        if (state.navTarget == AddOrEditCardsPrepaidNavTarget.addCard) {
          // Demo অনুযায়ী last4 "1234" (repo তেও ending 1234)
          final result = await AddCardBottomSheet.show(
            context,
            last4: '1234',
          );

          if (result != null) {
            bloc.add(
              AddOrEditCardsPrepaidSaveCardPressed(
                month: result.month,
                year: result.year,
              ),
            );
          }

          bloc.add(const AddOrEditCardsPrepaidNavigationConsumed());
          return;
        }

        if (state.navTarget == AddOrEditCardsPrepaidNavTarget.home) {
          // TODO: integrate router/go_router for home navigation
          bloc.add(const AddOrEditCardsPrepaidNavigationConsumed());
          return;
        }
      },
      child: Scaffold(
        backgroundColor: AddOrEditCardsPrepaidTheme.pageBg,
        body: SafeArea(
          child: BlocBuilder<AddOrEditCardsPrepaidBloc, AddOrEditCardsPrepaidState>(
            builder: (context, state) {
              final bloc = context.read<AddOrEditCardsPrepaidBloc>();

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: AddOrEditCardsPrepaidTheme.primary,
                    elevation: 0,
                    centerTitle: false,
                    leading: IconButton(
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 24.0),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    title: const Text(
                      'add/edit cards',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: IconButton(
                          onPressed: () {

                            context.go(AppRoutes.home);
                          },

                          icon:
                           SvgPicture.asset('assets/icons/home.svg',color: Colors.white,),
                        ),
                      ),
                    ],
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 18),
                    sliver: SliverToBoxAdapter(
                      child: BlocBuilder<SavedCardsCubit, SavedCardsState>(
                        builder: (context, savedCardsState) {
                          if (savedCardsState.isLoading &&
                              !savedCardsState.hasCards) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final mappedCards = savedCardsState.cards
                              .map(_savedCardModelToSavedCard)
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PaymentMethodSection(
                                cards: mappedCards,
                                deletingIds: state.deletingIds,
                                onDelete: (id) async {
                                  final confirmed =
                                      await RemoveSavedCardConfirmBottomSheet
                                          .show(context);
                                  if (confirmed) {
                                    bloc.add(
                                      AddOrEditCardsPrepaidDeletePressed(id),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                              DashedAddCardButton(
                                onTap: () {
                                  bloc.add(
                                    const AddOrEditCardsPrepaidAddNewCardPressed(),
                                  );
                                },
                              ),
                            ],
                          );
                        },
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

SavedCard _savedCardModelToSavedCard(SavedCardModel model) {
  return SavedCard(
    id: model.token,
    brand: CardBrand.unknown,
    ending: model.lastDigits,
    expiry: '',
  );
}
