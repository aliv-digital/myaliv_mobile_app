import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/bahamas_phone_input_formatter.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/cubit/gift_data_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/cubit/gift_data_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/gift_data_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/repository/gift_data_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/available_data_chip.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/confirm_gift_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/gift_amount_option_chip.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/gift_amount_options_grid_skeleton.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/gift_info_banner.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/recipient_receive_banner.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/core/utils/bahamas_phone_formatter.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class GiftDataScreen extends StatelessWidget {
  const GiftDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GiftDataCubit(
        repository: instance<GiftDataRepository>(),
        accountInfoCubit: instance<AccountInfoCubit>(),
        deviceLimitsCubit: instance<DeviceLimitsCubit>(),
      )..load(),
      child: const _GiftDataView(),
    );
  }
}

class _GiftDataView extends StatefulWidget {
  const _GiftDataView();

  @override
  State<_GiftDataView> createState() => _GiftDataViewState();
}

class _GiftDataViewState extends State<_GiftDataView> {
  final _recipientController = TextEditingController();
  final _confirmRecipientController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _confirmRecipientController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final cubit = context.read<GiftDataCubit>();
    final state = cubit.state;
    if (!state.isFormValid) return;

    final sent = await ConfirmGiftBottomSheet.show(
      context,
      amountLabel: state.selectedAmount!.label,
      availableLabel: formatMb(state.remainingAfterGiftMb ?? 0),
      recipient: state.recipient,
      onConfirm: () async {
        final ref = await cubit.submit();
        if (ref == null && cubit.state.errorMessage != null) {
          AppToast.show(
            message: cubit.state.errorMessage!,
            type: ToastType.error,
          );
        }
        return ref != null;
      },
    );

    if (!mounted || !sent) return;

    final latest = cubit.state;
    final now = DateTime.now();

