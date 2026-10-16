import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/common/verification/account_action_otp_navigation.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verification_coordinator.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verified_result.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../logic/auto_top_up_validation.dart';
import '../../theme/top_up_prepaid_theme.dart';
import '../../view/auto_top_up_authorization_screen.dart';
import 'auto_topup_amount_grid.dart';
import 'auto_topup_sections.dart';
import 'auto_topup_widgets.dart';

class AutoTopupTab extends StatefulWidget {
  const AutoTopupTab({super.key});

  @override
  State<AutoTopupTab> createState() => _AutoTopupTabState();
}

class _AutoTopupTabState extends State<AutoTopupTab> {
  bool _anyTimeEnabled = true;
  int? _selectedAmount;
  SavedCardModel? _selectedCard;
  final _thresholdController = TextEditingController();
  final _customAmountController = TextEditingController();
  bool _initialValuesSet = false;
  double _minThreshold = 0;

  /// ATOP-001 inline error; cleared as soon as a card is selected.
  String? _cardError;

  /// ATOP-002 threshold and ATOP-003/004/005 amount inline errors; each
  /// clears as soon as its own field is edited.
  String? _thresholdError;
  String? _amountError;

  /// Guards against overlapping taps of "apply" while an OTP request is open.
  bool _applying = false;

  /// Lazily created on the first "apply" tap so screens that never trigger
  /// an OTP (e.g. toggle-only tests) don't require OTP-related singletons.
  ActionVerificationCoordinator<ProtectedAccountAction>? _verification;

