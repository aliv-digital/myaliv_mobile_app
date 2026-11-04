import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/model/login_country_selection.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/login_phone_number_helper.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/cubit/gift_data_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/cubit/gift_data_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/gift_data_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/amount_options_grid.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/available_data_chip.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/gift_amount_options_grid_skeleton.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/info_banner.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/gift_data_error_banner.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/recipient_phone_field.dart';
import 'package:myaliv_mobile_app/core/utils/bahamas_phone_formatter.dart';

/// Scrollable form shown while `GiftDataStatus` is `ready` / `submitting` /
/// `success`. Pure composition — all state transitions live in the cubit; the
/// screen hosts side-effects (toast, navigation, keyboard dismissal).
class GiftDataFormBody extends StatefulWidget {
  const GiftDataFormBody({
    super.key,
    required this.state,
    required this.recipientController,
    required this.confirmRecipientController,
    required this.onContinue,
    this.recipientFocusNode,
    this.confirmRecipientFocusNode,
  });

  final GiftDataState state;
  final TextEditingController recipientController;
  final TextEditingController confirmRecipientController;
  final VoidCallback onContinue;
  final FocusNode? recipientFocusNode;
  final FocusNode? confirmRecipientFocusNode;

  @override
  State<GiftDataFormBody> createState() => _GiftDataFormBodyState();
}

class _GiftDataFormBodyState extends State<GiftDataFormBody> {
  FocusNode? _ownedRecipientFocusNode;
  FocusNode? _ownedConfirmFocusNode;

  // Share the screen's nodes with its keyboard toolbar; standalone forms own theirs.
  FocusNode get _recipientFocusNode =>
      widget.recipientFocusNode ??
      (_ownedRecipientFocusNode ??= FocusNode(debugLabel: 'recipientFocus'));
  FocusNode get _confirmFocusNode =>
      widget.confirmRecipientFocusNode ??
      (_ownedConfirmFocusNode ??= FocusNode(debugLabel: 'confirmFocus'));

  static const LoginPhoneNumberHelper _phoneHelper = LoginPhoneNumberHelper(
    requireBahamasAreaCode: true,
  );

  static const LoginCountrySelection _bahamasCountry = LoginCountrySelection(
    isoCode: 'BS',
    dialCode: '1',
    flagEmoji: '🇧🇸',
  );

  @override
  void dispose() {
    _ownedRecipientFocusNode?.dispose();
    _ownedConfirmFocusNode?.dispose();
    super.dispose();
  }

