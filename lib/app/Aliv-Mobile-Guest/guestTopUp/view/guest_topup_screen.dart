// lib/features/guest_top_up/guest_top_up/view/guest_top_up_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/bloc/guest_topup_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/bloc/guest_topup_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/bloc/guest_topup_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/data/guest_topup_data.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/repository/guest_topup_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/theme/guest_topup_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/widgets/gradient_input_field.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/widgets/phone_number_input.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/model/login_country_selection.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/bahamas_phone_input_formatter.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/login_phone_number_helper.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

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

  final CountryInfo _selectedCountry = _defaultCountry;
  final LoginPhoneNumberHelper _phoneHelper = const LoginPhoneNumberHelper();

  LoginCountrySelection get _loginCountry => LoginCountrySelection(
        isoCode: _selectedCountry.isoCode ?? 'BS',
        dialCode: _selectedCountry.dialCode,
        flagEmoji: _selectedCountry.flagEmoji,
      );

  bool get _isBahamas => (_selectedCountry.isoCode ?? '') == 'BS';

  bool _isPhoneInvalid(String value) {
    return _phoneHelper.hasLiveValidationError(
      rawPhoneNumber: value,
      selectedCountry: _loginCountry,
    );
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  bool _isMismatch(String phone, String confirm) {
    if (confirm.isEmpty) return false;
    return _digitsOnly(phone) != _digitsOnly(confirm);
  }

  void _showErrorSnackBar(String? errorMessage) {
    final resolvedMessage = errorMessage ?? GuestTopUpTheme.fallbackErrorMessage;

    AppToast.show(message: resolvedMessage.toString(), type: ToastType.error);
  }

  void _handleNextPressed(GuestTopUpState state) {
    final bool phoneInvalid = _isPhoneInvalid(state.phoneNumber);
    final bool mismatch = _isMismatch(state.phoneNumber, state.confirmPhoneNumber);
    final bool confirmEmpty = state.confirmPhoneNumber.isEmpty;

    if (state.phoneNumber.isEmpty || phoneInvalid) {
      AppToast.show(
        message: GuestTopUpTheme.invalidPhoneMessage,
        type: ToastType.error,
      );
      return;
    }

    if (confirmEmpty || mismatch) {
      AppToast.show(
        message: GuestTopUpTheme.phoneMismatchMessage,
        type: ToastType.error,
      );
      return;
    }

    final double parsedAmount = double.tryParse(
          state.amount.replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0;
    if (parsedAmount <= 0) return;

    context.push(
      AppRoutes.confirmGuestTopUp,
      extra: <String, Object?>{
        'phoneNumber': state.phoneNumber,
        'amount': parsedAmount,
      },
    );
  }

  Widget _buildPhoneField({
    required String labelText,
    required String value,
    required bool showError,
    required String? errorText,
    required ValueChanged<String> onChanged,
    TextStyle? labelStyle,
    bool showCountryArrow = false,
  }) {
    final Color borderColor =
        showError ? GuestTopUpTheme.errorRed : GuestTopUpTheme.inputFieldBorderColor;
    final TextStyle inputStyle = showError
        ? GuestTopUpTheme.phoneInput.copyWith(color: GuestTopUpTheme.errorRed)
        : GuestTopUpTheme.phoneInput;
    final double errorLeftPadding =
        60 /* countryPickerWidth default */ + GuestTopUpTheme.countryToPhoneGap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCountryPhoneInputRow(
          labelText: labelText,
          labelStyle: labelStyle,
          hintText: GuestTopUpTheme.phoneHintText,
          flagEmoji: _selectedCountry.flagEmoji,
          dialCode: _selectedCountry.dialCode,
          countryIsoCode: _selectedCountry.isoCode,
          enableCountryPicker: false,
          showCountryArrow: showCountryArrow,
          inputFormatters:
              _isBahamas ? const [BahamasPhoneInputFormatter()] : null,
          unfocusedBorderColor: borderColor,
          phoneInputStyle: inputStyle,
          onChanged: onChanged,
        ),
        if (showError && (errorText ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: errorLeftPadding),
            child: Text(
              errorText!,
              style: GuestTopUpTheme.inlineError,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GuestTopUpTheme.screenBackgroundColor,
      body: SafeArea(
        top: false,
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
                        child: BlocBuilder<GuestTopUpBloc, GuestTopUpState>(
                          buildWhen: (previous, current) =>
                              previous.phoneNumber != current.phoneNumber,
                          builder: (context, state) {
                            final bool showError =
                                _isPhoneInvalid(state.phoneNumber);
                            return _buildPhoneField(
                              labelText: GuestTopUpTheme.activePrepaidLabel,
                              labelStyle: GuestTopUpTheme.activePrepaidPrompt,
                              value: state.phoneNumber,
                              showError: showError,
                              errorText: GuestTopUpTheme.invalidPhoneMessage,
                              onChanged: (value) => context
                                  .read<GuestTopUpBloc>()
                                  .add(GuestActivePrepaidNumberEvent(value)),
                            );
                          },
                        ),
                      ),
                    ),

                    // 2) Confirm mobile number
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                          left: 23,
                          right: 23,
                        ),
                        child: BlocBuilder<GuestTopUpBloc, GuestTopUpState>(
                          buildWhen: (previous, current) =>
                              previous.phoneNumber != current.phoneNumber ||
                              previous.confirmPhoneNumber !=
                                  current.confirmPhoneNumber,
                          builder: (context, state) {
                            final bool showError = _isMismatch(
                              state.phoneNumber,
                              state.confirmPhoneNumber,
                            );
                            return _buildPhoneField(
                              labelText: GuestTopUpTheme.confirmMobileLabel,
                              value: state.confirmPhoneNumber,
                              showError: showError,
                              errorText: GuestTopUpTheme.phoneMismatchMessage,
                              onChanged: (value) => context
                                  .read<GuestTopUpBloc>()
                                  .add(GuestActivePrepaidNumberConfirmEvent(
                                      value)),
                            );
                          },
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
                          onChanged: (value) => context
                              .read<GuestTopUpBloc>()
                              .add(GuestTopUpAmountEvent(value)),
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
                              onPressed: () => _handleNextPressed(state),
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: AppConstants.defaultFontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
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
