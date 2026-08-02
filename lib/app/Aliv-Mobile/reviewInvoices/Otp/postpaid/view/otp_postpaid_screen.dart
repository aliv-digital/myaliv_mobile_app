import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

import '../bloc/otp_postpaid_bloc.dart';
import '../bloc/otp_postpaid_state.dart';
import '../repository/otp_postpaid_repository.dart';
import '../widgets/otp_postpaid_bottom_action.dart';
import '../widgets/otp_postpaid_code_fields.dart';
import '../widgets/otp_postpaid_header.dart';

class OtpPostpaidScreen extends StatelessWidget {
  const OtpPostpaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OTPPostpaidBloc(repository: OTPPostpaidRepository()),
      child: const _OTPPostpaidView(),
    );
  }
}

class _OTPPostpaidView extends StatelessWidget {
  const _OTPPostpaidView();

  @override
  Widget build(BuildContext context) {
    return StripedScaffold(
      // ✅ keep default keyboard behavior (auto resize + auto scroll)
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: BlocListener<OTPPostpaidBloc, OTPPostpaidState>(
          listener: (context, state) {
            if (state.status == OTPPostpaidStatus.failure && state.errorMessage != null) {

              AppToast.show(message: state.errorMessage.toString(),type: ToastType.error);
              //ScaffoldMessenger.of(context).showSnackBar(
              //  SnackBar(content: Text(state.errorMessage!)),
              //);
            }

            // success হলে next screen এ যাওয়ার logic এখানে দিতে পারো
            // if (state.status == OTPPostpaidStatus.success) { ... }
          },
          child: Padding(
                  padding: const EdgeInsets.only(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      const SliverToBoxAdapter(
                        child: OTPPostpaidHeader(),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 41, right: 41),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: const [
                              SizedBox(height: 24),
                              OTPPostpaidCodeFields(),
                              SizedBox(height: 54),
                              OTPPostpaidBottomActions(),
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
