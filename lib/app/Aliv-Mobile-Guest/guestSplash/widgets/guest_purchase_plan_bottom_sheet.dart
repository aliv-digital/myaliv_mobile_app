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

class _SheetBody extends StatefulWidget {
  const _SheetBody();

  @override
  State<_SheetBody> createState() => _SheetBodyState();
}

class _SheetBodyState extends State<_SheetBody> {
  static const LoginPhoneNumberHelper _phoneHelper = LoginPhoneNumberHelper();

  late final TextEditingController _phoneController;
  late final TextEditingController _confirmPhoneController;
  late final FocusNode _phoneFocusNode;
  late final FocusNode _confirmPhoneFocusNode;

  // Set only by a Continue/Done attempt with an empty mobile number; cleared
  // as soon as the user edits that field.
  bool _showEmptyPhoneError = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<GuestSplashBloc>();
    final s = bloc.state;
    final initialPhone = s is GuestSplashLoadedState ? s.purchasePhone : '';
    final initialConfirm = s is GuestSplashLoadedState
        ? s.purchaseConfirmPhone
        : '';

    _phoneController = TextEditingController(text: initialPhone);
    _confirmPhoneController = TextEditingController(text: initialConfirm);
    _phoneFocusNode = FocusNode();
    _confirmPhoneFocusNode = FocusNode();

    _phoneFocusNode.addListener(_onPhoneFocusChange);
    _confirmPhoneFocusNode.addListener(_onConfirmPhoneFocusChange);
  }

  @override
  void dispose() {
    _phoneFocusNode.removeListener(_onPhoneFocusChange);
    _confirmPhoneFocusNode.removeListener(_onConfirmPhoneFocusChange);
    _phoneFocusNode.dispose();
    _confirmPhoneFocusNode.dispose();
    _phoneController.dispose();
    _confirmPhoneController.dispose();
    super.dispose();
  }

  void _onPhoneFocusChange() {
    if (!_phoneFocusNode.hasFocus) {
      _normalizeFieldIfSevenDigits(_phoneController, isConfirm: false);
    }
  }

  void _onConfirmPhoneFocusChange() {
    if (!_confirmPhoneFocusNode.hasFocus) {
      _normalizeFieldIfSevenDigits(_confirmPhoneController, isConfirm: true);
    }
  }

  void _normalizeFieldIfSevenDigits(
    TextEditingController controller, {
    required bool isConfirm,
  }) {
    final digits = _digitsOnly(controller.text);
    if (digits.length == 7) {
      final formatted = LoginPhoneNumberHelper.formatBahamasNumberForDisplay(
        digits,
      );
      controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      if (isConfirm) {
        context.read<GuestSplashBloc>().add(
          GuestSplashPurchasePlanConfirmPhoneChanged(formatted),
        );
      } else {
        context.read<GuestSplashBloc>().add(
          GuestSplashPurchasePlanPhoneChanged(formatted),
        );
      }
    }
  }

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
            _showEmptyPhoneError ||
            _isPhoneInvalid(_phoneController.text, state.purchaseCountry);
        final bool showConfirmError = _isMismatch(
          _phoneController.text,
          _confirmPhoneController.text,
        );
        final Color phoneBorderColor = showPhoneError
            ? GuestSplashTheme.errorRed
            : GuestSplashTheme.purchasePlanFieldBorderColor;
        final Color confirmBorderColor = showConfirmError
            ? GuestSplashTheme.errorRed
            : GuestSplashTheme.purchasePlanFieldBorderColor;
        final TextStyle phoneInputStyle = showPhoneError
            ? GuestSplashTheme.phoneInput.copyWith(
                color: GuestSplashTheme.errorRed,
              )
            : GuestSplashTheme.phoneInput;
        final TextStyle confirmInputStyle = showConfirmError
            ? GuestSplashTheme.phoneInput.copyWith(
                color: GuestSplashTheme.errorRed,
              )
            : GuestSplashTheme.phoneInput;
        final List<TextInputFormatter> phoneFormatters = isBahamas
            ? const <TextInputFormatter>[BahamasPhoneInputFormatter()]
            : <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\- ]')),
              ];
        Future<void> continueAction() async {
          if (_isVerifying) return;

          // Normalize any 7-digit Bahamas input in the UI fields before submitting
          _normalizeFieldIfSevenDigits(_phoneController, isConfirm: false);
          _normalizeFieldIfSevenDigits(
            _confirmPhoneController,
            isConfirm: true,
          );

          final phone = _phoneController.text.trim();
          final confirmPhone = _confirmPhoneController.text.trim();

          if (phone.isEmpty) {
            setState(() => _showEmptyPhoneError = true);
            return;
          }
          if (_isPhoneInvalid(phone, state.purchaseCountry)) {
            AppToast.show(
              message: GuestSplashTheme.invalidPhoneMessage,
              type: ToastType.error,
            );
            return;
          }
          if (confirmPhone.isEmpty || _isMismatch(phone, confirmPhone)) {
            AppToast.show(
              message: GuestSplashTheme.phoneMismatchMessage,
              type: ToastType.error,
            );
            return;
          }

          final repo = context.read<GuestSplashBloc>().repository;
          setState(() => _isVerifying = true);
          try {
            final subscriber = await repo.verifySubscriber(phone);
            if (!context.mounted) return;
            if (!subscriber.isActivePrepaid) {
              AppToast.show(
                message: GuestSplashTheme.invalidActivePrepaidErrorMessage,
                type: ToastType.error,
              );
              return;
            }
            context.push(
              AppRoutes.guestPurchasePlan,
              extra: {
                'phoneNumber':
                    LoginPhoneNumberHelper.formatBahamasNumberForDisplay(phone),
              },
            );
          } catch (_) {
            if (!context.mounted) return;
            AppToast.show(
              message: GuestSplashTheme.invalidActivePrepaidErrorMessage,
              type: ToastType.error,
            );
          } finally {
            if (mounted) {
              setState(() => _isVerifying = false);
            }
          }
        }

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
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                hintText: 'eg: (242)-899-9999',
                flagEmoji: state.purchaseCountry?.flagEmoji ?? '🏳️',
                dialCode: state.purchaseCountry?.phoneCode ?? '1',
                countryIsoCode: state.purchaseCountry?.countryCode,
                textInputAction: TextInputAction.next,
                onChanged: (v) {
                  if (_showEmptyPhoneError) {
                    setState(() => _showEmptyPhoneError = false);
                  }
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
                Text(
                  _showEmptyPhoneError
                      ? GuestSplashTheme.emptyPhoneMessage
                      : 'invalid Format',
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
                controller: _confirmPhoneController,
                focusNode: _confirmPhoneFocusNode,
                hintText: 'eg: (242)-899-9999',
                flagEmoji: state.purchaseCountry?.flagEmoji ?? '🏳️',
                dialCode: state.purchaseCountry?.phoneCode ?? '1',
                countryIsoCode: state.purchaseCountry?.countryCode,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => continueAction(),
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
              if (state.purchaseStatus ==
                      GuestSplashPurchasePlanStatus.failure &&
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
                isLoading: _isVerifying,
                height: GuestSplashTheme.purchasePlanContinueButtonHeight,
                backgroundColor:
                    GuestSplashTheme.purchasePlanContinueButtonColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(
                    GuestSplashTheme.purchasePlanContinueButtonRadius,
                  ),
                ),
                textStyle: GuestSplashTheme.continueButtonText,
                onPressed: continueAction,
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
