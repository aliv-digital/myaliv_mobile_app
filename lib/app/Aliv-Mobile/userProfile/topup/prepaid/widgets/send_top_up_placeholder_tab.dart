import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/send_top_up_phone_field.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/top_up_prepaid_amount_box.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/top_up_prepaid_balance_row.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../../../core/utils/app_session.dart';
import '../../../../../../resources/widgets/custom_country_phone_input_row.dart';
import '../../../../../Aliv-Mobile-Guest/guestTopUp/theme/guest_topup_theme.dart';
import '../../../../../Aliv-Mobile-Guest/guestTopUp/widgets/gradient_input_field.dart';
import '../../../../../Aliv-Mobile-Guest/guestTopUp/widgets/phone_number_input.dart';
import '../theme/top_up_prepaid_theme.dart';

class SendTopUpPlaceholderTab extends StatefulWidget {
  final String title;

  SendTopUpPlaceholderTab({super.key, required this.title});

  @override
  State<SendTopUpPlaceholderTab> createState() => _SendTopUpPlaceholderTabState();
}

class _SendTopUpPlaceholderTabState extends State<SendTopUpPlaceholderTab> {
  String _amount = '15.00';
  String _phoneNumber = '';
  String _confirmPhoneNumber = '';
 // 🔥 default amount (matches design)

  double get _amountValue {
    final cleaned = _amount.trim().replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  static const CountryInfo _defaultCountry = CountryInfo(
    flagEmoji: '🇧🇸',
    dialCode: '1',
    isoCode: 'BS',
  );

  CountryInfo _selectedCountry = _defaultCountry;

  void _showErrorSnackBar(String? errorMessage) {
    final resolvedMessage =
        errorMessage ?? GuestTopUpTheme.fallbackErrorMessage;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resolvedMessage,
          style: GuestTopUpTheme.snackBarText,
        ),
      ),
    );
  }



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
              CustomCountryPhoneInputRow(
                labelText: GuestTopUpTheme.activePrepaidLabel,
                labelStyle: GuestTopUpTheme.activePrepaidPrompt,
                hintText: GuestTopUpTheme.phoneHintText,
                flagEmoji: _selectedCountry.flagEmoji,
                dialCode: _selectedCountry.dialCode,
                countryIsoCode: _selectedCountry.isoCode,
                enableCountryPicker: false,
                onChanged: (value) => _phoneNumber = value,
              ),

              const SizedBox(height: 20),

              // const _SectionLabel('confirm number to top up'),
              // const SizedBox(height: 8),
              // SendTopUpPhoneField(hint: 'eg: 242-899-9999'),
              CustomCountryPhoneInputRow(
                labelText: GuestTopUpTheme.confirmMobileLabel,
                hintText: GuestTopUpTheme.phoneHintText,
                flagEmoji: _selectedCountry.flagEmoji,
                enableCountryPicker: false,
                showCountryArrow: false,
                dialCode: _selectedCountry.dialCode,
                countryIsoCode: _selectedCountry.isoCode,
                onChanged: (value) => _confirmPhoneNumber = value,
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
                    if (_phoneNumber.trim().isEmpty ||
                        _confirmPhoneNumber.trim().isEmpty) {
                      AppToast.show(
                        message: 'please enter phone number',
                        type: ToastType.error,
                      );
                      return;
                    }
                    if (_phoneNumber != _confirmPhoneNumber) {
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
                      _phoneNumber.trim(),
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
                      color: const Color(0xFFF1F1F8),
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
          color:  Color(0xFF1C1C1C) /* Black-100% */,

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
          color: const Color(0xFF707070),
          fontWeight: FontWeight.w400,
          height: 1.43,
        ),
      ),
    );
  }
}

class _InputPlaceholder extends StatelessWidget {
  final String hint;
  const _InputPlaceholder(this.hint);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: TopUpPrepaidTheme.lightBg,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        hint,
        style: TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 15,
          color: TopUpPrepaidTheme.textMuted,
        ),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final int amount;
  const _AmountCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: TopUpPrepaidTheme.amountBorderGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        width: 220,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$ $amount.00',
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: TopUpPrepaidTheme.purple,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'enter top-up amount',
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 13,
                color: TopUpPrepaidTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
