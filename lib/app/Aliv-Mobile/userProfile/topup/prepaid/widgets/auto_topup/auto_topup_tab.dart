import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
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

  bool get _hasCustomAmount => _customAmountController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    context.read<SavedCardsCubit>().fetchSavedCards();
    instance<DeviceLimitsCubit>().loadDeviceLimits();
  }

  @override
  void dispose() {
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
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          32 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoTopupCardSection(
              selectedCard: _selectedCard,
              onCardSelected: (c) => setState(() => _selectedCard = c),
            ),
            const SizedBox(height: 20),
            AutoTopupAnyTimeToggle(
              value: _anyTimeEnabled,
              onChanged: (v) => setState(() => _anyTimeEnabled = v),
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
            onChanged: (_) => setState(() {}),
            minThreshold: _minThreshold,
          ),
          const SizedBox(height: 26),
          AutoTopupAmountSection(
            selectedAmount: _selectedAmount,
            onAmountSelected: (v) => setState(() {
              _selectedAmount = v;
              _customAmountController.clear();
            }),
            enabled: !_hasCustomAmount,
          ),
          const SizedBox(height: 16),
          const AutoTopupOrDivider(),
          const SizedBox(height: 16),
          AutoTopupCustomAmountSection(
            controller: _customAmountController,
            onChanged: (v) {
              if (v.isNotEmpty) setState(() => _selectedAmount = null);
            },
          ),
          const SizedBox(height: 32),
          AutoTopupApplyButton(enabled: _anyTimeEnabled, onPressed: _onApply),
        ],
      ),
    ),
  );

  void _onApply() {
    FocusManager.instance.primaryFocus?.unfocus();

    final threshold =
        double.tryParse(_thresholdController.text) ?? _minThreshold;

    // Custom amount has priority
    final amount = _hasCustomAmount
        ? double.tryParse(_customAmountController.text)
        : _selectedAmount?.toDouble();
    if (amount == null || amount <= 0) {
      _showError('Please select or enter an amount');
      return;
    }

    // Use selected card token, or existing token from API, or empty string
    final cardToken =
        _selectedCard?.token ??
        instance<DeviceLimitsCubit>().state.autoTopUpCardToken;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AutoTopUpAuthorizationScreen(
          balanceThreshold: threshold,
          autoTopUpAmount: amount,
          cardToken: cardToken,
          cardLastDigits: _selectedCard?.lastDigits ?? '',
        ),
      ),
    );
  }

  void _showError(String msg) {
    AppToast.show(message: msg,type: ToastType.error);
  }
}
