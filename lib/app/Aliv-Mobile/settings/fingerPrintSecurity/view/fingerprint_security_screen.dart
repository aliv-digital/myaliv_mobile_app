import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/fingerprint_security_bloc.dart';
import '../bloc/fingerprint_security_event.dart';
import '../bloc/fingerprint_security_state.dart';
import '../repository/fingerprint_security_repository_impl.dart';
import '../theme/fingerprint_security_theme.dart';
import '../widgets/fingerprint_security_app_bar.dart';
import '../widgets/fingerprint_security_body_text.dart';
import '../widgets/fingerprint_security_bottom_button.dart';

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
          context.read<FingerPrintSecurityBloc>().add(const FingerPrintSecurityNavConsumed());
        }
      },
      builder: (context, state) {
        final content = state.content;

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            backgroundColor: FingerPrintSecurityTheme.bg,
            body: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: FingerPrintSecurityAppBar(
                    title: 'fingerprint security',
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: FingerPrintSecurityTheme.pagePadding.copyWith(bottom: 90),
                    child: content == null
                        ? const SizedBox.shrink()
                        : FingerPrintSecurityBodyText(
                      header: content.header,
                      body: content.body,
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: FingerPrintSecurityBottomButton(
              text: 'yes, i agree',
              onTap: () => context.read<FingerPrintSecurityBloc>().add(const AgreePressed()),
            ),
          ),
        );
      },
    );
  }
}
