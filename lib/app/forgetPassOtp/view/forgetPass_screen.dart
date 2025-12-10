import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/forgetPassOtp/widgets/forgetOtp_bottom_action.dart';
import 'package:myaliv_mobile_app/app/forgetPassOtp/widgets/forgetOtp_code_fields.dart';
import 'package:myaliv_mobile_app/app/forgetPassOtp/widgets/forgetOtp_header.dart';
import '../../login/widgets/login_bottom_stripes.dart';
import '../../loginOtp/widgets/otp_header.dart';
import '../bloc/forgetPass_otp_bloc.dart';
import '../bloc/forgetPass_otp_state.dart';
import '../repository/forgetPass_otp_repository.dart';


class ForgetPasswordOtpScreen extends StatelessWidget {
  const ForgetPasswordOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgetPasswordOtpBloc(repository: ForgetPasswordOtpRepository()),
      child: const _ForgetPasswordOtpView(),
    );
  }
}

class _ForgetPasswordOtpView extends StatelessWidget {
  const _ForgetPasswordOtpView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<ForgetPasswordOtpBloc, ForgetPasswordOtpState>(
          listener: (context, state) {
            if (state.status == ForgetPasswordOtpStatus.failure && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
            // success হলে next screen এ যাওয়ার logic এখানে দিতে পারো
          },
          child: Column(
            children: [
              // scrollable content
              Expanded(
                child: Padding(
                  //padding: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.only(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: ForgetPasswordOtpHeader(),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(left: 41,right: 41),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: const [
                              SizedBox(height: 24),
                              ForgetPasswordOtpCodeFields(),//OtpCodeFields(),
                              SizedBox(height: 54),
                              ForgetPasswordOtpBottomActions(),//OtpBottomActions(),
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
