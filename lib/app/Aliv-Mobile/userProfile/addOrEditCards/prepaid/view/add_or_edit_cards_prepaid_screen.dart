import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_or_edit_cards_prepaid_bloc.dart';
import '../bloc/add_or_edit_cards_prepaid_event.dart';
import '../bloc/add_or_edit_cards_prepaid_state.dart';
import '../theme/add_or_edit_cards_prepaid_theme.dart';
import '../widgets/dashed_add_card_button.dart';
import '../widgets/payment_method_section.dart';
import '../widgets/bottomsheet/add_card_bottom_sheet.dart';

class AddOrEditCardsPrepaidScreen extends StatelessWidget {
  const AddOrEditCardsPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddOrEditCardsPrepaidBloc()
        ..add(const AddOrEditCardsPrepaidStarted()),
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

        /// ✅ Add Card BottomSheet open
        if (state.navTarget == AddOrEditCardsPrepaidNavTarget.addCard) {
          // one-shot: consume first (avoid double open on rebuild)
          bloc.add(const AddOrEditCardsPrepaidNavigationConsumed());

          final result = await AddCardBottomSheet.show(
            context,
            last4: '1234',
          );

          if (result != null) {
            bloc.add(AddOrEditCardsPrepaidSaveCardPressed(
              month: result.month,
              year: result.year,
            ));
          }
        }

        /// ✅ Home nav (router connect later)
        if (state.navTarget == AddOrEditCardsPrepaidNavTarget.home) {
          bloc.add(const AddOrEditCardsPrepaidNavigationConsumed());
          // TODO: go_router navigation
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
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                      IconButton(
                        onPressed: () => bloc.add(const AddOrEditCardsPrepaidHomePressed()),
                        icon: const Icon(Icons.home_outlined, color: Colors.white),
                      ),
                    ],
                  ),

                  if (state.loadStatus == AddOrEditCardsPrepaidLoadStatus.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PaymentMethodSection(
                              cards: state.cards,
                              deletingIds: state.deletingIds,
                              onDelete: (id) =>
                                  bloc.add(AddOrEditCardsPrepaidDeletePressed(id)),
                            ),
                            const SizedBox(height: 18),

                            //  show loading state while saving new card
                            Stack(
                              children: [
                                DashedAddCardButton(
                                  onTap: () => bloc.add(
                                    const AddOrEditCardsPrepaidAddNewCardPressed(),
                                  ),
                                ),
                                if (state.savingNewCard)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.55),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
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
