import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/model/login_country_selection.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/login_phone_number_helper.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/cubit/alt_number_validation_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/model/mifi_alt_contact_route_args.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/view/mifi_alt_contact_args_builder.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/widgets/mifi_alt_contact_scaffold.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/widgets/mifi_alt_phone_field.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/widgets/mifi_alt_validation_listener.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class MifiAltContactScreen extends StatelessWidget {
  const MifiAltContactScreen({super.key, required this.args});

  final MifiAltContactRouteArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AltNumberValidationCubit>(
      create: (_) => instance<AltNumberValidationCubit>(),
      child: _MifiAltContactView(args: args),
    );
  }
}

class _MifiAltContactView extends StatefulWidget {
  const _MifiAltContactView({required this.args});

  final MifiAltContactRouteArgs args;

  @override
  State<_MifiAltContactView> createState() => _MifiAltContactViewState();
}

class _MifiAltContactViewState extends State<_MifiAltContactView> {
  static const LoginPhoneNumberHelper _phoneHelper = LoginPhoneNumberHelper();

  static const String _emptyPhoneMessage =
      'enter a mobile number we can reach you on';
  static const String _invalidPhoneMessage =
      'enter a valid 10-digit mobile number';
  static const String _sameAsMifiMessage =
      "enter a number that's different from your mifi number";

  late final TextEditingController _phoneController;
  final FocusNode _phoneFocusNode = FocusNode();

  final LoginCountrySelection _selectedCountry =
      LoginCountrySelection.defaultBahamas;
  String _rawPhone = '';
  bool? _marketingOptIn;
  bool _hasPhoneFocus = false;

  /// Inline error from the last continue tap; cleared as soon as the user edits.
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
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

  LoginPhoneValidationResult get _validation =>
      _phoneHelper.validateAndBuildApiUsername(
        rawPhoneNumber: _rawPhone,
        selectedCountry: _selectedCountry,
      );

  // The phone number is validated on tap so empty/invalid input can explain
  // itself inline; the offers choice still gates the button.
  bool get _canContinue => _marketingOptIn != null;

  /// MIFI-002 (empty) → MIFI-003 (format) → MIFI-005 (same as MiFi line).
  String? _phoneError(LoginPhoneValidationResult v) {
    if (_rawPhone.replaceAll(RegExp(r'\D'), '').isEmpty) {
      return _emptyPhoneMessage;
    }
    if (!v.isValid) return _invalidPhoneMessage;

    // Both numbers go through the same helper so formatting differences
    // (e.g. `242-801-1616` vs `2428011616`) cannot hide a match.
    final mifiNumber = _phoneHelper.validateAndBuildApiUsername(
      rawPhoneNumber: MifiAltContactArgsBuilder.accountPhoneNumber(
        instance<AccountInfoCubit>().state,
      ),
      selectedCountry: _selectedCountry,
    );
    if (mifiNumber.isValid &&
        mifiNumber.phoneNumberForApi == v.phoneNumberForApi) {
      return _sameAsMifiMessage;
    }
    return null;
  }

  String? get _visiblePhoneError {
    if (_submitError != null) return _submitError;
    final hasLiveError = _phoneHelper.hasLiveValidationError(
      rawPhoneNumber: _rawPhone,
      selectedCountry: _selectedCountry,
    );
    return hasLiveError ? _invalidPhoneMessage : null;
  }

  void _onContinuePressed() {
    final v = _validation;
    final isOptedIn = _marketingOptIn;
    if (isOptedIn == null) return;

    final phoneError = _phoneError(v);
    if (phoneError != null) {
      setState(() => _submitError = phoneError);
      return;
    }

    context.read<AltNumberValidationCubit>().submit(
      altNumber: v.phoneNumberForApi ?? '',
      isOptedIn: isOptedIn,
    );
  }

  void _onValidationSuccess() {
    final v = _validation;
    if (!v.isValid) return;
    context.pushReplacement(
      AppRoutes.homePlanConfirmationScreen,
      extra: MifiAltContactArgsBuilder.buildConfirmationArgs(
        routeArgs: widget.args,
        accountState: instance<AccountInfoCubit>().state,
        altContactNumber: v.phoneNumberForApi ?? '',
        marketingOptIn: _marketingOptIn ?? false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MifiAltValidationListener(
      onValidationSuccess: _onValidationSuccess,
      child: MifiAltContactScaffold(
        marketingOptIn: _marketingOptIn,
        canContinue: _canContinue,
        onMarketingChanged: (value) => setState(() => _marketingOptIn = value),
        onContinuePressed: _onContinuePressed,
        phoneFieldBuilder: ({required bool readOnly}) => MifiAltPhoneField(
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          country: _selectedCountry,
          rawPhone: _rawPhone,
          hasFocus: _hasPhoneFocus,
          readOnly: readOnly,
          errorText: _visiblePhoneError,
          onChanged: (value) => setState(() {
            _rawPhone = value;
            _submitError = null;
          }),
        ),
      ),
    );
  }
}
