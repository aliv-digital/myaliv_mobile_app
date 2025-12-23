import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import '../../../../router/app_routes.dart';
import '../bloc/forget_password_bloc.dart';
import '../bloc/forget_password_event.dart';
import '../bloc/forget_password_state.dart';
import '../repository/forgetpassword_repository.dart';
import '../widgets/forgetpass_bottom_stripes.dart';
import '../widgets/forgetpass_header.dart';
import '../widgets/forgetpass_phone_row.dart';
import '../widgets/termsAndConditions.dart';



class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgetPasswordBloc(repository: ForgetPasswordRepository()),
      child: const _ForgetPasswordScreenView(),
    );
  }
}

class _ForgetPasswordScreenView extends StatelessWidget {
  const _ForgetPasswordScreenView();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,  // Background transparent
        statusBarIconBrightness: Brightness.dark, // ANDROID → white icons
        statusBarBrightness: Brightness.dark,       // iOS → white icons
      ),
    );
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<ForgetPasswordBloc, ForgetPasswordState>(
          listener: (context, state) {
            // error/snack bar
          },
          child: Column(
            children: [
              // ---------- Scrollable content ----------
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: const ForgetPasswordHeader(),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(left: 40,right: 54),
                          child: Column(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //const SizedBox(height: 12),

                              const SizedBox(height: 9.61),
                              const ForgetPasswordPhoneRow(),
                              const SizedBox(height: 20),



                              //const SizedBox(height: 15),

                              // send in button
                              BlocBuilder<ForgetPasswordBloc, ForgetPasswordState>(
                                builder: (context, state) {
                                  final loading = state.status == ForgetPasswordStatus.loading;

                                  return DefaultButton(
                                      label: 'send',
                                      isLoading: loading,
                                      onPressed: (){
                                        //context.read<ForgetPasswordBloc>().add(const ForgetPasswordSubmitted());
                                        context.push(AppRoutes.forgetPasswordOtp);
                                      }
                                  );
                                },
                              ),
                              const SizedBox(height: 147),
                              BlocBuilder<ForgetPasswordBloc, ForgetPasswordState>(
                                builder: (context, state) {
                                  return TermsAndPrivacyText(
                                    isTermsLoading: state.isTermsLoading,
                                    isPrivacyLoading: state.isPrivacyLoading,
                                    onTermsTap: () {
                                      //context.read<LegalBloc>().add(LoadTermsPressed());
                                    },
                                    onPrivacyTap: () {
                                      //context.read<LegalBloc>().add(LoadPrivacyPressed());
                                    },
                                  );
                                },
                              ),
                              //const SizedBox(height: 230)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------- Fixed bottom stripes ----------
              const ForgetPasswordBottomStripes(),
            ],
          ),
        ),
      ),
    );
  }
}
