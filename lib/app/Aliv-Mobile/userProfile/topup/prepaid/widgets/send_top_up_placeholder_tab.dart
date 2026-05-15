import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/model/login_country_selection.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/theme/login_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/bahamas_phone_input_formatter.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/login_phone_number_helper.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/top_up_prepaid_balance_row.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
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
  State<SendTopUpPlaceholderTab> createState() => _SendTopUpPlaceholderTabState();
}

class _SendTopUpPlaceholderTabState extends State<SendTopUpPlaceholderTab> {
  final LoginPhoneNumberHelper _phoneNumberHelper =
      const LoginPhoneNumberHelper();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _confirmPhoneFocusNode = FocusNode();

  String _amount = '15.00';
  String _phoneNumber = '';
  String _confirmPhoneNumber = '';
  bool _hasPhoneFocus = false;
  bool _hasConfirmPhoneFocus = false;
  bool _phoneFieldError = false;
  bool _confirmPhoneFieldError = false;
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
            child: const Text(
              LoginPhoneNumberHelper.invalidPhoneNumberMessage,
              style: AuthModuleTextStyles.invalidCredentials,
            ),
          ),
        ],
      ],
    );
  }

  // void _showErrorSnackBar(String? errorMessage) {
  //   final resolvedMessage = errorMessage ?? GuestTopUpTheme.fallbackErrorMessage;
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         resolvedMessage,
  //         style: GuestTopUpTheme.snackBarText,
  //       ),
  //     ),
  //   );
  // }



  /* PARKED: country picker disabled to match Login screen behavior.
     Keep this opener around for an easy revert if multi-country
     support is restored later.

  void _pickCountry() {
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
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = CountryInfo(
            flagEmoji: country.flagEmoji,
            dialCode: country.phoneCode.split(RegExp(r'[\\s-]')).first,
            isoCode: country.countryCode,
          );
        });
      },
    );
  }
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TopUpPrepaidTheme.pageBg,
      body: SafeArea(
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
                    'wallet \$ ${balanceState.walletBalanceFormatted}',
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
                forceError: _confirmPhoneFieldError,
                hasFocus: _hasConfirmPhoneFocus,
                focusNode: _confirmPhoneFocusNode,
                onChanged: (value) {
                  setState(() {
                    _confirmPhoneNumber = value;
                    _confirmPhoneFieldError = false;
                  });
                },
              ),
              const SizedBox(height: 18),

              // ================= CURRENT BALANCE =================
              // Center(
              //   child:Text(
              //     'current balance: \$129.00',
              //     style: TextStyle(
              //       color: const Color(0xFF1C1C1C) /* Black-100% */,
              //       fontSize: 14,
              //       fontFamily: 'CircularPro',
              //       fontWeight: FontWeight.w700,
              //       height: 1.43,
              //     ),
              //   )
              // ),
              //
              // const SizedBox(height: 24),

              // ================= AMOUNT CARD =================
              GradientInputField(
                label: GuestTopUpTheme.amountLabel,
                hint: GuestTopUpTheme.amountHintText,
                onChanged: (value) {
                  setState(() => _amount = value);
                },
              ),
              // Center(
              //   child:
              //   TopUpPrepaidAmountBox(
              //     value: _amount,
              //     onChanged: (v) {
              //       setState(() {
              //         _amount = v;
              //       });
              //     },
              //   ),
              // ),

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
                  onPressed: () {
                    final phoneValidation = _validatePhone(_phoneNumber);
                    final confirmPhoneValidation =
                        _validatePhone(_confirmPhoneNumber);
                    final hasPhoneError = !phoneValidation.isValid;
                    final hasConfirmPhoneError = !confirmPhoneValidation.isValid;

                    if (hasPhoneError || hasConfirmPhoneError) {
                      setState(() {
                        _phoneFieldError = hasPhoneError;
                        _confirmPhoneFieldError = hasConfirmPhoneError;
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
                      AppToast.show(
                        message: 'phone numbers do not match',
                        type: ToastType.error,
                      );
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
                    AppSession.appRoute = 'sendTopUp';
                    final amountParam = _amountValue.toStringAsFixed(2);
                    final recipientParam = Uri.encodeQueryComponent(
                      recipientPhone,
                    );
                    context.push(
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
                  child: const Text(
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
