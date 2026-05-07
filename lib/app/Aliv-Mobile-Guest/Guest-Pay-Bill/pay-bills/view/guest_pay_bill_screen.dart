import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/model/guest_pay_bill_confirm_models.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_submit_row.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/guest_pay_bill_bloc.dart';
import '../bloc/guest_pay_bill_event.dart';
import '../bloc/guest_pay_bill_state.dart';
import '../model/guest_pay_bill_models.dart';
import '../theme/guest_pay_bill_theme.dart';
import '../widgets/guest_pay_bill_focused_text_field.dart';
import '../widgets/guest_pay_bill_inline_verify_field.dart';
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

class _GuestPayBillView extends StatelessWidget {
  const _GuestPayBillView();

  GuestPayBillBloc _bloc(BuildContext context) {
    return context.read<GuestPayBillBloc>();
  }

  void _applySystemStatusBarStyle() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GuestPayBillTheme.snackBarTextStyle,
        ),
      ),
    );
  }

  void _onBlocStateChanged(BuildContext context, GuestPayBillState state) {
    final errorMessage = state.errorMessage;
    if (errorMessage != null && errorMessage.isNotEmpty) {
      _showSnackBar(context, errorMessage);
    }

    if (state.submitStatus == GuestPayBillSubmitStatus.success) {
      // _showSnackBar(context, GuestPayBillTheme.submitSuccessMessage);
      // you can show toast here in future
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
    final bloc = _bloc(context);
    bloc.add(GuestPayBillServiceChanged(service));
  }

  void _onMobileChanged(BuildContext context, String value) {
    final bloc = _bloc(context);
    bloc.add(GuestPayBillMobileChanged(value));
  }

  void _onConfirmMobileChanged(BuildContext context, String value) {
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

  void _onSubmitPressed(BuildContext context, GuestPayBillState state) {
    final bloc = _bloc(context);
    bloc.add(const GuestPayBillSubmitPressed());

    final confirmArgs = _buildConfirmArgs(state);
    context.push(
      AppRoutes.guestPayBillConfirm,
      extra: confirmArgs,
    );
  }

  String _money(double amount) {
    return '\$ ${amount.toStringAsFixed(2)}';
  }

  GuestPayBillConfirmArgs _buildConfirmArgs(GuestPayBillState state) {
    final serviceName = state.selectedService?.label ?? '';
    final identifierLabel = state.isAlivPostpaid ? 'phone no.' : 'account no.';

    final identifierValue =
        state.isAlivPostpaid ? '242-801-0000' : state.accountNumber.trim();

    return GuestPayBillConfirmArgs(
      serviceName: serviceName,
      identifierLabel: identifierLabel,
      identifierValue: identifierValue,
      amount: state.amountValue,
    );
  }

  List<Widget> _buildAlivPostpaidFields(
    BuildContext context,
    GuestPayBillState state,
  ) {
    return <Widget>[
      Text(
        GuestPayBillTheme.mobileNumberLabel,
        style: GuestPayBillTheme.labelStyle(),
      ),
      const SizedBox(height: GuestPayBillTheme.labelToFieldGap),
      CustomCountryPhoneInputRow(
        hideUnfocusedInputBorder: true,
        hintText: GuestPayBillTheme.phoneHintText,
        flagEmoji: state.selectedCountry.flagEmoji,
        dialCode: state.selectedCountry.dialCode,
        countryIsoCode: state.selectedCountry.isoCode,
        onChanged: (value) {
          _onMobileChanged(context, value);
        },
        enableCountryPicker: false,
        showCountryArrow: true,
        fieldHeight: GuestPayBillTheme.inlineVerifyFieldHeight,
        countryPickerWidth: 96,
        countryToPhoneGap: GuestPayBillTheme.countryPickerToInputGap,
        borderRadius: GuestPayBillTheme.radius,
        borderWidth: GuestPayBillTheme.inputFocusBorderWidth,
        countryPickerPadding: const EdgeInsets.symmetric(horizontal: 10),
        backgroundColor: GuestPayBillTheme.fieldBg,
        unfocusedBorderColor: GuestPayBillTheme.unfocusedInputBorderColor,
        phoneInputStyle: GuestPayBillTheme.inputTextStyle,
        phoneHintStyle: GuestPayBillTheme.inputHintTextStyle,
        dialCodeStyle: GuestPayBillTheme.inputTextStyle,
        flagStyle: const TextStyle(
          fontSize: 18,
          fontFamily: 'CircularPro',
        ),
      ),
      const SizedBox(height: GuestPayBillTheme.sectionGap),
      Text(
        GuestPayBillTheme.confirmMobileNumberLabel,
        style: GuestPayBillTheme.labelStyle(),
      ),
      const SizedBox(height: GuestPayBillTheme.labelToFieldGap),
      CustomCountryPhoneInputSubmitRow(
        hideUnfocusedInputBorder: true,
        hintText: GuestPayBillTheme.phoneHintText,
        flagEmoji: state.selectedCountry.flagEmoji,
        dialCode: state.selectedCountry.dialCode,
        countryIsoCode: state.selectedCountry.isoCode,
        enableCountryPicker: false,
        showCountryArrow: false,
        fieldHeight: GuestPayBillTheme.inlineVerifyFieldHeight,
        countryPickerWidth: 96,
        countryToPhoneGap: GuestPayBillTheme.countryPickerToInputGap,
        countryPickerPadding: const EdgeInsets.symmetric(horizontal: 10),
        inputContainerPadding: const EdgeInsets.all(8),
        phoneInputPadding: const EdgeInsets.symmetric(horizontal: 8),
        countryFlagToDialGap: 6,
        countryDialToArrowGap: 4,
        countryArrowIconSize: 18,
        backgroundColor: GuestPayBillTheme.fieldBg,
        unfocusedBorderColor: GuestPayBillTheme.unfocusedInputBorderColor,
        borderRadius: GuestPayBillTheme.radius,
        borderWidth: GuestPayBillTheme.inputFocusBorderWidth,
        keyboardType: TextInputType.phone,
        phoneInputStyle: GuestPayBillTheme.inputTextStyle,
        phoneHintStyle: GuestPayBillTheme.inputHintTextStyle,
        dialCodeStyle: GuestPayBillTheme.inputTextStyle,
        submitEnabled: state.canVerify,
        submitLoading: state.verifyStatus == GuestPayBillVerifyStatus.loading,
        onChanged: (value) {
          _onConfirmMobileChanged(context, value);
        },
        onSubmit: () {
          _onVerifyPressed(context);
        },
      ),
    ];
  }

  List<Widget> _buildNonPostpaidFields(
    BuildContext context,
    GuestPayBillState state,
  ) {
    return <Widget>[
      Text(
        state.accountIdentifierLabel,
        style: GuestPayBillTheme.labelStyle(),
      ),
      const SizedBox(height: GuestPayBillTheme.labelToFieldGap),
      GuestPayBillFocusedTextField(
        hint: state.accountIdentifierHint,
        keyboardType:
            state.isAlivFibr ? TextInputType.text : TextInputType.number,
        onChanged: (value) {
          _onAccountNumberChanged(context, value);
        },
      ),
      const SizedBox(height: GuestPayBillTheme.sectionGap),
      Text(
        GuestPayBillTheme.nameLabel,
        style: GuestPayBillTheme.labelStyle(),
      ),
      const SizedBox(height: GuestPayBillTheme.labelToFieldGap),
      GuestPayBillInlineVerifyField(
        hint: GuestPayBillTheme.nameHintText,
        keyboardType: TextInputType.text,
        loading: state.verifyStatus == GuestPayBillVerifyStatus.loading,
        enabled: state.canVerify,
        onChanged: (value) {
          _onNameChanged(context, value);
        },
        onSubmit: () {
          _onVerifyPressed(context);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _applySystemStatusBarStyle();

    return BlocListener<GuestPayBillBloc, GuestPayBillState>(
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
          child: Column(
            children: <Widget>[
              DefaultAppBar(
                  title: GuestPayBillTheme.appBarTitle,
                  backgroundColor: GuestPayBillTheme.primary,
                  onBack: () {
                    context.pop();
                  },
                  onHomeTap: () => context.go(AppRoutes.logIn)),
              Expanded(
                child: BlocBuilder<GuestPayBillBloc, GuestPayBillState>(
                  builder: (context, state) {
                    if (state.loadStatus == GuestPayBillLoadStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        GuestPayBillTheme.contentHorizontalPadding,
                        GuestPayBillTheme.contentTopGapAfterAppBar,
                        GuestPayBillTheme.contentHorizontalPadding,
                        GuestPayBillTheme.contentBottomPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const GuestPayBillRequiredLabel(
                            text: GuestPayBillTheme.selectServiceLabel,
                          ),
                          const SizedBox(
                              height: GuestPayBillTheme.labelToFieldGap),
                          GuestPayBillServiceDropdown(
                            services: state.services,
                            selected: state.selectedService,
                            onChanged: (selectedService) {
                              _onServiceChanged(context, selectedService);
                            },
                          ),
                          const SizedBox(
                              height: GuestPayBillTheme.labelToFieldGap),
                          Text(
                            GuestPayBillTheme.selectServiceHelperText,
                            style: GuestPayBillTheme.helperStyle(),
                          ),
                          const SizedBox(height: GuestPayBillTheme.sectionGap),

                          // Dynamic form by selected service type.
                          if (state.isAlivPostpaid)
                            ..._buildAlivPostpaidFields(context, state)
                          else
                            ..._buildNonPostpaidFields(context, state),

                          const SizedBox(height: GuestPayBillTheme.sectionGap),
                          Text(
                            GuestPayBillTheme.accountStatusLabel,
                            style: GuestPayBillTheme.labelStyle(),
                          ),
                          const SizedBox(
                              height: GuestPayBillTheme.labelToFieldGap),
                          GuestPayBillReadOnlyBox(
                            text: state.accountInfo?.status ??
                                GuestPayBillTheme.statusPlaceholderText,
                          ),
                          const SizedBox(height: GuestPayBillTheme.sectionGap),
                          Text(
                            GuestPayBillTheme.accountBalanceLabel,
                            style: GuestPayBillTheme.labelStyle(),
                          ),
                          const SizedBox(
                              height: GuestPayBillTheme.labelToFieldGap),
                          Text(
                            state.accountInfo?.balance == null
                                ? GuestPayBillTheme.statusPlaceholderText
                                : _money(state.accountInfo!.balance!),
                            style: GuestPayBillTheme.accountBalanceValueStyle,
                          ),

                          const SizedBox(height: GuestPayBillTheme.sectionGap),
                          Text(
                            GuestPayBillTheme.customAmountLabel,
                            style: GuestPayBillTheme.labelStyle(),
                          ),
                          const SizedBox(
                              height: GuestPayBillTheme.labelToFieldGap),
                          GuestPayBillFocusedTextField(
                            hint: GuestPayBillTheme.amountHintText,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (value) {
                              _onAmountChanged(context, value);
                            },
                          ),

                          const SizedBox(
                              height: GuestPayBillTheme.submitTopGap),
                          GuestPayBillPrimarySubmitButton(
                            enabled: state.canSubmit,
                            loading: state.submitStatus ==
                                GuestPayBillSubmitStatus.loading,
                            onTap: () {
                              _onSubmitPressed(context, state);
                            },
                          ),
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
  }
}
