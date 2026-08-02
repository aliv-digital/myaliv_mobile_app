import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
import 'package:myaliv_mobile_app/resources/widgets/terms_and_conditions_modal.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../router/app_routes.dart';
import '../bloc/forget_password_bloc.dart';
import '../bloc/forget_password_state.dart';
import '../repository/forgetpassword_repository.dart';
import '../theme/forget_password_theme.dart';
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
        statusBarColor: ForgetPasswordColors.pageBackground,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    //final phoneRowGap = _phoneRowGapFromSubtitle(context);

    return StripedScaffold(
      backgroundColor: ForgetPasswordColors.pageBackground,

      // ✅ keep default keyboard behavior (auto resize + auto scroll)
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: BlocListener<ForgetPasswordBloc, ForgetPasswordState>(
          listener: (context, state) {
            // error/snack bar
          },
          child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    const SliverToBoxAdapter(
                      child: ForgetPasswordHeader(),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: ForgetPasswordPaddings.pageHorizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            //SizedBox(height: phoneRowGap),
                            const ForgetPasswordPhoneRow(),
                            const SizedBox(height: ForgetPasswordSizes.phoneToSendGap),

                            // send button
                            BlocBuilder<ForgetPasswordBloc, ForgetPasswordState>(
                              builder: (context, state) {
                                final loading = state.status == ForgetPasswordStatus.loading;

                                return DefaultButton(
                                  label: 'send',
                                  isLoading: loading,
                                  textStyle: ForgetPasswordTheme.sendButton,
                                  onPressed: () {
                                    //context.read<ForgetPasswordBloc>().add(const ForgetPasswordSubmitted());
                                    context.push(AppRoutes.forgetPasswordOtp);
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: ForgetPasswordSizes.sendToTermsGap),

                            BlocBuilder<ForgetPasswordBloc, ForgetPasswordState>(
                              builder: (context, state) {
                                return TermsAndPrivacyText(
                                  isTermsLoading: state.isTermsLoading,
                                  isPrivacyLoading: state.isPrivacyLoading,
                                  onTermsTap: () async {
                                    await showTermsAndConditionsModal(context);
                                  },
                                  onPrivacyTap: () async {
                                    //context.read<LegalBloc>().add(LoadPrivacyPressed());
                                    final uri = Uri.parse(
                                      'https://www.bealiv.com/privacy-policy/',
                                    );

                                    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                    throw 'Could not open store locator';
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
