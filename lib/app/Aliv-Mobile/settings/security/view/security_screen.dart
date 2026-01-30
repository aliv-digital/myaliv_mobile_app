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
      listenWhen: (p, c) => p.navTarget != c.navTarget,
      listener: (context, state) {
        if (state.navTarget != SecurityNavTarget.none) {
          // navigation hook (wire later)
          context.read<SecurityBloc>().add(const SecurityNavConsumed());
        }
      },
      builder: (context, state) {
        final content = state.content;

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            backgroundColor: SecurityTheme.bg,
            body: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: SecurityAppBar(
                    title: 'security',
                    onHomeTap: () {
                      context.read<SecurityBloc>().add(const SecurityHomePressed());
                      context.go(AppRoutes.home);
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: SecurityTheme.pagePadding,
                    child: content == null
                        ? const SizedBox.shrink()
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SecuritySection(
                          title: content.title1,
                          paragraphs: [
                            content.paragraph1,
                            content.paragraph2,
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text('how we can help', style: SecurityTheme.sectionHeader),
                        const SizedBox(height: 10),
                        Text(content.paragraph3, style: SecurityTheme.body),
                        const SizedBox(height: 14),
                        Text(content.paragraph4, style: SecurityTheme.body),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
