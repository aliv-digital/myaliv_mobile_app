import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import '../../../../../../resources/widgets/default_app_bar.dart';

import '../bloc/face_id_security_bloc.dart';
import '../bloc/face_id_security_event.dart';
import '../bloc/face_id_security_state.dart';
import '../repository/face_id_security_repository_impl.dart';
import '../theme/face_id_security_theme.dart';
import '../widgets/face_id_security_body_text.dart';

class FaceIdSecurityScreen extends StatelessWidget {
  const FaceIdSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FaceIdSecurityBloc(
        repository: FaceIdSecurityRepositoryImpl(),
      )..add(const FaceIdSecurityStarted()),
      child: const _FaceIdSecurityView(),
    );
  }
}

class _FaceIdSecurityView extends StatelessWidget {
  const _FaceIdSecurityView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FaceIdSecurityBloc, FaceIdSecurityState>(
      listenWhen: (p, c) => p.navTarget != c.navTarget,
      listener: (context, state) {
        if (state.navTarget == FaceIdSecurityNavTarget.back) {
          Navigator.of(context).maybePop();
          context
              .read<FaceIdSecurityBloc>()
              .add(const FaceIdSecurityNavConsumed());
        }
      },
      builder: (context, state) {
        final content = state.content;

        return MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            backgroundColor: FaceIdSecurityTheme.bg,
            body: Column(
              children: [
                DefaultAppBar(
                  title: 'face id Security',
                  height: FaceIdSecurityTheme.appBarHeight,
                  backgroundColor: FaceIdSecurityTheme.appBarBg,
                  showBackArrow: true,
                  showHome: false,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: FaceIdSecurityTheme.pagePadding,
                    child: content == null
                        ? const SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FaceIdSecurityBodyText(
                                header: content.header,
                                body: content.body,
                              ),
                              const SizedBox(
                                height: FaceIdSecurityTheme.bodyToButtonGap,
                              ),
                              DefaultButton(
                                label: 'yes, i agree',
                                isLoading: false,
                                onPressed: () => context
                                    .read<FaceIdSecurityBloc>()
                                    .add(const FaceIdAgreePressed()),
                                backgroundColor:
                                    FaceIdSecurityTheme.bottomButtonBg,
                                textStyle: FaceIdSecurityTheme.bottomButtonText,
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
