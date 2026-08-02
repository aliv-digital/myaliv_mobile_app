import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/model/login_country_selection.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/bahamas_phone_input_formatter.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/login_phone_number_helper.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import '../theme/guest_splash_theme.dart';
import '../bloc/guest_splash_bloc.dart';
import '../bloc/guest_splash_event.dart';
import '../bloc/guest_splash_state.dart';
import '../model/guest_purchase_plan_input.dart';

Future<GuestSplashPurchasePlanInput?> showGuestSplashPurchasePlanBottomSheet(
  BuildContext context,
) async {
  final service = CountryService();
  final initialCountry = service.findByCode('BS') ?? service.findByCode('US');

  // Init bottom-sheet state in same bloc
  context.read<GuestSplashBloc>().add(
    GuestSplashPurchasePlanInit(initialCountry: initialCountry),
  );

  return showModalBottomSheet<GuestSplashPurchasePlanInput>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: GuestSplashTheme.purchasePlanSheetBarrierColor,
    builder: (_) {
      return BlocProvider.value(
        value: context.read<GuestSplashBloc>(),
        child: const _GuestSplashPurchasePlanSheetView(),
      );
    },
  );
}

class _GuestSplashPurchasePlanSheetView extends StatelessWidget {
  const _GuestSplashPurchasePlanSheetView();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // ✅ BottomSheet route animation
    final routeAnim = ModalRoute.of(context)?.animation;

