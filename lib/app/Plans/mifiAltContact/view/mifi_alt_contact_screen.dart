import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/model/login_country_selection.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/theme/login_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/bahamas_phone_input_formatter.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/login_phone_number_helper.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/theme/home_plan_confirmation_theme.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/model/mifi_alt_contact_route_args.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class MifiAltContactScreen extends StatefulWidget {
  const MifiAltContactScreen({super.key, required this.args});

  final MifiAltContactRouteArgs args;

  @override
  State<MifiAltContactScreen> createState() => _MifiAltContactScreenState();
}

class _MifiAltContactScreenState extends State<MifiAltContactScreen> {
  static const LoginPhoneNumberHelper _phoneHelper = LoginPhoneNumberHelper();

  late final TextEditingController _phoneController;
  final FocusNode _phoneFocusNode = FocusNode();

  final LoginCountrySelection _selectedCountry =
      LoginCountrySelection.defaultBahamas;
  String _rawPhone = '';
  bool? _marketingOptIn;
  bool _hasPhoneFocus = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _rawPhone = '';
    _phoneFocusNode.addListener(_handlePhoneFocusChange);
  }

  @override
  void dispose() {
    _phoneFocusNode.removeListener(_handlePhoneFocusChange);
    _phoneFocusNode.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handlePhoneFocusChange() {
    if (_hasPhoneFocus == _phoneFocusNode.hasFocus) return;
    setState(() => _hasPhoneFocus = _phoneFocusNode.hasFocus);
  }

  bool get _isPhoneValid {
    return _phoneHelper
        .validateAndBuildApiUsername(
          rawPhoneNumber: _rawPhone,
          selectedCountry: _selectedCountry,
        )
        .isValid;
  }

  bool get _canContinue => _isPhoneValid && _marketingOptIn != null;

  void _onContinuePressed() {
    final validation = _phoneHelper.validateAndBuildApiUsername(
      rawPhoneNumber: _rawPhone,
      selectedCountry: _selectedCountry,
    );
    if (!validation.isValid) return;

    final accountState = instance<AccountInfoCubit>().state;
    final args = _buildConfirmationArgs(
      accountState: accountState,
      altContactNumber: validation.phoneNumberForApi ?? '',
      marketingOptIn: _marketingOptIn ?? false,
    );

    context.pushReplacement(
      AppRoutes.homePlanConfirmationScreen,
      extra: args,
    );
  }

  HomePlanConfirmationRouteArgs _buildConfirmationArgs({
    required AccountInfoState accountState,
    required String altContactNumber,
    required bool marketingOptIn,
  }) {
    final selectedApiPlan = widget.args.selectedApiPlan;
    final fallbackPlan = widget.args.fallbackPlan;

    return HomePlanConfirmationRouteArgs(
      phoneNumber: _accountUsername(accountState),
      accountHolderName: _accountDisplayName(accountState),
      primaryPlanId: selectedApiPlan?.planId.trim() ?? fallbackPlan.id,
      primaryPlanName: _planName(
        selectedApiPlan: selectedApiPlan,
        fallbackPlan: fallbackPlan,
      ),
      primaryPlanTypeCode: selectedApiPlan?.planType.trim() ?? 'P',
      primaryPlanPrice: selectedApiPlan?.planAmount ?? fallbackPlan.price,
      primaryPlanVatAmount: selectedApiPlan?.vatAmount ?? 0,
      futurePlanStartDate: selectedApiPlan?.startDate.trim() ?? '',
      flow: HomePlanConfirmationEntryFlow.skip,
      forceNow: widget.args.forceNow,
      altContactNumber: altContactNumber,
      marketingOptIn: marketingOptIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePlanConfirmationTheme.bg,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: DefaultAppBar(
              title: 'alternate contact number',
              backgroundColor: HomePlanConfirmationTheme.purple,
              showBackArrow: true,
              showHome: true,
              onBack: () => context.pop(),
              onHomeTap: () => context.go(AppRoutes.home),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'we would like to stay connected. please provide a '
                          'mobile number that is not your mifi number.',
                          style: _MifiAltContactStyles.bodyText,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'mobile number:',
                          style: _MifiAltContactStyles.fieldLabel,
                        ),
                        const SizedBox(height: 8),
                        _phoneRow(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Card(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Text(
                            'would you like to receive plan discounts and '
                            'other device offers from aliv?',
                            style: _MifiAltContactStyles.bodyText,
                          ),
                        ),
                        _RadioRow(
                          label: 'yes',
                          selected: _marketingOptIn == true,
                          onTap: () => setState(() => _marketingOptIn = true),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFE6E8F2),
                        ),
                        _RadioRow(
                          label: 'no',
                          selected: _marketingOptIn == false,
                          onTap: () => setState(() => _marketingOptIn = false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: DefaultButton(
                label: 'continue',
                isLoading: false,
                onPressed: _canContinue ? _onContinuePressed : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _phoneRow() {
    final bool showLiveError = _phoneHelper.hasLiveValidationError(
      rawPhoneNumber: _rawPhone,
      selectedCountry: _selectedCountry,
    );
    final bool showBorderError = !_hasPhoneFocus && showLiveError;
    final Color borderColor = showBorderError
        ? AuthModuleColors.errorRed
        : AuthModuleColors.loginFieldBorderColor;
    final TextStyle inputStyle = showLiveError
        ? AuthModuleTextStyles.fieldValue.copyWith(
            color: AuthModuleColors.errorRed,
          )
        : AuthModuleTextStyles.fieldValue;
    final bool isBahamas = _selectedCountry.isoCode == 'BS';
    final double errorLeftPad = AuthModuleSizes.countryWidth +
        AuthModuleSizes.countryToPhoneGap +
        AuthModulePaddings.fieldHorizontal14.left;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCountryPhoneInputRow(
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          hideUnfocusedInputBorder: false,
          hintText: 'eg: 242-899-9999',
          flagEmoji: _selectedCountry.flagEmoji,
          dialCode: _selectedCountry.dialCode,
          countryIsoCode: _selectedCountry.isoCode,
          enableCountryPicker: false,
          onChanged: (value) => setState(() => _rawPhone = value),
          inputFormatters:
              isBahamas ? const [BahamasPhoneInputFormatter()] : null,
          backgroundColor: AuthModuleColors.pageBackground,
          unfocusedBorderColor: borderColor,
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
          phoneInputStyle: inputStyle,
          phoneHintStyle: AuthModuleTextStyles.fieldHint,
        ),
        if (showLiveError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: errorLeftPad),
            child: const Text(
              LoginPhoneNumberHelper.invalidPhoneNumberMessage,
              style: AuthModuleTextStyles.invalidCredentials,
            ),
          ),
        ],
      ],
    );
  }

  String _accountDisplayName(AccountInfoState accountState) {
    final fullName = accountState.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;
    return _nameFromEmail(accountState.email);
  }

  String _accountUsername(AccountInfoState accountState) {
    final accountInfo = accountState.accountInfo;
    final username = accountInfo?.username.trim() ?? '';
    if (username.isNotEmpty) return username;
    final primaryPhone = accountInfo?.primaryPhoneNumber.trim() ?? '';
    if (primaryPhone.isNotEmpty) return primaryPhone;
    final phone = accountInfo?.phoneNumber.trim() ?? '';
    return phone.isEmpty ? '--' : phone;
  }

  String _planName({
    required BasePlanModel? selectedApiPlan,
    required HomePlanModel fallbackPlan,
  }) {
    final name = selectedApiPlan?.planName.trim();
    if (name != null && name.isNotEmpty) return name;
    return fallbackPlan.title;
  }

  String _nameFromEmail(String? email) {
    final normalized = email?.trim() ?? '';
    if (normalized.isEmpty || !normalized.contains('@')) return 'User';
    return normalized.split('@').first;
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: _MifiAltContactStyles.radioLabel,
              ),
            ),
            _RadioDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    const double size = 20;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? HomePlanConfirmationTheme.purple
              : const Color(0xFFB8BACB),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: HomePlanConfirmationTheme.purple,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _MifiAltContactStyles {
  static const TextStyle bodyText = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF1C1C1C),
    height: 1.4,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF1C1C1C),
  );

  static const TextStyle radioLabel = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: Color(0xFF1C1C1C),
  );
}