    context.pushReplacement(
      AppRoutes.giftDataReceipt,
      extra: <String, dynamic>{
        'recipientNumber': latest.recipient,
        'orderReference': latest.orderReference ?? '',
        'dateText': DateFormat('MMM d, yyyy').format(now),
        'timeText': DateFormat('h:mm a').format(now).toLowerCase(),
        'totalDataLabel': formatMb(latest.availableToShowMb ?? 0),
        'remainingDataLabel': formatMb(latest.remainingAfterGiftMb ?? 0),
        'dataGiftedLabel': latest.selectedAmount?.label ?? '',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GiftDataCubit, GiftDataState>(
      // Dismiss the keyboard the moment the recipient + confirm fields match
      // a 10-digit number, so the chip grid + banner that appear below the
      // confirm field aren't hidden behind the keyboard.
      listenWhen: (prev, curr) =>
          !prev.isRecipientComplete && curr.isRecipientComplete,
      listener: (context, _) => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: GiftDataTheme.pageBg,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              DefaultAppBar(title: 'gift data', showBackArrow: true),
              Expanded(
                child: BlocBuilder<GiftDataCubit, GiftDataState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case GiftDataStatus.initial:
                      case GiftDataStatus.loading:
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      case GiftDataStatus.failure:
                        return _ErrorView(
                          message:
                              state.errorMessage ?? 'something went wrong',
                          onRetry: () =>
                              context.read<GiftDataCubit>().load(),
                        );
                      case GiftDataStatus.ineligible:
                        return _IneligibleView(
                          reason: state.ineligibleReason,
                        );
                      case GiftDataStatus.ready:
                      case GiftDataStatus.submitting:
                      case GiftDataStatus.success:
                        return _FormBody(
                          state: state,
                          recipientController: _recipientController,
                          confirmRecipientController:
                              _confirmRecipientController,
                          onContinue: _handleContinue,
                        );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.state,
    required this.recipientController,
    required this.confirmRecipientController,
    required this.onContinue,
  });

  final GiftDataState state;
  final TextEditingController recipientController;
  final TextEditingController confirmRecipientController;
  final VoidCallback onContinue;

  bool _isAmountEnabled(GiftDataState state, int mb) {
    final cap = state.availableToShowMb;
    if (cap != null && mb > cap) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        GiftDataTheme.pageHGap,
        24.0,
        GiftDataTheme.pageHGap,
        24.0,
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
          ],
          if (state.hasShareStatus) ...[
            const SizedBox(height: 5.0),
            GiftInfoBanner(
              validUntilLabel: DateFormat(
                'MMMM dd, yyyy',
              ).format(state.shareStatus!.dataShareEndDate!),
              senderMaxLabel: formatGb(state.shareStatus!.dataAmountSendLimit),
            ),
          ],
          const SizedBox(height: GiftDataTheme.sectionGap),
          const Text(
            'please enter an active prepaid number to gift data',
            style: GiftDataTheme.sectionLabel,
          ),
          const SizedBox(height: GiftDataTheme.labelToInputGap),
          _RecipientField(
            controller: recipientController,
            onChanged: (v) => context.read<GiftDataCubit>().recipientChanged(v),
          ),
          const SizedBox(height: GiftDataTheme.sectionGap),
          const Text(
            'confirm mobile number',
            style: GiftDataTheme.sectionLabel,
          ),
          const SizedBox(height: GiftDataTheme.labelToInputGap),
          _RecipientField(
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
            _AmountOptionsGrid(
              options: state.amountOptions,
              selected: state.selectedAmount,
              isEnabled: (mb) => _isAmountEnabled(state, mb),
              onSelected: (option) =>
                  context.read<GiftDataCubit>().amountSelected(option),
            ),
          ],
          if (state.isRecipientComplete &&
              !state.isCheckingRecipient &&
              state.maxGiftableGb != null) ...[
            const SizedBox(height: GiftDataTheme.sectionGap),
            RecipientReceiveBanner(
              recipientLabel: BahamasPhoneFormatter.format(state.recipient),
              maxLabel: formatGb(state.maxGiftableGb!),
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

class _RecipientField extends StatelessWidget {
  const _RecipientField({
    required this.controller,
    required this.onChanged,
    this.enableCountryPicker = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enableCountryPicker;

  @override
  Widget build(BuildContext context) {
    return CustomCountryPhoneInputRow(
      hintText: 'eg: (242)-899-9999',
      flagEmoji: '🇧🇸',
      dialCode: '1',
      countryIsoCode: 'BS',
      controller: controller,
      enableCountryPicker: enableCountryPicker,
      showCountryArrow: false,
      keyboardType: TextInputType.phone,
      // Presentation-only: same formatter as the login phone row — formats
      // raw digits into (XXX)-XXX-XXXX as the user types. API client strips
      // non-digits again before POST.
      inputFormatters: const [BahamasPhoneInputFormatter()],
      onChanged: onChanged,
    );
  }
}

/// 3-column × 2-row page of amount chips, with horizontal paging when the
/// catalog exceeds 6 items. Each page fills exactly the available horizontal
/// space (chip width = (pageWidth - 2 * hGap) / 3); additional pages scroll
/// into view via a horizontal `SingleChildScrollView`. Partially filled pages
/// (e.g. 3 items on page 1, bottom row empty) keep chip widths consistent by
/// inserting fixed-width `SizedBox.shrink()` placeholders.
class _AmountOptionsGrid extends StatelessWidget {
  const _AmountOptionsGrid({
    required this.options,
    required this.selected,
    required this.isEnabled,
    required this.onSelected,
  });

  static const int _columns = 3;
  static const int _rows = 2;
  static const int _itemsPerPage = _columns * _rows;
  static const double _hGap = 10;
  static const double _vGap = 10;

  final List<GiftAmountOption> options;
  final GiftAmountOption? selected;
  final bool Function(int amountMb) isEnabled;
  final ValueChanged<GiftAmountOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth;
        final chipWidth = (pageWidth - _hGap * (_columns - 1)) / _columns;
        final pageCount = (options.length / _itemsPerPage).ceil().clamp(
          1,
          1 << 30,
        );
        final canScroll = options.length > _itemsPerPage;

        final children = <Widget>[];
        for (var page = 0; page < pageCount; page++) {
          if (children.isNotEmpty) children.add(const SizedBox(width: _hGap));
          children.add(_buildPage(page, chipWidth, pageWidth));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: canScroll
              ? const ClampingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          child: Row(children: children),
        );
      },
    );
  }

  Widget _buildPage(int page, double chipWidth, double pageWidth) {
    final rows = <Widget>[];
    for (var row = 0; row < _rows; row++) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: _vGap));
      final cells = <Widget>[];
      for (var col = 0; col < _columns; col++) {
        if (col > 0) cells.add(const SizedBox(width: _hGap));
        final i = page * _itemsPerPage + row * _columns + col;
        cells.add(SizedBox(width: chipWidth, child: _cell(i)));
      }
      rows.add(Row(children: cells));
    }
    return SizedBox(
      width: pageWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }

  Widget _cell(int index) {
    if (index >= options.length) return const SizedBox.shrink();
    final option = options[index];
    return GiftAmountOptionChip(
      label: option.label,
      selected: selected == option,
      enabled: isEnabled(option.amountMb),
      onTap: () => onSelected(option),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GiftDataTheme.pageHGap),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: GiftDataTheme.sectionLabel,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: GiftDataTheme.ctaHeight,
              width: 180,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GiftDataTheme.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed: onRetry,
                child: const Text('retry', style: GiftDataTheme.ctaLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IneligibleView extends StatelessWidget {
  const _IneligibleView({required this.reason});

  final String? reason;

  @override
  Widget build(BuildContext context) {
    final suffix = (reason == null || reason!.isEmpty) ? '' : '\n($reason)';
    return Padding(
      padding: const EdgeInsets.all(GiftDataTheme.pageHGap),
      child: Center(
        child: Text(
          'this account is not eligible to send a data gift$suffix',
          textAlign: TextAlign.center,
          style: GiftDataTheme.sectionLabel,
        ),
      ),
    );
  }
}
