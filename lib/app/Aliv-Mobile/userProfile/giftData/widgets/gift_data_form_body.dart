import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/cubit/gift_data_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/cubit/gift_data_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/gift_data_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/amount_options_grid.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/available_data_chip.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/gift_amount_options_grid_skeleton.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/info_banner.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/recipient_phone_field.dart';
import 'package:myaliv_mobile_app/core/utils/bahamas_phone_formatter.dart';

/// Scrollable form shown while `GiftDataStatus` is `ready` / `submitting` /
/// `success`. Pure composition — all state transitions live in the cubit; the
/// screen hosts side-effects (toast, navigation, keyboard dismissal).
class GiftDataFormBody extends StatelessWidget {
  const GiftDataFormBody({
    super.key,
    required this.state,
    required this.recipientController,
    required this.confirmRecipientController,
    required this.onContinue,
  });

  final GiftDataState state;
  final TextEditingController recipientController;
  final TextEditingController confirmRecipientController;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
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
          if (state.hasShareStatus) ...[
            const SizedBox(height: GiftDataTheme.labelToInputGap),
            AvailableDataChip(
              amountLabel: formatGb(state.shareStatus!.availableToShow),
            ),
            const SizedBox(height: 5),
            InfoBanner(
              text:
                  'until ${DateFormat('MMMM dd, yyyy').format(state.shareStatus!.dataShareEndDate!)}'
                  ' you can gift up to ${formatGb(state.shareStatus!.dataAmountSendLimit)}',
            ),
          ],
          const SizedBox(height: GiftDataTheme.sectionGap),
          const Text(
            'please enter an active prepaid number to gift data',
            style: GiftDataTheme.sectionLabel,
          ),
          const SizedBox(height: GiftDataTheme.labelToInputGap),
          RecipientPhoneField(
            controller: recipientController,
            onChanged: (v) => context.read<GiftDataCubit>().recipientChanged(v),
          ),
          const SizedBox(height: GiftDataTheme.sectionGap),
          const Text(
            'confirm mobile number',
            style: GiftDataTheme.sectionLabel,
          ),
          const SizedBox(height: GiftDataTheme.labelToInputGap),
          RecipientPhoneField(
            controller: confirmRecipientController,
            enableCountryPicker: false,
            onChanged: (v) =>
                context.read<GiftDataCubit>().confirmRecipientChanged(v),
          ),
          if (state.isCheckingRecipient) ...[
            const SizedBox(height: GiftDataTheme.sectionGap),
            const Text('choose gift amount', style: GiftDataTheme.sectionLabel),
            const SizedBox(height: GiftDataTheme.labelToInputGap),
            const GiftAmountOptionsGridSkeleton(),
          ] else if (state.amountOptions.isNotEmpty) ...[
            const SizedBox(height: GiftDataTheme.sectionGap),
            const Text('choose gift amount', style: GiftDataTheme.sectionLabel),
            const SizedBox(height: GiftDataTheme.labelToInputGap),
            AmountOptionsGrid(
              options: state.amountOptions,
              selected: state.selectedAmount,
              isEnabled: state.isAmountEnabled,
              onSelected: (option) =>
                  context.read<GiftDataCubit>().amountSelected(option),
            ),
          ],
          if (state.isRecipientComplete &&
              !state.isCheckingRecipient &&
              state.maxGiftableGb != null) ...[
            const SizedBox(height: GiftDataTheme.sectionGap),
            InfoBanner(
              bordered: true,
              text:
                  '${BahamasPhoneFormatter.format(state.recipient)}'
                  ' can receive up to ${formatGb(state.maxGiftableGb!)}',
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
              onPressed: state.isFormValid && !state.isSubmitting
                  ? onContinue
                  : null,
              child: state.isSubmitting
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
