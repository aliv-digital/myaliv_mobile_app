import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
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
                unfocusedBorderColor:
                    GuestSplashTheme.purchasePlanFieldBorderColor,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\- ]')),
                ],
                dialCodeStyle: GuestSplashTheme.dialCode,
                phoneInputStyle: GuestSplashTheme.phoneInput,
                phoneHintStyle: GuestSplashTheme.phoneHint,
                flagStyle: GuestSplashTheme.flagEmoji,
              ),
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
                unfocusedBorderColor:
                    GuestSplashTheme.purchasePlanFieldBorderColor,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\- ]')),
                ],
                dialCodeStyle: GuestSplashTheme.dialCode,
                phoneInputStyle: GuestSplashTheme.phoneInput,
                phoneHintStyle: GuestSplashTheme.phoneHint,
                flagStyle: GuestSplashTheme.flagEmoji,
              ),
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
                  context.push(AppRoutes.guestPurchasePlan);
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
