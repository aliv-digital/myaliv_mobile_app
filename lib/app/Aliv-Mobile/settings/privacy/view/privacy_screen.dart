import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../resources/widgets/default_app_bar.dart';

import '../../../../../router/app_routes.dart';
import '../bloc/privacy_bloc.dart';
import '../bloc/privacy_event.dart';
import '../bloc/privacy_state.dart';
import '../repository/privacy_repository_impl.dart';
import '../theme/privacy_theme.dart';
import '../widgets/privacy_section.dart';

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
      listenWhen: (p, c) => p.navTarget != c.navTarget,
      listener: (context, state) {
        if (state.navTarget != PrivacyNavTarget.none) {
          // navigation hook (wire later)
          context.read<PrivacyBloc>().add(const PrivacyNavConsumed());
        }
      },
      builder: (context, state) {
        final content = state.content;

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
                  child: SingleChildScrollView(
                    padding: PrivacyTheme.pagePadding,
                    child: content == null
                        ? const SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PrivacySection(
                                title: content.title1,
                                paragraphs: [
                                  content.paragraph1,
                                  content.paragraph2,
                                ],
                              ),
                              // const SizedBox(height: 18),
                              Text(
                                'how we can help',
                                style: PrivacyTheme.sectionHeader,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                content.paragraph3,
                                style: PrivacyTheme.body,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                content.paragraph4,
                                style: PrivacyTheme.body,
                              ),
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
