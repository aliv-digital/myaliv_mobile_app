import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/cubit/alt_number_validation_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/cubit/alt_number_validation_state.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class MifiAltValidationListener extends StatelessWidget {
  const MifiAltValidationListener({
    super.key,
    required this.onValidationSuccess,
    required this.child,
  });

  final VoidCallback onValidationSuccess;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AltNumberValidationCubit, AltNumberValidationState>(
      listenWhen: (prev, curr) => prev.signalId != curr.signalId,
      listener: (context, state) {
        switch (state.status) {
          case AltNumberValidationStatus.valid:
            onValidationSuccess();
            break;
          case AltNumberValidationStatus.invalid:
          case AltNumberValidationStatus.failure:
            AppToast.show(
              message: state.errorMessage.isNotEmpty
                  ? state.errorMessage
                  : 'this mobile number is not valid.',
              type: ToastType.error,
            );
            break;
          case AltNumberValidationStatus.initial:
          case AltNumberValidationStatus.loading:
            break;
        }
      },
      child: child,
    );
  }
}
