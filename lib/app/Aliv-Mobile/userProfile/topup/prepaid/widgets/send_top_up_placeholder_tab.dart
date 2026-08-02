import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/model/login_country_selection.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/theme/login_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/bahamas_phone_input_formatter.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/login_phone_number_helper.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/bloc/top_up_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/can_submit_order_result.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/send_topup_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/top_up_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/top_up_prepaid_balance_row.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/common/services/balance_currency_formatter_service.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../../../core/utils/app_session.dart';
import '../../../../../../resources/widgets/custom_country_phone_input_row.dart';
import '../../../../../Aliv-Mobile-Guest/guestTopUp/theme/guest_topup_theme.dart';
import '../../../../../Aliv-Mobile-Guest/guestTopUp/widgets/gradient_input_field.dart';
import '../theme/top_up_prepaid_theme.dart';

class SendTopUpPlaceholderTab extends StatefulWidget {
  final String title;

  const SendTopUpPlaceholderTab({super.key, required this.title});

  @override
  State<SendTopUpPlaceholderTab> createState() =>
      _SendTopUpPlaceholderTabState();
}

class _SendTopUpPlaceholderTabState extends State<SendTopUpPlaceholderTab> {
  final LoginPhoneNumberHelper _phoneNumberHelper =
      const LoginPhoneNumberHelper();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _confirmPhoneFocusNode = FocusNode();

  String _amount = '';
  String _phoneNumber = '';
  String _confirmPhoneNumber = '';
  bool _hasPhoneFocus = false;
  bool _hasConfirmPhoneFocus = false;
  bool _phoneFieldError = false;
  bool _confirmPhoneFieldError = false;
  bool _phoneNumbersDoNotMatch = false;
  bool _isChecking = false;
  // 🔥 default amount (matches design)

  double get _amountValue {
    final cleaned = _amount.trim().replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  static const LoginCountrySelection _defaultCountry =
      LoginCountrySelection.defaultBahamas;

  final LoginCountrySelection _selectedCountry = _defaultCountry;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(_handlePhoneFocusChange);
    _confirmPhoneFocusNode.addListener(_handleConfirmPhoneFocusChange);
  }

  @override
  void dispose() {
    _phoneFocusNode.removeListener(_handlePhoneFocusChange);
    _confirmPhoneFocusNode.removeListener(_handleConfirmPhoneFocusChange);
    _phoneFocusNode.dispose();
    _confirmPhoneFocusNode.dispose();
    super.dispose();
  }

  void _handlePhoneFocusChange() {
    if (_hasPhoneFocus == _phoneFocusNode.hasFocus) return;

    setState(() {
      _hasPhoneFocus = _phoneFocusNode.hasFocus;
    });
  }

  void _handleConfirmPhoneFocusChange() {
    if (_hasConfirmPhoneFocus == _confirmPhoneFocusNode.hasFocus) return;

    setState(() {
      _hasConfirmPhoneFocus = _confirmPhoneFocusNode.hasFocus;
    });
  }

  LoginPhoneValidationResult _validatePhone(String value) {
    return _phoneNumberHelper.validateAndBuildApiUsername(
      rawPhoneNumber: value,
      selectedCountry: _selectedCountry,
    );
  }

