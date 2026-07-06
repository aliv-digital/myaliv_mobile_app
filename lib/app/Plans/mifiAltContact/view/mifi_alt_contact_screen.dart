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

  bool get _canContinue => _validation.isValid && _marketingOptIn != null;

  void _onContinuePressed() {
    final v = _validation;
    final isOptedIn = _marketingOptIn;
    if (!v.isValid || isOptedIn == null) return;

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
          onChanged: (value) => setState(() => _rawPhone = value),
        ),
      ),
    );
  }
}
