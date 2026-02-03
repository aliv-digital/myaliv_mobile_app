import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../router/app_routes.dart';
import '../bloc/help_bloc.dart';
import '../bloc/help_event.dart';
import '../bloc/help_state.dart';
import '../repository/help_repository_impl.dart';
import '../theme/help_theme.dart';
import '../widgets/help_app_bar.dart';
import '../widgets/help_section.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HelpBloc(
        repository: HelpRepositoryImpl(),
      )..add(const HelpStarted()),
      child: const _HelpView(),
    );
  }
}

class _HelpView extends StatelessWidget {
  const _HelpView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HelpBloc, HelpState>(
      listenWhen: (p, c) => p.navTarget != c.navTarget,
      listener: (context, state) {
        if (state.navTarget != HelpNavTarget.none) {
          // navigation hook (wire later)
          context.read<HelpBloc>().add(const HelpNavConsumed());
        }
      },
      builder: (context, state) {
        final content = state.content;

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            backgroundColor: HelpTheme.bg,
            body: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: HelpAppBar(
                    title: 'help',
                    onHomeTap: () {
                      context.read<HelpBloc>().add(const HelpHomePressed());
                      context.go(AppRoutes.home);
                    }),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: HelpTheme.pagePadding,
                    child: content == null
                        ? const SizedBox.shrink()
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HelpSection(
                          title: content.title1,
                          paragraphs: [
                            content.paragraph1,
                            content.paragraph2,
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(content.title2, style: HelpTheme.sectionHeader),
                        const SizedBox(height: 10),
                        Text(content.paragraph3, style: HelpTheme.body),
                        const SizedBox(height: 14),
                        Text(content.paragraph4, style: HelpTheme.body),
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
