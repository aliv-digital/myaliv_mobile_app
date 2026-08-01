import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/add_or_edit_cards_prepaid_bloc.dart';
import '../bloc/add_or_edit_cards_prepaid_event.dart';
import '../bloc/add_or_edit_cards_prepaid_state.dart';
import '../model/add_or_edit_cards_prepaid_models.dart';
import '../theme/add_or_edit_cards_prepaid_theme.dart';
import '../widgets/bottomsheet/add_card_details_bottom_sheet.dart';
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
    return MultiBlocListener(
      listeners: [
        BlocListener<SavedCardsCubit, SavedCardsState>(
          listenWhen: (p, c) =>
              p.errorMessage != c.errorMessage && c.errorMessage != null,
          listener: (context, state) {
            final msg = state.errorMessage;
            if (msg != null && msg.isNotEmpty) {
              AppToast.show(message: msg, type: ToastType.error);
            }
          },
        ),
        BlocListener<AddOrEditCardsPrepaidBloc, AddOrEditCardsPrepaidState>(
          listenWhen: (p, c) =>
              p.errorMessage != c.errorMessage || p.navTarget != c.navTarget,
          listener: _onLocalBlocStateChanged,
        ),
      ],
      child: _buildScaffold(context),
    );
  }

  Future<void> _onLocalBlocStateChanged(
    BuildContext context,
    AddOrEditCardsPrepaidState state,
  ) async {
    final bloc = context.read<AddOrEditCardsPrepaidBloc>();
    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      AppToast.show(message: state.errorMessage!, type: ToastType.error);
    }

    if (state.navTarget == AddOrEditCardsPrepaidNavTarget.addCard) {
      final details = await AddCardDetailsBottomSheet.show(context);

      if (!context.mounted) return;
      bloc.add(const AddOrEditCardsPrepaidNavigationConsumed());
      if (details == null) return;

      final added = await context.read<SavedCardsCubit>().addCard(details);
      if (!context.mounted || !added) return;

      AppToast.show(
        message: 'your card has been added successfully',
        type: ToastType.success,
      );
      return;
    }

    if (state.navTarget == AddOrEditCardsPrepaidNavTarget.home) {
      bloc.add(const AddOrEditCardsPrepaidNavigationConsumed());
      return;
    }
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: AddOrEditCardsPrepaidTheme.pageBg,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AddOrEditCardsPrepaidTheme.primary,
              elevation: 0,
              centerTitle: false,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: ColorManager.primaryPurple,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
              leading: IconButton(
                icon: const Padding(
                  padding: EdgeInsets.only(left: 24.0),
                  child: Icon(Icons.arrow_back, color: Colors.white),
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
                    onPressed: () => context.go(AppRoutes.home),
                    icon: SvgPicture.asset(
                      'assets/icons/home.svg',
                      color: Colors.white,
                    ),
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
                        child: Center(child: CircularProgressIndicator()),
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
                          deletingIds: savedCardsState.removingTokens,
                          onDelete: (id) => _onDeletePressed(context, id),
                        ),
                        const SizedBox(height: 20),
                        DashedAddCardButton(
                          isLoading: savedCardsState.isAddingCard,
                          onTap: () => context
                              .read<AddOrEditCardsPrepaidBloc>()
                              .add(
                                const AddOrEditCardsPrepaidAddNewCardPressed(),
                              ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onDeletePressed(BuildContext context, String token) async {
    final confirmed = await RemoveSavedCardConfirmBottomSheet.show(context);
    if (!confirmed) return;
    if (!context.mounted) return;

    final cubit = context.read<SavedCardsCubit>();
    await cubit.removeCard(token);

    if (!context.mounted) return;
    if (cubit.state.errorMessage == null) {
      AppToast.show(
        message: 'your card has been saved successfully removed',
        type: ToastType.success,
      );
    }
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
