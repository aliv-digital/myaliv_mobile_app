import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/cubit/alt_number_validation_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/cubit/alt_number_validation_state.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';

class MifiAltContinueButton extends StatelessWidget {
  const MifiAltContinueButton({
    super.key,
    required this.canContinue,
    required this.onPressed,
  });

  final bool canContinue;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child:
            BlocBuilder<AltNumberValidationCubit, AltNumberValidationState>(
          builder: (context, state) {
            final bool busy = state.isLoading;
            return DefaultButton(
              label: 'continue',
              isLoading: busy,
              onPressed: !busy && canContinue ? onPressed : null,
            );
          },
        ),
      ),
    );
  }
}
