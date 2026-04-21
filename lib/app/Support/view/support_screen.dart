import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_bottom_stripes.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/support_bloc.dart';
import '../bloc/support_event.dart';
import '../bloc/support_state.dart';
import '../model/support_models.dart';
import '../repository/support_repository.dart';
import '../widgets/support_tile.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => SupportRepository(dio: Dio()),
      child: BlocProvider(
        create: (context) =>
        SupportBloc(repository: context.read<SupportRepository>())
          ..add(const SupportStarted()),
        child: const _SupportView(),
      ),
    );
  }
}

class _SupportView extends StatelessWidget {
  const _SupportView();

  static const Color _purple = Color(0xFF645D9C);

  Future<void> _handleLaunch(
      BuildContext context,
      SupportLaunchRequest request,
      ) async {
    final launched = await launchUrl(
      request.uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(request.failureMessage)));
    }
  }

  void _handleNavigation(
      BuildContext context,
      SupportNavigationRequest request,
      ) {
    switch (request.target) {
      case SupportNavigationTarget.chatBot:
        context.push(AppRoutes.chatScreen);
        break;
      case SupportNavigationTarget.quickHelp:
        context.push(AppRoutes.callSupportScreen);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SupportBloc, SupportState>(
          listenWhen: (previous, current) =>
          previous.navigationRequest?.id != current.navigationRequest?.id,
          listener: (context, state) {
            final request = state.navigationRequest;
            if (request != null) {
              _handleNavigation(context, request);
            }
          },
        ),
        BlocListener<SupportBloc, SupportState>(
          listenWhen: (previous, current) =>
          previous.launchRequest?.id != current.launchRequest?.id,
          listener: (context, state) {
            final request = state.launchRequest;
            if (request != null) {
              _handleLaunch(context, request);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: _purple,
          centerTitle: false,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: const Text(
            'support',
            textAlign: TextAlign.left,
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
                    return ListView(
                      padding: const EdgeInsets.only(left: 24, right: 20),
                      children: state.menuItems
                          .map(
                            (item) => SupportTile(
                          title: item.title,
                          onTap: () => context.read<SupportBloc>().add(
                            SupportMenuItemPressed(item),
                          ),
                        ),
                      )
                          .toList(growable: false),
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