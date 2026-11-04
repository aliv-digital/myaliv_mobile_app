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
import 'package:myaliv_mobile_app/resources/widgets/app_keyboard_toolbar.dart';
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
  final FocusNode _phoneFocusNode = FocusNode(debugLabel: 'guestTopUpPhone');
  final FocusNode _confirmPhoneFocusNode = FocusNode(
    debugLabel: 'guestTopUpConfirmPhone',
  );
  final FocusNode _amountFocusNode = FocusNode(debugLabel: 'guestTopUpAmount');
  bool _isChecking = false;
  // Set only by a Next/Done attempt with an empty first number; cleared as
  // soon as the user edits that field.
  bool _showEmptyPhoneError = false;
  // Set only by a Next/Done attempt with an empty confirm number; cleared as
  // soon as the user edits the confirm field.
  bool _showEmptyConfirmPhoneError = false;
  // GST-004: product-approved Guest Top-up range (USD, inclusive). Local to
  // this flow so logged-in Top-up limits are unaffected.
  static const double _minGuestTopUpAmount = 5;
  static const double _maxGuestTopUpAmount = 100;
  // Set only by a Next/Done attempt with an out-of-range amount; cleared as
  // soon as the user edits the amount.
  bool _showAmountRangeError = false;
  static const CountryInfo _defaultCountry = CountryInfo(
    flagEmoji: '🇧🇸',
    dialCode: '1',
    isoCode: 'BS',
  );

  final CountryInfo _selectedCountry = _defaultCountry;
  final LoginPhoneNumberHelper _phoneHelper = const LoginPhoneNumberHelper(
    requireBahamasAreaCode: true,
  );

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
    if (_digitsOnly(confirm).isEmpty) return false;
    return _digitsOnly(phone) != _digitsOnly(confirm);
  }

  void _showErrorSnackBar(String? errorMessage) {
    final resolvedMessage =
        errorMessage ?? GuestTopUpTheme.fallbackErrorMessage;

    AppToast.show(message: resolvedMessage.toString(), type: ToastType.error);
  }

  Future<void> _handleNextPressed(GuestTopUpState state) async {
    if (_isChecking) return;

    final bool phoneInvalid = _isPhoneInvalid(state.phoneNumber);
    final bool mismatch = _isMismatch(
      state.phoneNumber,
      state.confirmPhoneNumber,
    );
    final bool confirmEmpty = _digitsOnly(state.confirmPhoneNumber).isEmpty;

    if (state.phoneNumber.isEmpty) {
      setState(() => _showEmptyPhoneError = true);
      return;
    }

    if (phoneInvalid) {
      AppToast.show(
        message: GuestTopUpTheme.invalidPhoneMessage,
        type: ToastType.error,
      );
      return;
    }

    if (confirmEmpty) {
      setState(() => _showEmptyConfirmPhoneError = true);
      return;
    }

    if (mismatch) {
      AppToast.show(
        message: GuestTopUpTheme.phoneMismatchMessage,
        type: ToastType.error,
      );
      return;
    }

    final double parsedAmount =
        double.tryParse(state.amount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    if (parsedAmount < _minGuestTopUpAmount ||
        parsedAmount > _maxGuestTopUpAmount) {
      setState(() => _showAmountRangeError = true);
      return;
    }

    final repo = context.read<GuestTopUpBloc>().repository;

    setState(() => _isChecking = true);
    try {
      final result = await repo.verifyNumber(state.phoneNumber);
      if (!mounted) return;

      // Previous separate checks retained for reference.
      // if (result.paymentOption != GuestTopUpTheme.paymentOptionPrePay) {
      //   AppToast.show(
      //     message: GuestTopUpTheme.notPrepaidErrorMessage,
      //     type: ToastType.error,
      //   );
      //   return;
      // }
      //
      // if (result.accountStatus != GuestTopUpTheme.accountStatusActive) {
      //   AppToast.show(
      //     message: GuestTopUpTheme.inactiveAccountErrorMessage,
      //     type: ToastType.error,
      //   );
      //   return;
      // }

      if (result.paymentOption != GuestTopUpTheme.paymentOptionPrePay ||
          result.accountStatus != GuestTopUpTheme.accountStatusActive) {
        AppToast.show(
          message: GuestTopUpTheme.invalidActivePrepaidErrorMessage,
          type: ToastType.error,
        );
        return;
      }

      context.push(
        AppRoutes.confirmGuestTopUp,
        extra: <String, Object?>{
          'phoneNumber': state.phoneNumber,
          'amount': parsedAmount,
        },
      );
    } catch (_) {
      if (!mounted) return;
      AppToast.show(
        message: GuestTopUpTheme.fallbackErrorMessage,
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _confirmPhoneFocusNode.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Widget _buildPhoneField({
    required String labelText,
    required String value,
    required bool showError,
    required String? errorText,
    required ValueChanged<String> onChanged,
    TextStyle? labelStyle,
    bool showCountryArrow = false,
    TextInputAction? textInputAction,
    FocusNode? focusNode,
  }) {
    final Color borderColor = showError
        ? GuestTopUpTheme.errorRed
        : GuestTopUpTheme.inputFieldBorderColor;
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
          inputFormatters: _isBahamas
              ? const [BahamasPhoneInputFormatter()]
              : null,
          hideUnfocusedInputBorder: !showError,
          unfocusedBorderColor: borderColor,
          focusNode: focusNode,
          phoneInputStyle: inputStyle,
          onChanged: onChanged,
          textInputAction: textInputAction,
        ),
        if (showError && (errorText ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: errorLeftPadding),
            child: Text(errorText!, style: GuestTopUpTheme.inlineError),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    void nextAction() {
      final currentState = context.read<GuestTopUpBloc>().state;
      _handleNextPressed(currentState);
    }

    final page = Scaffold(
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
                                _showEmptyPhoneError ||
                                _isPhoneInvalid(state.phoneNumber);
                            return _buildPhoneField(
                              focusNode: _phoneFocusNode,
                              labelText: GuestTopUpTheme.activePrepaidLabel,
                              labelStyle: GuestTopUpTheme.activePrepaidPrompt,
                              value: state.phoneNumber,
                              showError: showError,
                              errorText: _showEmptyPhoneError
                                  ? GuestTopUpTheme.emptyPhoneMessage
                                  : 'invalid Format',
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                if (_showEmptyPhoneError) {
                                  setState(() => _showEmptyPhoneError = false);
                                }
                                context.read<GuestTopUpBloc>().add(
                                  GuestActivePrepaidNumberEvent(value),
                                );
                              },
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
                            final bool confirmEmpty = _digitsOnly(
                              state.confirmPhoneNumber,
                            ).isEmpty;
                            final bool showEmptyError =
                                _showEmptyConfirmPhoneError && confirmEmpty;
                            final bool showMismatchError =
                                !confirmEmpty &&
                                _isMismatch(
                                  state.phoneNumber,
                                  state.confirmPhoneNumber,
                                );
                            final bool showError =
                                showEmptyError || showMismatchError;
                            final String? errorText = showEmptyError
                                ? GuestTopUpTheme.emptyConfirmPhoneMessage
                                : (showMismatchError
                                      ? GuestTopUpTheme.phoneMismatchMessage
                                      : null);
                            return _buildPhoneField(
                              focusNode: _confirmPhoneFocusNode,
                              labelText: GuestTopUpTheme.confirmMobileLabel,
                              value: state.confirmPhoneNumber,
                              showError: showError,
                              errorText: errorText,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                if (_showEmptyConfirmPhoneError) {
                                  setState(
                                    () => _showEmptyConfirmPhoneError = false,
                                  );
                                }
                                context.read<GuestTopUpBloc>().add(
                                  GuestActivePrepaidNumberConfirmEvent(value),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // 3) Top-up amount
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 44, bottom: 44),
                        child: Column(
                          children: [
                            GradientInputField(
                              focusNode: _amountFocusNode,
                              label: GuestTopUpTheme.amountLabel,
                              hint: GuestTopUpTheme.amountHintText,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => nextAction(),
                              onChanged: (value) {
                                if (_showAmountRangeError) {
                                  setState(() => _showAmountRangeError = false);
                                }
                                context.read<GuestTopUpBloc>().add(
                                  GuestTopUpAmountEvent(value),
                                );
                              },
                            ),
                            if (_showAmountRangeError) ...[
                              const SizedBox(height: 6),
                              const Text(
                                GuestTopUpTheme.amountRangeMessage,
                                textAlign: TextAlign.center,
                                style: GuestTopUpTheme.inlineError,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // 4) Next button
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 43, right: 43),
                        child: BlocBuilder<GuestTopUpBloc, GuestTopUpState>(
                          builder: (context, _) {
                            return DefaultButton(
                              height: 40,
                              backgroundColor: HexColor.fromHex('FF645D9C'),
                              onPressed: nextAction,
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: AppConstants.defaultFontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              label: GuestTopUpTheme.proceedButtonLabel,
                              isLoading: _isChecking,
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

    return AppKeyboardToolbar(
      focusNodes: [_phoneFocusNode, _confirmPhoneFocusNode, _amountFocusNode],
      onDone: nextAction,
      child: page,
    );
  }
}
