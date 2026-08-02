import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import '../../../../../../resources/widgets/default_app_bar.dart';
import '../bloc/fingerprint_security_bloc.dart';
import '../bloc/fingerprint_security_event.dart';
import '../bloc/fingerprint_security_state.dart';
import '../repository/fingerprint_security_repository_impl.dart';
import '../theme/fingerprint_security_theme.dart';
import '../widgets/fingerprint_security_body_text.dart';

class FingerPrintSecurityScreen extends StatelessWidget {
  const FingerPrintSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FingerPrintSecurityBloc(
        repository: FingerPrintSecurityRepositoryImpl(),
      )..add(const FingerPrintSecurityStarted()),
      child: const _FingerPrintSecurityView(),
    );
  }
}

class _FingerPrintSecurityView extends StatelessWidget {
  const _FingerPrintSecurityView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FingerPrintSecurityBloc, FingerPrintSecurityState>(
      listenWhen: (p, c) => p.navTarget != c.navTarget,
      listener: (context, state) {
        if (state.navTarget == FingerPrintSecurityNavTarget.back) {
          Navigator.of(context).maybePop();
          context
              .read<FingerPrintSecurityBloc>()
              .add(const FingerPrintSecurityNavConsumed());
        }
      },
      builder: (context, state) {
        final content = state.content;

        return MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            backgroundColor: FingerPrintSecurityTheme.bg,
            body: Column(
              children: [
                DefaultAppBar(
                  title: 'fingerprint security',
                  height: FingerPrintSecurityTheme.appBarHeight,
                  backgroundColor: FingerPrintSecurityTheme.appBarBg,
                  showBackArrow: true,
                  showHome: false,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: FingerPrintSecurityTheme.pagePadding,
                    child: content == null
                        ? const SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FingerPrintSecurityBodyText(
                                header: content.header,
                                body: content.body,
                              ),
                              const SizedBox(
                                height:
                                    FingerPrintSecurityTheme.bodyToButtonGap,
                              ),
                              DefaultButton(
                                label: 'yes, i agree',
                                isLoading: false,
                                onPressed: () => context
                                    .read<FingerPrintSecurityBloc>()
                                    .add(const AgreePressed()),
                                backgroundColor:
                                    FingerPrintSecurityTheme.bottomButtonBg,
                                textStyle:
                                    FingerPrintSecurityTheme.bottomButtonText,
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
