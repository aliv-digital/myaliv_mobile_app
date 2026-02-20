import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../bloc/auto_renew_auth_prepaid_bloc.dart';
import '../bloc/auto_renew_auth_prepaid_event.dart';
import '../bloc/auto_renew_auth_prepaid_state.dart';
import '../repository/auto_renew_auth_prepaid_repository.dart';
import '../theme/auto_renew_auth_prepaid_theme.dart';
import '../widgets/auth_name_input.dart';

class AutoRenewAuthPrepaidScreen extends StatelessWidget {
  const AutoRenewAuthPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AutoRenewAuthPrepaidBloc(
        repository: AutoRenewAuthPrepaidRepositoryImpl(),
      )..add(const AutoRenewAuthPrepaidStarted()),
      child: const _AutoRenewAuthPrepaidView(),
    );
  }
}

class _AutoRenewAuthPrepaidView extends StatelessWidget {
  const _AutoRenewAuthPrepaidView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AutoRenewAuthPrepaidBloc, AutoRenewAuthPrepaidState>(
      listenWhen: (p, c) =>
          p.errorMessage != c.errorMessage || p.navTarget != c.navTarget,
      listener: (context, state) {
        final bloc = context.read<AutoRenewAuthPrepaidBloc>();

        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }

        if (state.navTarget == AutoRenewAuthNavTarget.home) {
          // TODO: router home navigation
          bloc.add(const AutoRenewAuthNavigationConsumed());
          return;
        }

        if (state.navTarget == AutoRenewAuthNavTarget.success) {
          // TODO: navigate next screen / show success
          bloc.add(const AutoRenewAuthNavigationConsumed());
          return;
        }
      },
      child: Scaffold(
        backgroundColor: AutoRenewAuthPrepaidTheme.scaffoldBackground,
        body: SafeArea(
          child:
              BlocBuilder<AutoRenewAuthPrepaidBloc, AutoRenewAuthPrepaidState>(
            builder: (context, state) {
              final bloc = context.read<AutoRenewAuthPrepaidBloc>();

              return CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _PinnedHeaderDelegate(
                      height: AutoRenewAuthPrepaidTheme.appBarHeight,
                      child: DefaultAppBar(
                        showHome: false,
                        title: 'auto renew authorization form',
                        onBack: () => Navigator.of(context).maybePop(),
                        onHomeTap: () =>
                            bloc.add(const AutoRenewAuthHomePressed()),
                      ),
                    ),
                  ),
                  if (state.loadStatus == AutoRenewAuthLoadStatus.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.loadStatus == AutoRenewAuthLoadStatus.failure)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          state.errorMessage ?? 'Something went wrong.',
                          style: AutoRenewAuthPrepaidTheme.paragraphTextStyle(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: AutoRenewAuthPrepaidTheme.bodyPadding,
                      sliver: SliverToBoxAdapter(
                        child: _Body(
                          state: state,
                          onNameChanged: (v) =>
                              bloc.add(AutoRenewAuthNameChanged(v)),
                          onSubmit: () {
                            //bloc.add(const AutoRenewAuthSubmitPressed());
                            context.push(
                                AppRoutes.enterPasswordAutoRenewPrepaidScreen);
                          },
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final AutoRenewAuthPrepaidState state;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onSubmit;

  const _Body({
    required this.state,
    required this.onNameChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final content = state.content!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(content.paragraph1,
            style: AutoRenewAuthPrepaidTheme.paragraphTextStyle()),
        const SizedBox(
          height: AutoRenewAuthPrepaidTheme.paragraphToConsentHeaderGap,
        ),
        Text(content.consentTitle,
            style: AutoRenewAuthPrepaidTheme.sectionHeaderTextStyle()),
        const SizedBox(
          height: AutoRenewAuthPrepaidTheme.consentHeaderToParagraphGap,
        ),
        Text(content.paragraph2,
            style: AutoRenewAuthPrepaidTheme.paragraphTextStyle()),
        const SizedBox(
          height: AutoRenewAuthPrepaidTheme.paragraphToSignatureGap,
        ),
        Text(content.signatureName,
            style: AutoRenewAuthPrepaidTheme.signatureTextStyle()),
        const SizedBox(
          height: AutoRenewAuthPrepaidTheme.signatureToNameLabelGap,
        ),
        Text(content.nameLabel,
            style: AutoRenewAuthPrepaidTheme.fieldLabelTextStyle()),
        const SizedBox(height: AutoRenewAuthPrepaidTheme.nameLabelToInputGap),
        AuthNameInput(
          value: state.name,
          hintText: content.nameHint,
          onChanged: onNameChanged,
        ),
        const SizedBox(
          height: AutoRenewAuthPrepaidTheme.inputToSubmitButtonGap,
        ),
        _SubmitButton(
          enabled: state.canSubmit,
          loading: state.submitStatus == AutoRenewAuthSubmitStatus.submitting,
          text: content.submitText,
          onTap: onSubmit,
        ),
        const SizedBox(
          height: AutoRenewAuthPrepaidTheme.submitButtonToBottomGap,
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final String text;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.enabled,
    required this.loading,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultButton(
      label: text,
      isLoading: loading,
      onPressed: enabled ? onTap : null,
      height: AutoRenewAuthPrepaidTheme.submitButtonHeight,
      elevation: 0,
      backgroundColor: AutoRenewAuthPrepaidTheme.submitButtonBackgroundColor(
        isEnabled: enabled,
      ),
      textStyle: AutoRenewAuthPrepaidTheme.submitButtonTextStyle(),
      borderRadius: AutoRenewAuthPrepaidTheme.submitButtonBorderRadius,
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _PinnedHeaderDelegate({
    required this.height,
    required this.child,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
