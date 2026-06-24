import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/theme/home_plan_confirmation_theme.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/cubit/alt_number_validation_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/cubit/alt_number_validation_state.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/widgets/mifi_alt_contact_body.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/widgets/mifi_alt_continue_button.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

typedef MifiAltPhoneFieldBuilder = Widget Function({required bool readOnly});

class MifiAltContactScaffold extends StatelessWidget {
  const MifiAltContactScaffold({
    super.key,
    required this.marketingOptIn,
    required this.canContinue,
    required this.phoneFieldBuilder,
    required this.onMarketingChanged,
    required this.onContinuePressed,
  });

  final bool? marketingOptIn;
  final bool canContinue;
  final MifiAltPhoneFieldBuilder phoneFieldBuilder;
  final ValueChanged<bool> onMarketingChanged;
  final VoidCallback onContinuePressed;

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
            child: BlocBuilder<AltNumberValidationCubit,
                AltNumberValidationState>(
              builder: (context, state) => MifiAltContactBody(
                busy: state.isLoading,
                marketingOptIn: marketingOptIn,
                phoneField: phoneFieldBuilder(readOnly: state.isLoading),
                onMarketingChanged: onMarketingChanged,
              ),
            ),
          ),
          MifiAltContinueButton(
            canContinue: canContinue,
            onPressed: onContinuePressed,
          ),
        ],
      ),
    );
  }
}
