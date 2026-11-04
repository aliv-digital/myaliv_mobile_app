import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/model/guest_pay_bill_confirm_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/bahamas_phone_input_formatter.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/login_phone_number_helper.dart';
import 'package:myaliv_mobile_app/app/common/services/balance_currency_formatter_service.dart';
import 'package:myaliv_mobile_app/core/model/line_status.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_submit_row.dart';
import 'package:myaliv_mobile_app/resources/widgets/app_keyboard_toolbar.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../../../../resources/widgets/top_toast.dart';
import '../bloc/guest_pay_bill_bloc.dart';
import '../bloc/guest_pay_bill_event.dart';
import '../bloc/guest_pay_bill_state.dart';
import '../model/guest_pay_bill_models.dart';
import '../theme/guest_pay_bill_theme.dart';
import '../widgets/guest_pay_bill_focused_text_field.dart';
import '../widgets/guest_pay_bill_inline_verify_field.dart';
import '../widgets/guest_pay_bill_pay_with_rev_card.dart';
import '../widgets/guest_pay_bill_primary_submit_button.dart';
import '../widgets/guest_pay_bill_read_only_box.dart';
import '../widgets/guest_pay_bill_required_label.dart';
import '../widgets/guest_pay_bill_service_dropdown.dart';

class GuestPayBillScreen extends StatelessWidget {
  const GuestPayBillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = GuestPayBillBloc();

        // Populate available network when the screen opens.
        bloc.add(const GuestPayBillStarted());

        return bloc;
      },
      child: const _GuestPayBillView(),
    );
  }
}

class _GuestPayBillView extends StatefulWidget {
  const _GuestPayBillView();

  @override
  State<_GuestPayBillView> createState() => _GuestPayBillViewState();
}

class _GuestPayBillViewState extends State<_GuestPayBillView> {
  final FocusNode _mobileFocusNode = FocusNode(
    debugLabel: 'guestPayBillMobile',
  );
  final FocusNode _confirmMobileFocusNode = FocusNode(
    debugLabel: 'guestPayBillConfirmMobile',
  );
  final FocusNode _accountNumberFocusNode = FocusNode(
    debugLabel: 'guestPayBillAccount',
  );
  final FocusNode _nameFocusNode = FocusNode(debugLabel: 'guestPayBillName');
  bool _hasMobileFocus = false;
  bool _hasConfirmMobileFocus = false;
  bool _showEmptyMobileError = false;
  bool _showEmptyConfirmMobileError = false;

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  @override
  void initState() {
    super.initState();
    _mobileFocusNode.addListener(_handleMobileFocusChange);
    _confirmMobileFocusNode.addListener(_handleConfirmMobileFocusChange);
  }

