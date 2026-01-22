import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../login/widgets/login_bottom_stripes.dart';
import '../bloc/otp_prepaid_bloc.dart';
import '../bloc/otp_prepaid_state.dart';
import '../repository/otp_prepaid_repository.dart';
import '../widgets/otp_prepaid_bottom_action.dart';
import '../widgets/otp_prepaid_code_fields.dart';
import '../widgets/otp_prepaid_header.dart';


class OtpAutoRenewPrepaidScreen extends StatelessWidget {
  const OtpAutoRenewPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpAutoRenewPrepaidBloc(
        repository: OtpAutoRenewPrepaidRepository(),
      ),
      child: const _OtpAutoRenewPrepaidView(),
    );
  }
}

class _OtpAutoRenewPrepaidView extends StatelessWidget {
  const _OtpAutoRenewPrepaidView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<OtpAutoRenewPrepaidBloc, OtpAutoRenewPrepaidState>(
          listener: (context, state) {
            if (state.status == OtpAutoRenewPrepaidStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }

            // success হলে next screen এ যাওয়ার logic এখানে দিতে পারো
            // if (state.status == OtpAutoRenewPrepaidStatus.success) { ... }
          },
          child: Column(
            children: [
              // scrollable content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(
                        child: OtpAutoRenewPrepaidHeader(),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 41, right: 41),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: const [
                              SizedBox(height: 24),
                              OtpAutoRenewPrepaidCodeFields(),
                              SizedBox(height: 54),
                              OtpAutoRenewPrepaidBottomActions(),
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------- Fixed bottom stripes ----------
              const BottomStripes(),
            ],
          ),
        ),
      ),
    );
  }
}
