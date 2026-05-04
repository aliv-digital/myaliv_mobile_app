import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/repository/auto_renew_auth_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/theme/auto_renew_prepaid_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/widgets/auto_renew_payment_method_section.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/widgets/auto_renew_prepaid_proceed_action_button.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/widgets/dashed_add_card_button.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/addOrEditCards/prepaid/widgets/bottomsheet/add_card_bottom_sheet.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class AutoPayPostpaidScreen extends StatelessWidget {
  const AutoPayPostpaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: instance<SavedCardsCubit>(),
      child: const _AutoPayPostpaidView(),
    );
  }
}

class _AutoPayPostpaidView extends StatefulWidget {
  const _AutoPayPostpaidView();

  @override
  State<_AutoPayPostpaidView> createState() => _AutoPayPostpaidViewState();
}

class _AutoPayPostpaidViewState extends State<_AutoPayPostpaidView> {
  SavedCardModel? _selectedCard;

  @override
  void initState() {
    super.initState();
    instance<SavedCardsCubit>().fetchSavedCards();
  }

  bool get _canProceed => _selectedCard != null;

  void _onProceed() {
    final card = _selectedCard;
    if (card == null) return;
    context.push(
      AppRoutes.autoRenewAuthPrepaidScreen,
      extra: AutoRenewAuthArgs(
        paymentMethod: AutoRenewPaymentMethodType.postpaidInvoice,
        cardToken: card.token,
      ),
    );
  }

  Future<void> _onAddCard() async {
    await AddCardBottomSheet.show(context, last4: '1234');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AutoRenewPrepaidTheme.pageBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedHeaderDelegate(
                height: AutoRenewPrepaidTheme.appBarHeight,
                child: DefaultAppBar(
                  showHome: true,
                  title: 'auto pay',
                  onBack: () => Navigator.of(context).maybePop(),
                  onHomeTap: () => context.go(AppRoutes.home),
                ),
              ),
            ),
            SliverPadding(
              padding: AutoRenewPrepaidTheme.bodyPadding,
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoRenewPaymentMethodSection(
                      selectedCard: _selectedCard,
                      onCardSelected: (c) =>
                          setState(() => _selectedCard = c),
                      showWalletRow: false,
                    ),
                    const SizedBox(
                      height: AutoRenewPrepaidTheme.sectionToDashedGap,
                    ),
                    DashedAddCardButton(onTap: _onAddCard),
                    const SizedBox(
                      height: AutoRenewPrepaidTheme.dashedToActionGap,
                    ),
                    AutoRenewPrepaidProceedActionButton(
                      isEnabled: _canProceed,
                      isLoading: false,
                      onPressed: _onProceed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  const _PinnedHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