  @override
  void dispose() {
    _mobileFocusNode.removeListener(_handleMobileFocusChange);
    _confirmMobileFocusNode.removeListener(_handleConfirmMobileFocusChange);
    _mobileFocusNode.dispose();
    _confirmMobileFocusNode.dispose();
    _accountNumberFocusNode.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _handleMobileFocusChange() {
    if (_hasMobileFocus == _mobileFocusNode.hasFocus) return;
    setState(() => _hasMobileFocus = _mobileFocusNode.hasFocus);
  }

  void _handleConfirmMobileFocusChange() {
    if (_hasConfirmMobileFocus == _confirmMobileFocusNode.hasFocus) return;
    setState(() => _hasConfirmMobileFocus = _confirmMobileFocusNode.hasFocus);
  }

  GuestPayBillBloc _bloc(BuildContext context) {
    return context.read<GuestPayBillBloc>();
  }

  void _showSnackBar(BuildContext context, String message) {
    AppToast.show(message: message, type: ToastType.error);
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(
    //       message,
    //       style: GuestPayBillTheme.snackBarTextStyle,
    //     ),
    //   ),
    // );
  }

  void _onBlocStateChanged(BuildContext context, GuestPayBillState state) {
    final errorMessage = state.errorMessage;
    if (errorMessage != null && errorMessage.isNotEmpty) {
      _showSnackBar(context, errorMessage);
    }

    if (state.submitStatus == GuestPayBillSubmitStatus.loading) {
      final confirmArgs = _buildConfirmArgs(state);
      context.push(AppRoutes.guestPayBillConfirm, extra: confirmArgs);
    }
  }

  /* PARKED: country picker disabled to match Login screen behavior.
     Keep this opener around for an easy revert if multi-country
     support is restored later.

  void _pickCountry(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      customFlagBuilder: (Country country) {
        final String assetIsoCode = country.countryCode.toUpperCase() == 'AC'
            ? 'sh'
            : country.countryCode.toLowerCase();
        return Image.asset(
          'assets/$assetIsoCode.png',
          package: 'country_pickers',
          width: 26,
          height: 20,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Text(country.flagEmoji,
                style: const TextStyle(fontSize: 18));
          },
        );
      },
      onSelect: (country) {
        final normalizedPhoneCode =
            country.phoneCode.replaceAll(' ', '').split('-').first;

        final bloc = _bloc(context);
        bloc.add(
          GuestPayBillCountryChanged(
            PayBillCountry(
              flagEmoji: country.flagEmoji,
              dialCode: normalizedPhoneCode,
              isoCode: country.countryCode,
            ),
          ),
        );
      },
    );
  }
  */

  void _onServiceChanged(BuildContext context, BillService? service) {
    if (_showEmptyMobileError || _showEmptyConfirmMobileError) {
      setState(() {
        _showEmptyMobileError = false;
        _showEmptyConfirmMobileError = false;
      });
    }
    final bloc = _bloc(context);
    bloc.add(GuestPayBillServiceChanged(service));
  }

  void _onMobileChanged(BuildContext context, String value) {
    if (_showEmptyMobileError) {
      setState(() => _showEmptyMobileError = false);
    }
    final bloc = _bloc(context);
    bloc.add(GuestPayBillMobileChanged(value));
  }

  void _onConfirmMobileChanged(BuildContext context, String value) {
    if (_showEmptyConfirmMobileError) {
      setState(() => _showEmptyConfirmMobileError = false);
    }
    final bloc = _bloc(context);
    bloc.add(GuestPayBillConfirmMobileChanged(value));
  }

  void _onAccountNumberChanged(BuildContext context, String value) {
    final bloc = _bloc(context);
    bloc.add(GuestPayBillAccountNumberChanged(value));
  }

  void _onNameChanged(BuildContext context, String value) {
    final bloc = _bloc(context);
    bloc.add(GuestPayBillNameChanged(value));
  }

  void _onAmountChanged(BuildContext context, String value) {
    final bloc = _bloc(context);
    bloc.add(GuestPayBillAmountChanged(value));
  }

  void _onVerifyPressed(BuildContext context) {
    final bloc = _bloc(context);
    bloc.add(const GuestPayBillVerifyPressed());
  }

  void _onSubmitPressed(BuildContext context) {
    _bloc(context).add(const GuestPayBillSubmitPressed());
  }

  String _money(double amount) {
    return BalanceCurrencyFormatterService.format(amount);
  }

  GuestPayBillConfirmArgs _buildConfirmArgs(GuestPayBillState state) {
    final serviceName = state.selectedService?.label ?? '';
    final identifierLabel = state.isAlivPostpaid
        ? 'phone no.'
        : state.isAlivFibr
        ? 'Acc #'
        : 'account no.';

    final identifierValue = state.isAlivPostpaid
        ? LoginPhoneNumberHelper.formatBahamasNumberForDisplay(
            state.mobileNumber,
          )
        : state.accountNumber.trim();

    return GuestPayBillConfirmArgs(
      serviceName: serviceName,
      identifierLabel: identifierLabel,
      identifierValue: identifierValue,
      amount: state.amountValue,
      fibrAccountId: state.accountInfo?.fibrAccountId,
    );
  }

  List<Widget> _buildAlivPostpaidFields(
    BuildContext context,
    GuestPayBillState state,
  ) {
    final bool isBahamas = state.selectedCountry.isoCode == 'BS';
    final List<TextInputFormatter>? phoneFormatters = isBahamas
        ? const [BahamasPhoneInputFormatter()]
        : null;
    final double mobileErrorLeftPadding =
        60 +
        GuestPayBillTheme.countryPickerToInputGap +
        14; // picker width + gap + first-field input padding
    final double confirmErrorLeftPadding =
        60 +
        GuestPayBillTheme.countryPickerToInputGap +
        16; // picker width + gap + submit-row input container + input padding

    final bool mobileEmpty = _digitsOnly(state.mobileNumber).isEmpty;
    final bool showMobileEmpty = _showEmptyMobileError && mobileEmpty;
    final bool mobileHasError = showMobileEmpty || state.showMobileInvalidError;
    final bool showMobileBorderError =
        showMobileEmpty || (!_hasMobileFocus && state.showMobileInvalidError);
    final Color mobileBorderColor = showMobileBorderError
        ? GuestPayBillTheme.errorText
        : GuestPayBillTheme.unfocusedInputBorderColor;
    final TextStyle mobileInputStyle = mobileHasError
        ? GuestPayBillTheme.inputTextStyle.copyWith(
            color: GuestPayBillTheme.errorText,
          )
        : GuestPayBillTheme.inputTextStyle;

    final bool confirmEmpty = _digitsOnly(state.confirmMobileNumber).isEmpty;
    final bool showConfirmEmpty = _showEmptyConfirmMobileError && confirmEmpty;
    final bool confirmHasError =
        showConfirmEmpty ||
        state.showConfirmMobileInvalidError ||
        state.showConfirmMobileMismatchError;
    final bool showConfirmBorderError =
        showConfirmEmpty ||
        (!_hasConfirmMobileFocus &&
            (state.showConfirmMobileInvalidError ||
                state.showConfirmMobileMismatchError));
    final Color confirmBorderColor = showConfirmBorderError
        ? GuestPayBillTheme.errorText
        : GuestPayBillTheme.unfocusedInputBorderColor;
    final TextStyle confirmInputStyle = confirmHasError
        ? GuestPayBillTheme.inputTextStyle.copyWith(
            color: GuestPayBillTheme.errorText,
          )
        : GuestPayBillTheme.inputTextStyle;

    void verifyAction() {
      if (state.verifyStatus == GuestPayBillVerifyStatus.loading) return;

      final bool isMobileEmpty = _digitsOnly(state.mobileNumber).isEmpty;
      final bool isConfirmEmpty = _digitsOnly(
        state.confirmMobileNumber,
      ).isEmpty;

      if (isMobileEmpty || isConfirmEmpty) {
        setState(() {
          if (isMobileEmpty) _showEmptyMobileError = true;
          if (isConfirmEmpty) _showEmptyConfirmMobileError = true;
        });
        return;
      }

      if (!state.isMobileNumberValid ||
          !state.isConfirmMobileNumberValid ||
          _digitsOnly(state.mobileNumber) !=
              _digitsOnly(state.confirmMobileNumber)) {
        return;
      }

      _onVerifyPressed(context);
    }

    return <Widget>[
      Text(
        GuestPayBillTheme.mobileNumberLabel,
        style: GuestPayBillTheme.labelStyle(),
      ),
      const SizedBox(height: GuestPayBillTheme.labelToFieldGap),
      CustomCountryPhoneInputRow(
        focusNode: _mobileFocusNode,
        hideUnfocusedInputBorder: !showMobileBorderError,
        hintText: GuestPayBillTheme.phoneHintText,
        flagEmoji: state.selectedCountry.flagEmoji,
        dialCode: state.selectedCountry.dialCode,
        countryIsoCode: state.selectedCountry.isoCode,
        inputFormatters: phoneFormatters,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        onChanged: (value) {
          _onMobileChanged(context, value);
        },
        enableCountryPicker: false,
        showCountryArrow: false,
        fieldHeight: GuestPayBillTheme.inlineVerifyFieldHeight,
        countryPickerWidth: 60,
        countryToPhoneGap: GuestPayBillTheme.countryPickerToInputGap,
        borderRadius: GuestPayBillTheme.radius,
        borderWidth: GuestPayBillTheme.inputFocusBorderWidth,
        countryPickerPadding: const EdgeInsets.symmetric(horizontal: 10),
        backgroundColor: GuestPayBillTheme.fieldBg,
        unfocusedBorderColor: mobileBorderColor,
        phoneInputStyle: mobileInputStyle,
        phoneHintStyle: GuestPayBillTheme.inputHintTextStyle,
        dialCodeStyle: GuestPayBillTheme.inputTextStyle,
        flagStyle: const TextStyle(fontSize: 18, fontFamily: 'CircularPro'),
      ),
      if (mobileHasError) ...[
        const SizedBox(height: 6),
        Padding(
          padding: EdgeInsets.only(left: mobileErrorLeftPadding),
          child: Text(
            showMobileEmpty
                ? GuestPayBillTheme.emptyMobileErrorMessage
                : GuestPayBillTheme.invalidPhoneErrorMessage,
            style: GuestPayBillTheme.inlineErrorTextStyle,
          ),
        ),
      ],
      const SizedBox(height: GuestPayBillTheme.sectionGap),
      Text(
        GuestPayBillTheme.confirmMobileNumberLabel,
        style: GuestPayBillTheme.labelStyle(),
      ),
      const SizedBox(height: GuestPayBillTheme.labelToFieldGap),
      CustomCountryPhoneInputSubmitRow(
        focusNode: _confirmMobileFocusNode,
        hideUnfocusedInputBorder: !showConfirmBorderError,
        hintText: GuestPayBillTheme.phoneHintText,
        flagEmoji: state.selectedCountry.flagEmoji,
        dialCode: state.selectedCountry.dialCode,
        countryIsoCode: state.selectedCountry.isoCode,
        inputFormatters: phoneFormatters,
        enableCountryPicker: false,
        showCountryArrow: false,
        fieldHeight: GuestPayBillTheme.inlineVerifyFieldHeight,
        countryPickerWidth: 60,
        countryToPhoneGap: GuestPayBillTheme.countryPickerToInputGap,
        countryPickerPadding: const EdgeInsets.symmetric(horizontal: 10),
        inputContainerPadding: const EdgeInsets.all(8),
        phoneInputPadding: const EdgeInsets.symmetric(horizontal: 8),
        countryFlagToDialGap: 6,
        countryDialToArrowGap: 4,
        countryArrowIconSize: 18,
        backgroundColor: GuestPayBillTheme.fieldBg,
        unfocusedBorderColor: confirmBorderColor,
        borderRadius: GuestPayBillTheme.radius,
        borderWidth: GuestPayBillTheme.inputFocusBorderWidth,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        phoneInputStyle: confirmInputStyle,
        phoneHintStyle: GuestPayBillTheme.inputHintTextStyle,
        dialCodeStyle: GuestPayBillTheme.inputTextStyle,
        submitEnabled: true,
        submitLoading: state.verifyStatus == GuestPayBillVerifyStatus.loading,
        onChanged: (value) {
          _onConfirmMobileChanged(context, value);
        },
        onSubmit: verifyAction,
        onSubmitted: (_) => verifyAction(),
      ),
      if (confirmHasError) ...[
        const SizedBox(height: 6),
        Padding(
          padding: EdgeInsets.only(left: confirmErrorLeftPadding),
          child: Text(
            showConfirmEmpty
                ? GuestPayBillTheme.emptyConfirmMobileErrorMessage
                : (state.showConfirmMobileInvalidError
                      ? GuestPayBillTheme.invalidPhoneErrorMessage
                      : GuestPayBillTheme.mobileMismatchErrorMessage),
            style: GuestPayBillTheme.inlineErrorTextStyle,
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildNonPostpaidFields(
    BuildContext context,
    GuestPayBillState state,
  ) {
    void verifyAction() {
      _onVerifyPressed(context);
    }

    return <Widget>[
      Text(state.accountIdentifierLabel, style: GuestPayBillTheme.labelStyle()),
      const SizedBox(height: GuestPayBillTheme.labelToFieldGap),
      GuestPayBillFocusedTextField(
        focusNode: _accountNumberFocusNode,
        hint: state.accountIdentifierHint,
        keyboardType: state.isAlivFibr
            ? TextInputType.text
            : TextInputType.number,
        textInputAction: TextInputAction.next,
        onChanged: (value) {
          _onAccountNumberChanged(context, value);
        },
      ),
      const SizedBox(height: GuestPayBillTheme.sectionGap),
      Text(GuestPayBillTheme.nameLabel, style: GuestPayBillTheme.labelStyle()),
      const SizedBox(height: GuestPayBillTheme.labelToFieldGap),
      GuestPayBillInlineVerifyField(
        focusNode: _nameFocusNode,
        hint: GuestPayBillTheme.nameHintText,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        loading: state.verifyStatus == GuestPayBillVerifyStatus.loading,
        enabled: state.canVerify,
        onChanged: (value) {
          _onNameChanged(context, value);
        },
        onSubmit: verifyAction,
        onSubmitted: (_) => verifyAction(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final page = BlocListener<GuestPayBillBloc, GuestPayBillState>(
      listenWhen: (previousState, currentState) {
        final hasErrorChanged =
            previousState.errorMessage != currentState.errorMessage;
        final hasSubmitStatusChanged =
            previousState.submitStatus != currentState.submitStatus;
        final hasVerifyStatusChanged =
            previousState.verifyStatus != currentState.verifyStatus;

        return hasErrorChanged ||
            hasSubmitStatusChanged ||
            hasVerifyStatusChanged;
      },
      listener: (context, state) {
        _onBlocStateChanged(context, state);
      },
      child: Scaffold(
        backgroundColor: GuestPayBillTheme.pageBg,
        body: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              DefaultAppBar(
                title: GuestPayBillTheme.appBarTitle,
                backgroundColor: GuestPayBillTheme.primary,
                onBack: () {
                  context.pop();
                },
                onHomeTap: () => context.go(AppRoutes.guestSplash),
              ),
              Expanded(
                child: BlocBuilder<GuestPayBillBloc, GuestPayBillState>(
                  builder: (context, state) {
                    if (state.loadStatus == GuestPayBillLoadStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    void finalSubmitAction() {
                      _onSubmitPressed(context);
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        GuestPayBillTheme.contentHorizontalPadding,
                        GuestPayBillTheme.contentTopGapAfterAppBar,
                        GuestPayBillTheme.contentHorizontalPadding,
                        GuestPayBillTheme.contentBottomPadding,
                      ),
                      child: Column(
                        // Reset field text along with Bloc inputs on service changes.
                        key: ValueKey(state.selectedService?.code),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const GuestPayBillRequiredLabel(
                            text: GuestPayBillTheme.selectServiceLabel,
                          ),
                          const SizedBox(
                            height: GuestPayBillTheme.labelToFieldGap,
                          ),
                          GuestPayBillServiceDropdown(
                            services: state.services,
                            selected: state.selectedService,
                            onChanged: (selectedService) {
                              _onServiceChanged(context, selectedService);
                            },
                          ),
                          const SizedBox(
                            height: GuestPayBillTheme.labelToFieldGap,
                          ),
                          Text(
                            GuestPayBillTheme.selectServiceHelperText,
                            style: GuestPayBillTheme.helperStyle(),
                          ),
                          const SizedBox(height: GuestPayBillTheme.sectionGap),

                          // Dynamic form by selected service type.
                          if (state.isRev)
                            GuestPayBillPayWithRevCard(
                              onContinueToPay: () => context.push(
                                AppRoutes.revLandingPrepaidScreen,
                              ),
                            )
                          else ...[
                            if (state.isAlivPostpaid)
                              ..._buildAlivPostpaidFields(context, state)
                            else
                              ..._buildNonPostpaidFields(context, state),
                            const SizedBox(
                              height: GuestPayBillTheme.sectionGap,
                            ),
                            Text(
                              GuestPayBillTheme.accountStatusLabel,
                              style: GuestPayBillTheme.labelStyle(),
                            ),
                            const SizedBox(
                              height: GuestPayBillTheme.labelToFieldGap,
                            ),
                            GuestPayBillReadOnlyBox(
                              text: state.accountInfo == null
                                  ? GuestPayBillTheme.statusPlaceholderText
                                  : switch (LineStatus.fromCode(
                                      state.accountInfo!.status,
                                    )) {
                                      LineStatus.active => 'Active',
                                      final status => status.displayLabel,
                                    },
                            ),
                            const SizedBox(
                              height: GuestPayBillTheme.sectionGap,
                            ),
                            Text(
                              GuestPayBillTheme.accountBalanceLabel,
                              style: GuestPayBillTheme.labelStyle(),
                            ),
                            const SizedBox(
                              height: GuestPayBillTheme.labelToFieldGap,
                            ),
                            Text(
                              state.accountInfo?.balance == null
                                  ? GuestPayBillTheme.statusPlaceholderText
                                  : _money(state.accountInfo!.balance!),
                              style: state.accountInfo?.balance == null
                                  ? GuestPayBillTheme.accountBalanceValueStyle
                                        .copyWith(
                                          color: GuestPayBillTheme.placeholder,
                                        )
                                  : GuestPayBillTheme.accountBalanceValueStyle,
                            ),
                            if (state.isAccountInCredit) ...[
                              const SizedBox(height: 6),
                              const Text(
                                GuestPayBillTheme.accountInCreditInfoMessage,
                                style: GuestPayBillTheme.inlineErrorTextStyle,
                              ),
                            ],
                            const SizedBox(
                              height: GuestPayBillTheme.sectionGap,
                            ),
                            Text(
                              GuestPayBillTheme.customAmountLabel,
                              style: GuestPayBillTheme.labelStyle(),
                            ),
                            const SizedBox(
                              height: GuestPayBillTheme.labelToFieldGap,
                            ),
                            GuestPayBillFocusedTextField(
                              hint: GuestPayBillTheme.amountHintText,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textInputAction: TextInputAction.done,
                              isError: state.isBelowMinimumPayment,
                              onSubmitted: (_) {
                                if (state.canSubmit) {
                                  finalSubmitAction();
                                }
                              },
                              prefix: state.amountText.isEmpty
                                  ? null
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                        left: GuestPayBillTheme
                                            .amountPrefixLeftPadding,
                                        right: GuestPayBillTheme
                                            .amountPrefixRightPadding,
                                      ),
                                      child: Text(
                                        r'$',
                                        style:
                                            GuestPayBillTheme.amountPrefixStyle,
                                      ),
                                    ),
                              onChanged: (value) {
                                _onAmountChanged(context, value);
                              },
                            ),
                            if (state.isBelowMinimumPayment) ...[
                              const SizedBox(height: 6),
                              const Text(
                                GuestPayBillTheme.minimumPaymentErrorMessage,
                                style: GuestPayBillTheme.inlineErrorTextStyle,
                              ),
                            ],
                            const SizedBox(
                              height: GuestPayBillTheme.submitTopGap,
                            ),
                            GuestPayBillPrimarySubmitButton(
                              enabled: state.canSubmit,
                              loading:
                                  state.submitStatus ==
                                  GuestPayBillSubmitStatus.loading,
                              onTap: finalSubmitAction,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return BlocBuilder<GuestPayBillBloc, GuestPayBillState>(
      buildWhen: (p, c) => p.selectedService?.code != c.selectedService?.code,
      builder: (context, state) {
        final activeNodes = state.isAlivPostpaid
            ? [_mobileFocusNode, _confirmMobileFocusNode]
            : [_accountNumberFocusNode, _nameFocusNode];
        return AppKeyboardToolbar(
          focusNodes: activeNodes,
          onDone: () => _onVerifyPressed(context),
          child: page,
        );
      },
    );
  }
}
