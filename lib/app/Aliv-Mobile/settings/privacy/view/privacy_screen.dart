import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../resources/widgets/default_app_bar.dart';

import '../../../../../router/app_routes.dart';
import '../bloc/privacy_bloc.dart';
import '../bloc/privacy_event.dart';
import '../bloc/privacy_state.dart';
import '../repository/privacy_repository.dart';
import '../repository/privacy_repository_impl.dart';
import '../theme/privacy_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      PrivacyBloc(repository: PrivacyRepositoryImpl())
        ..add(const PrivacyStarted()),
      child: const _PrivacyView(),
    );
  }
}

class _PrivacyView extends StatelessWidget {
  const _PrivacyView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrivacyBloc, PrivacyState>(
      listenWhen: (previous, current) =>
      previous.navTarget != current.navTarget,
      listener: (context, state) {
        if (state.navTarget != PrivacyNavTarget.none) {
          context.read<PrivacyBloc>().add(const PrivacyNavConsumed());
        }
      },
      builder: (context, state) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            backgroundColor: PrivacyTheme.bg,
            body: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: PrivacyTheme.appBarHeight,
                    child: DefaultAppBar(
                      title: 'privacy',
                      onBack: () {
                        context.pop();
                      },
                      height: PrivacyTheme.appBarHeight,
                      backgroundColor: PrivacyTheme.appBarBg,
                      showBackArrow: true,
                      showHome: true,
                      onHomeTap: () {
                        context.read<PrivacyBloc>().add(
                          const PrivacyHomePressed(),
                        );
                        context.go(AppRoutes.home);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: _buildBody(state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(PrivacyState state) {
    switch (state.status) {
      case PrivacyStatus.initial:
      case PrivacyStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case PrivacyStatus.failure:
        return Center(
          child: Padding(
            padding: PrivacyTheme.pagePadding,
            child: Text(
              state.errorMessage ?? 'Something went wrong',
              style: PrivacyTheme.body,
              textAlign: TextAlign.center,
            ),
          ),
        );

      case PrivacyStatus.ready:
        final PrivacyContent? content = state.content;

        if (content == null || content.htmlContent.trim().isEmpty) {
          return const Center(
            child: Padding(
              padding: PrivacyTheme.pagePadding,
              child: Text(
                'No content found',
                style: PrivacyTheme.body,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: PrivacyTheme.pagePadding,
          child: Html(
            data: content.htmlContent,
            style: {
              'body': Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontFamily: PrivacyTheme.fontFamily,
                fontSize: FontSize(PrivacyTheme.body.fontSize ?? 14),
                fontWeight: PrivacyTheme.body.fontWeight,
                color: PrivacyTheme.textSecondary,
                lineHeight: LineHeight(
                  (PrivacyTheme.body.height ?? 1.43).toDouble(),
                ),
              ),
              'h1': Style(
                margin: Margins.only(bottom: 12),
                padding: HtmlPaddings.zero,
                fontFamily: PrivacyTheme.fontFamily,
                fontSize: FontSize(22),
                fontWeight: FontWeight.w700,
                color: PrivacyTheme.textPrimary,
                lineHeight: const LineHeight(1.25),
              ),
              'h2': Style(
                margin: Margins.only(bottom: 12),
                padding: HtmlPaddings.zero,
                fontFamily: PrivacyTheme.fontFamily,
                fontSize: FontSize(20),
                fontWeight: FontWeight.w700,
                color: PrivacyTheme.textPrimary,
                lineHeight: const LineHeight(1.25),
              ),
              'h3': Style(
                margin: Margins.only(bottom: 10, top: 8),
                padding: HtmlPaddings.zero,
                fontFamily: PrivacyTheme.fontFamily,
                fontSize: FontSize(PrivacyTheme.title.fontSize ?? 18),
                fontWeight: FontWeight.w700,
                color: PrivacyTheme.textPrimary,
                lineHeight: const LineHeight(1.25),
              ),
              'p': Style(
                margin: Margins.only(bottom: 14),
                padding: HtmlPaddings.zero,
                fontFamily: PrivacyTheme.fontFamily,
                fontSize: FontSize(PrivacyTheme.body.fontSize ?? 14),
                fontWeight: PrivacyTheme.body.fontWeight,
                color: PrivacyTheme.textSecondary,
                lineHeight: LineHeight(
                  (PrivacyTheme.body.height ?? 1.43).toDouble(),
                ),
              ),
              'span': Style(
                fontFamily: PrivacyTheme.fontFamily,
                fontSize: FontSize(PrivacyTheme.body.fontSize ?? 14),
                fontWeight: PrivacyTheme.body.fontWeight,
                color: PrivacyTheme.textSecondary,
                lineHeight: LineHeight(
                  (PrivacyTheme.body.height ?? 1.43).toDouble(),
                ),
              ),
              'strong': Style(
                fontWeight: FontWeight.w700,
                color: PrivacyTheme.textPrimary,
              ),
            },
          ),
        );
    }
  }
}