  bool get _hasCustomAmount => _customAmountController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    context.read<SavedCardsCubit>().fetchSavedCards();
    instance<DeviceLimitsCubit>().loadDeviceLimits();
  }

  @override
  void dispose() {
    _verification?.cancel();
    _thresholdController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  void _initFromDeviceLimits(DeviceLimitsState state) {
    if (_initialValuesSet || !state.hasDeviceLimits) return;
    _initialValuesSet = true;
    _minThreshold = state.balanceThreshold.abs();
    if (_minThreshold > 0)
      _thresholdController.text = _minThreshold.toInt().toString();
    final amount = state.autoTopUpAmount.abs().toInt();
    if (AutoTopupAmountGrid.presetAmounts.contains(amount))
      _selectedAmount = amount;
  }

  void _matchCard(SavedCardsState cardsState, String token) {
    if (_selectedCard != null || !cardsState.hasCards || token.isEmpty) return;
    final match = cardsState.cards.firstWhere(
      (c) => c.token == token,
      orElse: () => cardsState.cards.first,
    );
    setState(() => _selectedCard = match);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = instance<DeviceLimitsCubit>();
    return BlocListener<SavedCardsCubit, SavedCardsState>(
      listener: (_, state) {
        if (state.hasCards) _matchCard(state, cubit.state.autoTopUpCardToken);
      },
      child: StreamBuilder<DeviceLimitsState>(
        stream: cubit.stream,
        initialData: cubit.state,
        builder: (_, snap) {
          final deviceState = snap.data ?? cubit.state;
          if (deviceState.isLoaded && !_initialValuesSet) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _initFromDeviceLimits(deviceState));
              _matchCard(
                context.read<SavedCardsCubit>().state,
                deviceState.autoTopUpCardToken,
              );
            });
          }
          return _buildBody();
        },
      ),
    );
  }

  Widget _buildBody() => Scaffold(
    backgroundColor: TopUpPrepaidTheme.pageBg,
    resizeToAvoidBottomInset: true,
    body: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          32 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoTopupCardSection(
              selectedCard: _selectedCard,
              onCardSelected: (c) => setState(() {
                _selectedCard = c;
                _cardError = null;
              }),
              errorText: _cardError,
              onAddNewCard: _onAddNewCard,
            ),
            const SizedBox(height: 20),
            AutoTopupAnyTimeToggle(
              value: _anyTimeEnabled,
              onChanged: _onAnyTimeChanged,
            ),
            const SizedBox(height: 20),
            _buildConfigSection(),
          ],
        ),
      ),
    ),
  );

  Widget _buildConfigSection() => IgnorePointer(
    ignoring: !_anyTimeEnabled,
    child: Opacity(
      opacity: _anyTimeEnabled ? 1 : 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoTopupThresholdSection(
            controller: _thresholdController,
            onChanged: (_) => setState(() => _thresholdError = null),
            minThreshold: _minThreshold,
            errorText: _thresholdError,
          ),
          const SizedBox(height: 26),
          AutoTopupAmountSection(
            selectedAmount: _selectedAmount,
            onAmountSelected: (v) => setState(() {
              _selectedAmount = v;
              _customAmountController.clear();
              _amountError = null;
            }),
            enabled: !_hasCustomAmount,
          ),
          const SizedBox(height: 16),
          const AutoTopupOrDivider(),
          const SizedBox(height: 16),
          AutoTopupCustomAmountSection(
            controller: _customAmountController,
            onChanged: (v) => setState(() {
              if (v.isNotEmpty) _selectedAmount = null;
              _amountError = null;
            }),
          ),
          if (_amountError != null) ...[
            const SizedBox(height: 8),
            Text(_amountError!, style: TopUpPrepaidTheme.amountError()),
          ],
          const SizedBox(height: 32),
          AutoTopupApplyButton(enabled: _anyTimeEnabled, onPressed: _onApply),
        ],
      ),
    ),
  );

  /// OFF → ON keeps the existing immediate local toggle. ON → OFF asks for
  /// confirmation first (ATOP-010) and then shows ATOP-009 feedback.
  ///
  /// This only changes the local toggle; it does not update the backend Auto
  /// Top-up configuration.
  Future<void> _onAnyTimeChanged(bool value) async {
    if (value) {
      setState(() => _anyTimeEnabled = true);
      return;
    }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const AutoTopupTurnOffBottomSheet(),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _anyTimeEnabled = false);
    AppToast.show(
      message: 'auto top-up has been turned off',
      type: ToastType.success,
    );
  }

  Future<void> _onApply() async {
    if (_applying) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final threshold =
        double.tryParse(_thresholdController.text) ?? _minThreshold;

    // ATOP-002: threshold first, shown inline on the threshold helper.
    final thresholdError = validateAutoTopUpThreshold(threshold);
    if (thresholdError != null) {
      setState(() {
        _thresholdError = thresholdError;
        _amountError = null;
        _cardError = null;
      });
      return;
    }

    // Custom amount has priority (ATOP-003/004/005).
    final customAmount = _hasCustomAmount
        ? double.tryParse(_customAmountController.text)
        : null;
    final amountError = validateAutoTopUpAmount(
      customAmount: customAmount,
      presetAmount: _selectedAmount,
    );
    if (amountError != null) {
      setState(() {
        _amountError = amountError;
        _cardError = null;
      });
      return;
    }
    final amount = customAmount ?? _selectedAmount!.toDouble();

    // Use selected card token, or existing token from API, or empty string
    final cardToken =
        _selectedCard?.token ??
        instance<DeviceLimitsCubit>().state.autoTopUpCardToken;

    // ATOP-001: only a loaded list with no selected or existing card counts;
    // loading and load-failure states keep their existing behaviour.
    if (cardToken.isEmpty && context.read<SavedCardsCubit>().state.isSuccess) {
      setState(() => _cardError = 'select a card to continue');
      return;
    }

    final cardLastDigits = _selectedCard?.lastDigits ?? '';
    final attemptId = Object();

    _applying = true;
    final verification = _verification ??=
        ActionVerificationCoordinator<ProtectedAccountAction>();
    ActionVerifiedResult<ProtectedAccountAction>? verified;
    try {
      verified = await requestAccountActionOtp(
        context: context,
        coordinator: verification,
        purpose: ProtectedAccountAction.autoTopUp,
        attemptId: attemptId,
      );
    } on CallLogsVerificationException catch (error) {
      if (mounted) {
        AppToast.show(message: error.message, type: ToastType.error);
      }
      return;
    } catch (_) {
      if (mounted) {
        AppToast.show(
          message: 'Verification failed. Please try again.',
          type: ToastType.error,
        );
      }
      return;
    } finally {
      _applying = false;
    }

    if (!mounted || verified == null || !verified.isValid) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AutoTopUpAuthorizationScreen(
          balanceThreshold: threshold,
          autoTopUpAmount: amount,
          cardToken: cardToken,
          cardLastDigits: cardLastDigits,
          verifiedResult: verified!,
        ),
      ),
    );
  }

  /// Same action as the dropdown's own "add new card" entry.
  Future<void> _onAddNewCard() async {
    await context.push(AppRoutes.addOrEditCardsPrepaidScreen);
    if (!mounted) return;
    context.read<SavedCardsCubit>().refreshSavedCards();
  }
}
