import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_bottom_stripes.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/support_bloc.dart';
import '../bloc/support_event.dart';
import '../bloc/support_state.dart';
import '../model/support_models.dart';
import '../repository/support_repository.dart';
import '../widgets/quick_help_content.dart';

class QuickHelpScreen extends StatelessWidget {
  const QuickHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => SupportRepository(dio: Dio()),
      child: BlocProvider(
        create: (context) =>
        SupportBloc(repository: context.read<SupportRepository>())
          ..add(const SupportStarted()),
        child: const _QuickHelpView(),
      ),
    );
  }
}

class _QuickHelpView extends StatelessWidget {
  const _QuickHelpView();

  static const Color _purple = Color(0xFF645D9C);
  static const Color _bg = Color(0xFFF1F2FA);

  Future<void> _handleLaunch(
      BuildContext context,
      SupportLaunchRequest request,
      ) async {
    final launched = await launchUrl(
      request.uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      AppToast.show(
          message: request.failureMessage.toString(),
          type: ToastType.error
      );
      //ScaffoldMessenger.of(
      //  context,
      //).showSnackBar(SnackBar(content: Text(request.failureMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupportBloc, SupportState>(
      listenWhen: (previous, current) =>
      previous.launchRequest?.id != current.launchRequest?.id,
      listener: (context, state) {
        final request = state.launchRequest;
        if (request != null) {
          _handleLaunch(context, request);
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _purple,
          centerTitle: false,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => context.go(AppRoutes.home),
              child: SvgPicture.asset(
                'assets/icons/home.svg',
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 24),
          ],
          title: const Text(
            'support',
            style: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<SupportBloc, SupportState>(
                  builder: (context, state) {
                    return QuickHelpContent(
                      info: state.quickHelp,
                      onCallTap: () => context.read<SupportBloc>().add(
                        const SupportCallPressed(),
                      ),
                    );
                  },
                ),
              ),
              const BottomStripes(),
            ],
          ),
        ),
      ),
    );
  }
}