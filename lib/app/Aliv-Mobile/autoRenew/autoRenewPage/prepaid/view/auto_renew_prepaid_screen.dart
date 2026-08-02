import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import '../../shared/auto_pay_selection_resolver.dart';
import '../bloc/auto_renew_prepaid_bloc.dart';
import '../bloc/auto_renew_prepaid_event.dart';
import '../bloc/auto_renew_prepaid_state.dart';
import '../models/auto_renew_prepaid_models.dart';
import '../repository/auto_renew_prepaid_repository.dart';
import '../widgets/auto_renew_prepaid_page_content.dart';
import '../widgets/auto_renew_prepaid_state_listener.dart';

class AutoRenewPrepaidScreen extends StatelessWidget {
  const AutoRenewPrepaidScreen({super.key});

  // ==================== Screen Composition ====================
  // Provide feature dependencies once at the screen boundary.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: _createAutoRenewPrepaidBloc),
        BlocProvider.value(value: instance<SavedCardsCubit>()),
        BlocProvider.value(value: instance<DeviceLimitsCubit>()),
      ],
      child: const _AutoRenewPrepaidView(),
    );
  }

  // ==================== Bloc Factory ====================
  // Keep bloc creation isolated to simplify future dependency injection.
  AutoRenewPrepaidBloc _createAutoRenewPrepaidBloc(BuildContext context) {
    final AutoRenewPrepaidRepository autoRenewPrepaidRepository =
        AutoRenewPrepaidRepositoryImpl();

    final AutoRenewPrepaidBloc autoRenewPrepaidBloc = AutoRenewPrepaidBloc(
      repository: autoRenewPrepaidRepository,
    );

    autoRenewPrepaidBloc.add(const AutoRenewPrepaidStarted());
    instance<SavedCardsCubit>()
        .fetchSavedCards(forceRefresh: true, userType: UserType.prepaid);

    // Balance API is keyed by DeviceID (from /Account/devices), not the user's
    // account id. Passing the wrong id makes the API return 0 and clobbers the
    // shared BalanceCubit. Mirror the home_screen order: load devices, then
    // read deviceId, then fetch balance.
    _refreshBalanceWithDeviceId();

    return autoRenewPrepaidBloc;
  }

  Future<void> _refreshBalanceWithDeviceId() async {
    final deviceLimitsCubit = instance<DeviceLimitsCubit>();
    await deviceLimitsCubit.loadDeviceLimits();
    final deviceId = deviceLimitsCubit.state.deviceLimits?.deviceId ?? 0;
    if (deviceId <= 0) return;
    await instance<BalanceCubit>().loadBalances(deviceAccountId: deviceId);
  }
}

class _AutoRenewPrepaidView extends StatefulWidget {
  const _AutoRenewPrepaidView();

  @override
  State<_AutoRenewPrepaidView> createState() => _AutoRenewPrepaidViewState();
}

class _AutoRenewPrepaidViewState extends State<_AutoRenewPrepaidView> {
  bool _seededFromServer = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SavedCardsCubit, SavedCardsState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status ||
              prev.cards != curr.cards ||
              prev.autoRenewToken != curr.autoRenewToken,
          listener: (context, _) => _trySeed(context),
        ),
        // The prepaid bloc emits its own `ready` state with a default
        // `selectedMethodId` after it loads its mock cards. If that emit
        // arrives after the SavedCards-driven seed, it would overwrite our
        // selection — so we also listen here and re-seed once the bloc
        // reaches `ready`.
        BlocListener<AutoRenewPrepaidBloc, AutoRenewPrepaidState>(
          listenWhen: (prev, curr) => prev.loadStatus != curr.loadStatus,
          listener: (context, _) => _trySeed(context),
        ),
        // Device limits owns the authoritative `autoRenew` flag.
        BlocListener<DeviceLimitsCubit, DeviceLimitsState>(
          listenWhen: (prev, curr) =>
              prev.hasDeviceLimits != curr.hasDeviceLimits ||
              prev.autoRenew != curr.autoRenew,
          listener: (context, _) => _trySeed(context),
        ),
      ],
      child: const AutoRenewPrepaidStateListener(
        child: AutoRenewPrepaidPageContent(),
      ),
    );
  }

  void _trySeed(BuildContext context) {
    if (_seededFromServer) return;

    final savedCardsState = context.read<SavedCardsCubit>().state;
    final bloc = context.read<AutoRenewPrepaidBloc>();
    final blocState = bloc.state;
    final deviceLimitsState = context.read<DeviceLimitsCubit>().state;

    // Wait until all three inputs are stable before seeding.
    if (!savedCardsState.isSuccess) return;
    if (blocState.loadStatus != AutoRenewLoadStatus.ready) return;
    if (!deviceLimitsState.hasDeviceLimits) return;

    final autoRenewOn = deviceLimitsState.autoRenew;

    final selection = AutoPaySelectionResolver.resolve(
      autoEnabled: autoRenewOn,
      serverToken: savedCardsState.autoRenewToken,
      savedCards: savedCardsState.cards,
      walletAvailable: true,
    );

    switch (selection) {
      case SelectSavedCard(card: final card):
        bloc.add(AutoRenewSavedCardSelected(card));
      case SelectNoAutoRenew():
        bloc.add(
          AutoRenewMethodSelected(AutoRenewPaymentMethod.none.id),
        );
      case SelectPayFromWallet():
        bloc.add(
          AutoRenewMethodSelected(AutoRenewPaymentMethod.wallet.id),
        );
    }
    _seededFromServer = true;
  }
}