  bool _isPhoneInvalid(String value) {
    return _phoneHelper.hasLiveValidationError(
      rawPhoneNumber: value,
      selectedCountry: _bahamasCountry,
    );
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  @override
  Widget build(BuildContext context) {
    final s = widget.state;

    final bool hasServerRecipientError =
        s.recipientErrorMessage != null && s.recipientErrorMessage!.isNotEmpty;

    // Recipient field (first number input field):
    final bool recipientFormatInvalid = _isPhoneInvalid(s.recipient);
    final bool showRecipientError =
        recipientFormatInvalid || hasServerRecipientError;
    final String? recipientErrorText = recipientFormatInvalid
        ? GiftDataTheme.invalidFormatErrorMessage
        : (hasServerRecipientError ? s.recipientErrorMessage : null);

    // Confirm field validation:
    final bool confirmFormatInvalid = _isPhoneInvalid(s.confirmRecipient);
    final bool confirmMismatch =
        s.confirmRecipient.isNotEmpty &&
        _digitsOnly(s.recipient) != _digitsOnly(s.confirmRecipient);

    final bool showConfirmError =
        confirmFormatInvalid || confirmMismatch || hasServerRecipientError;

    final String? confirmErrorText = confirmFormatInvalid
        ? GiftDataTheme.invalidFormatErrorMessage
        : (confirmMismatch ? GiftDataTheme.phoneMismatchErrorMessage : null);

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        GiftDataTheme.pageHGap,
        24,
        GiftDataTheme.pageHGap,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'give the gift of data this holiday',
            style: GiftDataTheme.sectionLabel,
          ),
          if (s.hasShareStatus) ...[
            const SizedBox(height: GiftDataTheme.labelToInputGap),
            AvailableDataChip(
              amountLabel: formatGb(s.shareStatus!.availableToShow),
            ),
            const SizedBox(height: 5),
            InfoBanner(
              text:
                  'until ${DateFormat('MMMM dd, yyyy').format(s.shareStatus!.dataShareEndDate!)}'
                  ' you can gift up to ${formatGb(s.shareStatus!.dataAmountSendLimit)}',
            ),
          ],
          const SizedBox(height: GiftDataTheme.sectionGap),
          const Text(
            'please enter an active prepaid number to gift data',
            style: GiftDataTheme.sectionLabel,
          ),
          const SizedBox(height: GiftDataTheme.labelToInputGap),
          RecipientPhoneField(
            controller: widget.recipientController,
            focusNode: _recipientFocusNode,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _confirmFocusNode.requestFocus(),
            showError: showRecipientError,
            errorText: recipientErrorText,
            onChanged: (v) => context.read<GiftDataCubit>().recipientChanged(v),
          ),
          const SizedBox(height: GiftDataTheme.sectionGap),
          const Text(
            'confirm mobile number',
            style: GiftDataTheme.sectionLabel,
          ),
          const SizedBox(height: GiftDataTheme.labelToInputGap),
          RecipientPhoneField(
            controller: widget.confirmRecipientController,
            focusNode: _confirmFocusNode,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _confirmFocusNode.unfocus(),
            enableCountryPicker: false,
            showError: showConfirmError,
            errorText: confirmErrorText,
            onChanged: (v) =>
                context.read<GiftDataCubit>().confirmRecipientChanged(v),
          ),
          if (s.isCheckingRecipient) ...[
            const SizedBox(height: GiftDataTheme.sectionGap),
            const Text('choose gift amount', style: GiftDataTheme.sectionLabel),
            const SizedBox(height: GiftDataTheme.labelToInputGap),
            const GiftAmountOptionsGridSkeleton(),
          ] else if (s.amountOptions.isNotEmpty) ...[
            const SizedBox(height: GiftDataTheme.sectionGap),
            const Text('choose gift amount', style: GiftDataTheme.sectionLabel),
            const SizedBox(height: GiftDataTheme.labelToInputGap),
            AmountOptionsGrid(
              options: s.amountOptions,
              selected: s.selectedAmount,
              isEnabled: s.isAmountEnabled,
              onSelected: (option) =>
                  context.read<GiftDataCubit>().amountSelected(option),
            ),
          ],
          if (s.isRecipientComplete &&
              !s.isCheckingRecipient &&
              s.maxGiftableGb != null) ...[
            const SizedBox(height: GiftDataTheme.sectionGap),
            InfoBanner(
              bordered: true,
              text:
                  '${BahamasPhoneFormatter.format(s.recipient)}'
                  ' can receive up to ${formatGb(s.maxGiftableGb!)}',
            ),
          ],
          if (s.isRecipientComplete &&
              !s.isCheckingRecipient &&
              s.hasRecipientErrorBanner) ...[
            const SizedBox(height: GiftDataTheme.sectionGap),
            GiftDataErrorBanner(
              title: s.recipientErrorBannerTitle,
              message: s.recipientErrorBannerMessage,
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: GiftDataTheme.ctaHeight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GiftDataTheme.primaryPurple,
                disabledBackgroundColor: GiftDataTheme.primaryPurple.withValues(
                  alpha: 0.4,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              onPressed: s.isFormValid && !s.isSubmitting
                  ? widget.onContinue
                  : null,
              child: s.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('continue', style: GiftDataTheme.ctaLabel),
            ),
          ),
        ],
      ),
    );
  }
}
