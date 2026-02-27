// lib/features/guest_top_up/guest_top_up/view/guest_top_up_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_picker/country_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/widgets/gradient_input_field.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../resources/extentions/hex_color.dart';
import '../../../../resources/widgets/defaultButton.dart';
import '../bloc/guest_topup_bloc.dart';
import '../bloc/guest_topup_event.dart';
import '../bloc/guest_topup_state.dart';
import '../data/guest_topup_data.dart';
import '../repository/guest_topup_repository.dart';
import '../theme/guest_topup_theme.dart';
import '../widgets/phone_number_input.dart';

class GuestTopUpScreen extends StatelessWidget {
  const GuestTopUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = GuestTopUpBloc(repository: const GuestTopUpRepository());

        // Initialize default state values when this screen opens.
        bloc.add(const GuestTopUpStarted());

        return bloc;
      },
      child: const _GuestTopUpView(),
    );
  }
}

class _GuestTopUpView extends StatefulWidget {
  const _GuestTopUpView();

  @override
  State<_GuestTopUpView> createState() => _GuestTopUpViewState();
}

class _GuestTopUpViewState extends State<_GuestTopUpView> {
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

  void _goToConfirmTopUp() {
    context.push(AppRoutes.confirmGuestTopUp);
  }

  void _pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      // Keep using the previous package while rendering flat flag assets.
      customFlagBuilder: (Country country) {
        // `country_pickers` does not include `ac.png`, so map AC -> SH asset.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GuestTopUpTheme.screenBackgroundColor,
      body: SafeArea(
        child: BlocListener<GuestTopUpBloc, GuestTopUpState>(
          listenWhen: (previousState, currentState) {
            final hasStatusChanged =
                previousState.status != currentState.status;
            final isFailureState =
                currentState.status == GuestTopUpStatus.failure;

            return hasStatusChanged && isFailureState;
          },
          listener: (context, state) {
            _showErrorSnackBar(state.errorMessage);
          },
          child: Column(
            children: [
              DefaultAppBar(
                backgroundColor: HexColor.fromHex('FF645D9C'),
                title: GuestTopUpStrings.guestTopUpAppbarTitle,
                onBack: () {
                  context.pop();
                },
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // 1) Active prepaid number
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: GuestTopUpTheme.activePrepaidTopGap,
                          left: GuestTopUpTheme.activePrepaidHorizontal,
                          right: GuestTopUpTheme.activePrepaidHorizontal,
                        ),
                        child: CustomCountryPhoneInputRow(
                          labelText: GuestTopUpTheme.activePrepaidLabel,
                          labelStyle: GuestTopUpTheme.activePrepaidPrompt,
                          hintText: GuestTopUpTheme.phoneHintText,
                          flagEmoji: _selectedCountry.flagEmoji,
                          dialCode: _selectedCountry.dialCode,
                          countryIsoCode: _selectedCountry.isoCode,
                          onTapCountryPicker: _pickCountry,
                          onChanged: (value) {},
                        ),
                      ),
                    ),

                    // 2) Confirm mobile number
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 20,
                                left: 23,
                                right: 23),
                        child: CustomCountryPhoneInputRow(
                          labelText: GuestTopUpTheme.confirmMobileLabel,
                          hintText: GuestTopUpTheme.phoneHintText,
                          flagEmoji: _selectedCountry.flagEmoji,
                          enableCountryPicker: false,
                          showCountryArrow: false,
                          dialCode: _selectedCountry.dialCode,
                          countryIsoCode: _selectedCountry.isoCode,
                          onChanged: (value) {},
                        ),
                      ),
                    ),

                    // 3) Top-up amount
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 44, bottom: 44),
                        child: GradientInputField(
                          label: GuestTopUpTheme.amountLabel,
                          hint: GuestTopUpTheme.amountHintText,
                          onChanged: (value) {},
                        ),
                      ),
                    ),

                    // 4) Next button
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 43, right: 43),
                        child: BlocBuilder<GuestTopUpBloc, GuestTopUpState>(
                          builder: (context, state) {
                            return DefaultButton(
                              height: 40,
                              backgroundColor: HexColor.fromHex('FF645D9C'),
                              onPressed: () {
                                _goToConfirmTopUp();
                              },
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              label: GuestTopUpTheme.nextButtonLabel,
                              isLoading: false,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
