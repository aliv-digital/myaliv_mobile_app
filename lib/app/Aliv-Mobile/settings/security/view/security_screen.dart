import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';
import '../repository/security_repository_impl.dart';
import '../theme/security_theme.dart';
import '../widgets/security_app_bar.dart';
import '../widgets/security_section.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SecurityBloc(
        repository: SecurityRepositoryImpl(),
      )..add(const SecurityStarted()),
      child: const _SecurityView(),
    );
  }
}

class _SecurityView extends StatelessWidget {
  const _SecurityView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SecurityBloc, SecurityState>(
      listenWhen: (previous, current) => previous.navTarget != current.navTarget,
      listener: (context, state) {
        if (state.navTarget != SecurityNavTarget.none) {
          context.read<SecurityBloc>().add(const SecurityNavConsumed());
        }
      },
      builder: (context, state) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: Scaffold(
            backgroundColor: SecurityTheme.bg,
            body: Column(
              children: [
                SafeArea(
                  top: false,
                  bottom: false,
                  child: SecurityAppBar(
                    title: 'security',
                    onHomeTap: () {
                      context.read<SecurityBloc>().add(
                        const SecurityHomePressed(),
                      );
                      context.go(AppRoutes.home);
                    },
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

  Widget _buildBody(SecurityState state) {
    switch (state.status) {
      case SecurityStatus.initial:
      case SecurityStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case SecurityStatus.failure:
        return Center(
          child: Padding(
            padding: SecurityTheme.pagePadding,
            child: Text(
              state.errorMessage ?? 'Something went wrong',
              style: SecurityTheme.body,
              textAlign: TextAlign.center,
            ),
          ),
        );

      case SecurityStatus.ready:
        final content = state.content;

        if (content == null || content.htmlContent.trim().isEmpty) {
          return const Center(
            child: Padding(
              padding: SecurityTheme.pagePadding,
              child: Text(
                'No content found',
                style: SecurityTheme.body,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: SecurityTheme.pagePadding,
          child: SecuritySection(
            htmlContent: content.htmlContent,
          ),
        );
    }
  }
}