    Widget sheet = BlocListener<GuestSplashBloc, GuestSplashState>(
      listenWhen: (p, c) {
        if (p is GuestSplashLoadedState && c is GuestSplashLoadedState) {
          return p.purchaseStatus != c.purchaseStatus;
        }
        return false;
      },
      listener: (context, state) {
        if (state is GuestSplashLoadedState) {
          if (state.purchaseStatus == GuestSplashPurchasePlanStatus.success &&
              state.purchaseResult != null) {
            Navigator.of(context).pop(state.purchaseResult);
            context.read<GuestSplashBloc>().add(GuestSplashPurchasePlanReset());
          }
        }
      },
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedPadding(
          duration: GuestSplashTheme.purchasePlanSheetKeyboardAnimationDuration,
          curve: GuestSplashTheme.purchasePlanSheetKeyboardAnimationCurve,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            width: double.infinity,
            padding: GuestSplashTheme.purchasePlanSheetContentPadding,
            decoration: BoxDecoration(
              color: GuestSplashTheme.purchasePlanSheetBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(
                  GuestSplashTheme.purchasePlanSheetTopCornerRadius,
                ),
              ),
            ),
            child: const _SheetBody(),
          ),
        ),
      ),
    );

    // ✅ Add extra animation (fade + slide) on top of default bottomSheet motion
    if (routeAnim == null) return sheet;

    final curved = CurvedAnimation(
      parent: routeAnim,
      curve: GuestSplashTheme.purchasePlanSheetEntranceCurve,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: GuestSplashTheme.purchasePlanSheetEntranceBeginOffset,
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      child: sheet,
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody();

  static const LoginPhoneNumberHelper _phoneHelper = LoginPhoneNumberHelper();

  LoginCountrySelection _loginCountry(Country? country) {
    if (country == null) return LoginCountrySelection.defaultBahamas;
    return _phoneHelper.selectionFromCountry(country);
  }

  bool _isPhoneInvalid(String value, Country? country) {
    return _phoneHelper.hasLiveValidationError(
      rawPhoneNumber: value,
      selectedCountry: _loginCountry(country),
    );
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  bool _isMismatch(String phone, String confirm) {
    if (confirm.isEmpty) return false;
    return _digitsOnly(phone) != _digitsOnly(confirm);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuestSplashBloc, GuestSplashState>(
      builder: (context, state) {
        if (state is! GuestSplashLoadedState) {
          return const SizedBox(
            height: GuestSplashTheme.purchasePlanSheetLoadingHeight,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final bool isBahamas =
            (state.purchaseCountry?.countryCode ?? '').toUpperCase() == 'BS';
        final bool showPhoneError =
            _isPhoneInvalid(state.purchasePhone, state.purchaseCountry);
        final bool showConfirmError = _isMismatch(
          state.purchasePhone,
          state.purchaseConfirmPhone,
        );
        final Color phoneBorderColor = showPhoneError
            ? GuestSplashTheme.errorRed
            : GuestSplashTheme.purchasePlanFieldBorderColor;
        final Color confirmBorderColor = showConfirmError
            ? GuestSplashTheme.errorRed
            : GuestSplashTheme.purchasePlanFieldBorderColor;
        final TextStyle phoneInputStyle = showPhoneError
            ? GuestSplashTheme.phoneInput
                .copyWith(color: GuestSplashTheme.errorRed)
            : GuestSplashTheme.phoneInput;
        final TextStyle confirmInputStyle = showConfirmError
            ? GuestSplashTheme.phoneInput
                .copyWith(color: GuestSplashTheme.errorRed)
            : GuestSplashTheme.phoneInput;
        final List<TextInputFormatter> phoneFormatters = isBahamas
            ? const <TextInputFormatter>[BahamasPhoneInputFormatter()]
            : <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\- ]')),
              ];

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                title: 'guest purchase a plan',
                onBack: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: GuestSplashTheme.purchasePlanSectionGap),
              const _Label('enter mobile number'),
              const SizedBox(
                height: GuestSplashTheme.purchasePlanLabelToFieldGap,
              ),
              // Previous local wrapper kept for quick fallback:
              // PhoneRow(
              //   country: state.purchaseCountry,
              //   hintText: 'eg: 242-899-9999',
              //   onTapCountryPicker: () => _pickCountry(context),
              //   onChanged: (v) {context.read<GuestSplashBloc>().add(
              //     GuestSplashPurchasePlanPhoneChanged(v)
              //   );
              //   },
              //   enableCountryPicker: true,
              //   showCountryArrow: true,
              // ),
              CustomCountryPhoneInputRow(
                hintText: 'eg: 242-899-9999',
                flagEmoji: state.purchaseCountry?.flagEmoji ?? '🏳️',
                dialCode: state.purchaseCountry?.phoneCode ?? '1',
                countryIsoCode: state.purchaseCountry?.countryCode,
                onChanged: (v) {
                  context.read<GuestSplashBloc>().add(
                    GuestSplashPurchasePlanPhoneChanged(v),
                  );
                },
                enableCountryPicker: false,
                showCountryArrow: false,
                fieldHeight: GuestSplashTheme.purchasePlanPhoneInputHeight,
                countryPickerWidth:
                    GuestSplashTheme.purchasePlanCountryPickerWidth,
                countryToPhoneGap:
                    GuestSplashTheme.purchasePlanCountryPickerToInputGap,
                borderRadius: GuestSplashTheme.purchasePlanFieldCornerRadius,
                borderWidth: GuestSplashTheme.purchasePlanFieldBorderWidth,
                countryPickerPadding: const EdgeInsets.only(
                  left: GuestSplashTheme.purchasePlanCountryPickerLeftPadding,
                  right: GuestSplashTheme
                      .purchasePlanCountryPickerRightPaddingWithArrow,
                ),
                showCountryPickerBorder: true,
                countryPickerBorderColor:
                    GuestSplashTheme.purchasePlanFieldBorderColor,
                countryPickerBorderWidth:
                    GuestSplashTheme.purchasePlanFieldBorderWidth,
                phoneInputPadding: const EdgeInsets.symmetric(
                  horizontal:
                      GuestSplashTheme.purchasePlanPhoneInputHorizontalPadding,
                ),
                countryFlagToDialGap:
                    GuestSplashTheme.purchasePlanCountryFlagToDialGap,
                countryDialToArrowGap:
                    GuestSplashTheme.purchasePlanCountryDialToArrowGap,
                countryArrowIconSize:
                    GuestSplashTheme.purchasePlanCountryArrowIconSize,
                countryArrowColor:
                    GuestSplashTheme.purchasePlanCountryArrowIconColor,
                backgroundColor:
                    GuestSplashTheme.purchasePlanFieldBackgroundColor,
                unfocusedBorderColor: phoneBorderColor,
                inputFormatters: phoneFormatters,
                dialCodeStyle: GuestSplashTheme.dialCode,
                phoneInputStyle: phoneInputStyle,
                phoneHintStyle: GuestSplashTheme.phoneHint,
                flagStyle: GuestSplashTheme.flagEmoji,
              ),
              if (showPhoneError) ...[
                const SizedBox(height: 6),
                const Text(
                  GuestSplashTheme.invalidPhoneMessage,
                  style: GuestSplashTheme.errorText,
                ),
              ],
              const SizedBox(height: GuestSplashTheme.purchasePlanSectionGap),
              const _Label('confirm mobile number'),
              const SizedBox(
                height: GuestSplashTheme.purchasePlanLabelToFieldGap,
              ),
              // Previous local wrapper kept for quick fallback:
              // PhoneRow(
              //   country: state.purchaseCountry,
              //   hintText: 'eg: 242-899-9999',
              //   onChanged: (v) {
              //     context.read<GuestSplashBloc>().add(
              //       GuestSplashPurchasePlanConfirmPhoneChanged(v)
              //       );
              //   },
              //   enableCountryPicker: false,
              //   showCountryArrow: false,
              // ),
              CustomCountryPhoneInputRow(
                hintText: 'eg: 242-899-9999',
                flagEmoji: state.purchaseCountry?.flagEmoji ?? '🏳️',
                dialCode: state.purchaseCountry?.phoneCode ?? '1',
                countryIsoCode: state.purchaseCountry?.countryCode,
                onChanged: (v) {
                  context.read<GuestSplashBloc>().add(
                    GuestSplashPurchasePlanConfirmPhoneChanged(v),
                  );
                },
                enableCountryPicker: false,
                showCountryArrow: false,
                fieldHeight: GuestSplashTheme.purchasePlanPhoneInputHeight,
                countryPickerWidth:
                    GuestSplashTheme.purchasePlanCountryPickerWidth,
                countryToPhoneGap:
                    GuestSplashTheme.purchasePlanCountryPickerToInputGap,
                borderRadius: GuestSplashTheme.purchasePlanFieldCornerRadius,
                borderWidth: GuestSplashTheme.purchasePlanFieldBorderWidth,
                countryPickerPadding: const EdgeInsets.only(
                  left: GuestSplashTheme.purchasePlanCountryPickerLeftPadding,
                  right: GuestSplashTheme
                      .purchasePlanCountryPickerRightPaddingWithoutArrow,
                ),
                showCountryPickerBorder: true,
                countryPickerBorderColor:
                    GuestSplashTheme.purchasePlanFieldBorderColor,
                countryPickerBorderWidth:
                    GuestSplashTheme.purchasePlanFieldBorderWidth,
                phoneInputPadding: const EdgeInsets.symmetric(
                  horizontal:
                      GuestSplashTheme.purchasePlanPhoneInputHorizontalPadding,
                ),
                countryFlagToDialGap:
                    GuestSplashTheme.purchasePlanCountryFlagToDialGap,
                countryDialToArrowGap:
                    GuestSplashTheme.purchasePlanCountryDialToArrowGap,
                countryArrowIconSize:
                    GuestSplashTheme.purchasePlanCountryArrowIconSize,
                countryArrowColor:
                    GuestSplashTheme.purchasePlanCountryArrowIconColor,
                backgroundColor:
                    GuestSplashTheme.purchasePlanFieldBackgroundColor,
                unfocusedBorderColor: confirmBorderColor,
                inputFormatters: phoneFormatters,
                dialCodeStyle: GuestSplashTheme.dialCode,
                phoneInputStyle: confirmInputStyle,
                phoneHintStyle: GuestSplashTheme.phoneHint,
                flagStyle: GuestSplashTheme.flagEmoji,
              ),
              if (showConfirmError) ...[
                const SizedBox(height: 6),
                const Text(
                  GuestSplashTheme.phoneMismatchMessage,
                  style: GuestSplashTheme.errorText,
                ),
              ],
              const SizedBox(height: GuestSplashTheme.purchasePlanSectionGap),
              if (state.purchaseStatus == GuestSplashPurchasePlanStatus.failure &&
                  (state.purchaseErrorMessage?.isNotEmpty ?? false))
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: GuestSplashTheme.purchasePlanErrorBottomPadding,
                  ),
                  child: Text(
                    state.purchaseErrorMessage!,
                    style: GuestSplashTheme.errorText,
                  ),
                ),
              DefaultButton(
                label: 'continue',
                isLoading: false,
                height: GuestSplashTheme.purchasePlanContinueButtonHeight,
                backgroundColor: GuestSplashTheme.purchasePlanContinueButtonColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(
                    GuestSplashTheme.purchasePlanContinueButtonRadius,
                  ),
                ),
                textStyle: GuestSplashTheme.continueButtonText,
                onPressed: () {
                  if (state.purchasePhone.isEmpty ||
                      _isPhoneInvalid(
                        state.purchasePhone,
                        state.purchaseCountry,
                      )) {
                    AppToast.show(
                      message: GuestSplashTheme.invalidPhoneMessage,
                      type: ToastType.error,
                    );
                    return;
                  }
                  if (state.purchaseConfirmPhone.isEmpty ||
                      _isMismatch(
                        state.purchasePhone,
                        state.purchaseConfirmPhone,
                      )) {
                    AppToast.show(
                      message: GuestSplashTheme.phoneMismatchMessage,
                      type: ToastType.error,
                    );
                    return;
                  }
                  context.push(
                    AppRoutes.guestPurchasePlan,
                    extra: {
                      'phoneNumber':
                          LoginPhoneNumberHelper.formatBahamasNumberForDisplay(
                        state.purchasePhone,
                      ),
                    },
                  );
                },
              ),
              // SizedBox(height: 24,)
            ],
          ),
        );
      },
    );
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
          width: GuestSplashTheme.purchasePlanCountryFlagWidth,
          height: GuestSplashTheme.purchasePlanCountryFlagHeight,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Text(country.flagEmoji, style: GuestSplashTheme.flagEmoji);
          },
        );
      },
      onSelect: (country) {
        context.read<GuestSplashBloc>().add(
          GuestSplashPurchasePlanCountryChanged(country),
        );
      },
    );
  }
  */
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(
            GuestSplashTheme.purchasePlanHeaderBackTapRadius,
          ),
          onTap: onBack,
          child: const Padding(
            padding: EdgeInsets.zero,
            child: Icon(
              Icons.arrow_back,
              size: GuestSplashTheme.purchasePlanHeaderBackIconSize,
            ),
          ),
        ),
        const SizedBox(
          height: GuestSplashTheme.purchasePlanHeaderBackToTitleGap,
        ),
        Text(title, style: GuestSplashTheme.sheetTitle),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: GuestSplashTheme.fieldLabel);
  }
}