  bool _hasLivePhoneError(String value) {
    return _phoneNumberHelper.hasLiveValidationError(
      rawPhoneNumber: value,
      selectedCountry: _selectedCountry,
    );
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Widget _buildLoginStylePhoneField({
    required String labelText,
    required String value,
    required bool forceError,
    required bool hasFocus,
    required FocusNode focusNode,
    required ValueChanged<String> onChanged,
    TextStyle? labelStyle,
    String? validationMessage,
  }) {
    final showLiveValidationError = _hasLivePhoneError(value);
    final showInlineError = forceError || showLiveValidationError;
    final showBorderError = forceError || showLiveValidationError;
    final phoneBorderColor = !hasFocus && showBorderError
        ? AuthModuleColors.errorRed
        : AuthModuleColors.loginFieldBorderColor;
    final phoneInputStyle = showLiveValidationError
        ? AuthModuleTextStyles.fieldValue.copyWith(
            color: AuthModuleColors.errorRed,
          )
        : AuthModuleTextStyles.fieldValue;
    final phoneErrorLeftPadding = AuthModuleSizes.countryWidth +
        AuthModuleSizes.countryToPhoneGap +
        AuthModulePaddings.fieldHorizontal14.left;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCountryPhoneInputRow(
          focusNode: focusNode,
          hideUnfocusedInputBorder: false,
          labelText: labelText,
          labelStyle: labelStyle,
          hintText: '(242) 345-4356',
          flagEmoji: _selectedCountry.flagEmoji,
          dialCode: _selectedCountry.dialCode,
          countryIsoCode: _selectedCountry.isoCode,
          enableCountryPicker: false,
          onChanged: onChanged,
          inputFormatters: const [BahamasPhoneInputFormatter()],
          backgroundColor: AuthModuleColors.pageBackground,
          unfocusedBorderColor: phoneBorderColor,
          borderRadius: AuthModuleSizes.fieldRadius,
          borderWidth: AuthModuleSizes.fieldBorderWidth,
          fieldHeight: AuthModuleSizes.fieldHeight,
          countryPickerWidth: AuthModuleSizes.countryWidth,
          countryToPhoneGap: AuthModuleSizes.countryToPhoneGap,
          countryPickerPadding: AuthModulePaddings.countryHorizontal8,
          showCountryPickerBorder: true,
          countryPickerBorderColor: AuthModuleColors.loginFieldBorderColor,
          countryPickerBorderWidth: AuthModuleSizes.fieldBorderWidth,
          phoneInputPadding: AuthModulePaddings.fieldHorizontal14,
          countryFlagToDialGap: AuthModuleSizes.countryFlagToCodeGap,
          countryDialToArrowGap: AuthModuleSizes.countryCodeToArrowGap,
          countryArrowIconSize: AuthModuleSizes.countryArrowSize,
          countryArrowColor: AuthModuleColors.hintGrey,
          flagStyle: AuthModuleTextStyles.countryFlag,
          dialCodeStyle: AuthModuleTextStyles.countryCode,
          phoneInputStyle: phoneInputStyle,
          phoneHintStyle: AuthModuleTextStyles.fieldHint,
        ),
        if (showInlineError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: phoneErrorLeftPadding),
            child: Text(
              validationMessage ??
                  LoginPhoneNumberHelper.invalidPhoneNumberMessage,
              style: AuthModuleTextStyles.invalidCredentials,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TopUpPrepaidTheme.pageBg,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= TRANSFER FROM =================
              const _SectionLabel('transfer from'),
              const SizedBox(height: 8),

              BlocBuilder<BalanceCubit, BalanceState>(
                builder: (context, balanceState) {
                  return _ReadOnlyField(
                    'wallet ${BalanceCurrencyFormatterService.format(
                      balanceState.walletBalance,
                    )}',
                  );
                },
              ),

              const SizedBox(height: 24),

              // ================= ENTER NUMBER =================
              // const _SectionLabel('enter number to top up'),
              // const SizedBox(height: 8),
              // SendTopUpPhoneField(hint: 'eg: 242-899-9999'),
              _buildLoginStylePhoneField(
                labelText: GuestTopUpTheme.activePrepaidLabel,
                labelStyle: GuestTopUpTheme.activePrepaidPrompt,
                value: _phoneNumber,
                forceError: _phoneFieldError,
                hasFocus: _hasPhoneFocus,
                focusNode: _phoneFocusNode,
                onChanged: (value) {
                  setState(() {
                    _phoneNumber = value;
                    _phoneFieldError = false;
                    _phoneNumbersDoNotMatch = false;
                  });
                },
              ),

              const SizedBox(height: 20),

              // const _SectionLabel('confirm number to top up'),
              // const SizedBox(height: 8),
              // SendTopUpPhoneField(hint: 'eg: 242-899-9999'),
              _buildLoginStylePhoneField(
                labelText: GuestTopUpTheme.confirmMobileLabel,
                value: _confirmPhoneNumber,
                forceError:
                    _confirmPhoneFieldError || _phoneNumbersDoNotMatch,
                hasFocus: _hasConfirmPhoneFocus,
                focusNode: _confirmPhoneFocusNode,
                validationMessage: _phoneNumbersDoNotMatch
                    ? 'Phone number do not match'
                    : null,
                onChanged: (value) {
                  setState(() {
                    _confirmPhoneNumber = value;
                    _confirmPhoneFieldError = false;
                    _phoneNumbersDoNotMatch = false;
                  });
                },
              ),
              const SizedBox(height: 18),

              GradientInputField(
                label: GuestTopUpTheme.amountLabel,
                hint: GuestTopUpTheme.amountHintText,
                initialValue: _amount,
                onChanged: (value) {
                  setState(() => _amount = value);
                },
              ),

              const SizedBox(height: 30),
              BlocBuilder<BalanceCubit, BalanceState>(
                builder: (context, balanceState) {
                  return TopUpPrepaidBalanceRow(
                    balance: balanceState.walletBalance,
                    enteredAmount: _amountValue,
                    isSendTopUp: true,
                  );
                },
              ),

              const SizedBox(height: 56),

              // ================= PROCEED =================
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : () async {
                    final phoneValidation = _validatePhone(_phoneNumber);
                    final confirmPhoneValidation =
                        _validatePhone(_confirmPhoneNumber);
                    final hasPhoneError = !phoneValidation.isValid;
                    final hasConfirmPhoneError =
                        !confirmPhoneValidation.isValid;

                    if (hasPhoneError || hasConfirmPhoneError) {
                      setState(() {
                        _phoneFieldError = hasPhoneError;
                        _confirmPhoneFieldError = hasConfirmPhoneError;
                        _phoneNumbersDoNotMatch = false;
                      });
                      final hasEmptyPhone = _digitsOnly(_phoneNumber).isEmpty ||
                          _digitsOnly(_confirmPhoneNumber).isEmpty;
                      AppToast.show(
                        message: hasEmptyPhone
                            ? 'please enter phone number'
                            : LoginPhoneNumberHelper.invalidPhoneNumberMessage,
                        type: ToastType.error,
                      );
                      return;
                    }
                    final recipientPhone =
                        phoneValidation.phoneNumberForApi ?? '';
                    final confirmPhone =
                        confirmPhoneValidation.phoneNumberForApi ?? '';

                    if (recipientPhone != confirmPhone) {
                      setState(() => _phoneNumbersDoNotMatch = true);
                      return;
                    }
                    final walletBalance =
                        context.read<BalanceCubit>().state.walletBalance;
                    if (_amountValue > walletBalance) {
                      AppToast.show(
                        message: 'balance is not sufficient',
                        type: ToastType.error,
                      );
                      return;
                    }
                    // Capture context-derived refs before awaits.
                    final topUpRepo =
                        context.read<TopUpPrepaidBloc>().repo;
                    final router = GoRouter.of(context);
                    final sendTopupRepo = instance<SendTopupRepository>();

                    setState(() => _isChecking = true);
                    try {
                      // Gate 0: is this even an Aliv number?
                      final existsResult = await sendTopupRepo
                          .phoneNumberExists(recipientPhone);
                      if (!mounted) return;
                      if (existsResult ==
                          PhoneExistsResult.invalidDevice) {
                        AppToast.show(
                          message:
                              'this number is not registered on aliv. please verify the number.',
                          type: ToastType.error,
                        );
                        return;
                      }
                      if (existsResult == PhoneExistsResult.unknown) {
                        AppToast.show(
                          message: SendTopupRepository.caseDMessage,
                          type: ToastType.error,
                        );
                        return;
                      }

                      // Gate 2: recipient transfer eligibility.
                      final transferError = await sendTopupRepo
                          .transferIsValid(recipientPhone);
                      if (!mounted) return;
                      if (transferError != null) {
                        AppToast.show(
                          message: transferError,
                          type: ToastType.error,
                        );
                        return;
                      }

                      // Gate 3: no concurrent order in flight.
                      final orderResult =
                          await topUpRepo.canSubmitOrder(amount: _amountValue);
                      if (!mounted) return;
                      if (!orderResult.canProceed) {
                        AppToast.show(
                          message: CanSubmitOrderResult.pendingOrdersMessage,
                          type: ToastType.error,
                        );
                        return;
                      }
                    } on CanSubmitOrderException {
                      if (!mounted) return;
                      AppToast.show(
                        message: SendTopupRepository.caseDMessage,
                        type: ToastType.error,
                      );
                      return;
                    } finally {
                      if (mounted) setState(() => _isChecking = false);
                    }
                    if (!mounted) return;

                    AppSession.appRoute = 'sendTopUp';
                    final amountParam = _amountValue.toStringAsFixed(2);
                    final recipientParam = Uri.encodeQueryComponent(
                      recipientPhone,
                    );
                    router.push(
                      '${AppRoutes.confirmation}?amount=$amountParam&recipient=$recipientParam',
                    );
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (_) => const SendTopUpConfirmationScreen(),
                    //   ),
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TopUpPrepaidTheme.purple,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Color(0xFFF1F1F8)),
                          ),
                        )
                      : const Text(
                          'proceed',
                          style: TextStyle(
                            color: Color(0xFFF1F1F8),
                            fontSize: 15,
                            fontFamily: 'CircularPro',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                  WIDGETS                                   */
/* -------------------------------------------------------------------------- */

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1C1C1C) /* Black-100% */,
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String value;
  const _ReadOnlyField(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        value,
        style: const TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 14,
          color: Color(0xFF707070),
          fontWeight: FontWeight.w400,
          height: 1.43,
        ),
      ),
    );
  }
}
