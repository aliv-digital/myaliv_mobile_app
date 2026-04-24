import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import '../../theme/top_up_prepaid_theme.dart';
import '../../view/auto_renew_authorization_screen.dart';
import 'auto_topup_sections.dart';
import 'auto_topup_widgets.dart';

/// Auto top-up configuration tab.
///
/// Allows users to set up automatic top-up when balance falls below threshold.
class AutoTopupTab extends StatefulWidget {
  const AutoTopupTab({super.key});

  @override
  State<AutoTopupTab> createState() => _AutoTopupTabState();
}

class _AutoTopupTabState extends State<AutoTopupTab> {
  bool _anyTimeEnabled = true;
  int? _selectedAmount = 15;
  SavedCardModel? _selectedCard;

  /// Controller for the custom amount input field.
  final _customAmountController = TextEditingController();

  /// Tracks if custom amount has a value.
  bool get _hasCustomAmount => _customAmountController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    context.read<SavedCardsCubit>().fetchSavedCards();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  /// Called when custom amount text changes.
  void _onCustomAmountChanged(String value) {
    setState(() {
      if (value.isNotEmpty) {
        // Custom amount entered - clear preset selection
        _selectedAmount = null;
      }
    });
  }

  /// Called when a preset amount is selected.
  void _onPresetAmountSelected(int amount) {
    setState(() {
      _selectedAmount = amount;
      // Clear custom amount when preset is selected
      _customAmountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onCardSelected: (card) => setState(() => _selectedCard = card),
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
  }

  Widget _buildConfigSection() {
    return IgnorePointer(
      ignoring: !_anyTimeEnabled,
      child: Opacity(
        opacity: _anyTimeEnabled ? 1 : 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AutoTopupThresholdSection(),
            const SizedBox(height: 26),
            AutoTopupAmountSection(
              selectedAmount: _selectedAmount,
              onAmountSelected: _onPresetAmountSelected,
              enabled: !_hasCustomAmount,
            ),
            const SizedBox(height: 16),
            const AutoTopupOrDivider(),
            const SizedBox(height: 16),
            AutoTopupCustomAmountSection(
              controller: _customAmountController,
              onChanged: _onCustomAmountChanged,
            ),
            const SizedBox(height: 32),
            AutoTopupApplyButton(
              enabled: _anyTimeEnabled,
              onPressed: _onApply,
            ),
          ],
        ),
      ),
    );
  }

  void _onApply() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AutoRenewAuthorizationScreen(),
      ),
    );
  }
}
