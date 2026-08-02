import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../widgets/support_tile.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: _createRepository,
      child: BlocProvider(create: _createBloc, child: const _SupportView()),
    );
  }

  SupportRepository _createRepository(BuildContext _) {
    return SupportRepository(dio: Dio());
  }

  SupportBloc _createBloc(BuildContext context) {
    return SupportBloc(repository: context.read<SupportRepository>())
      ..add(const SupportStarted());
  }
}

class _SupportView extends StatelessWidget {
  const _SupportView();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [_navigationListener(), _externalLaunchListener()],
      child: const _SupportScaffold(),
    );
  }

  BlocListener<SupportBloc, SupportState> _navigationListener() {
    return BlocListener<SupportBloc, SupportState>(
      listenWhen: _hasNewNavigationRequest,
      listener: _onNavigationRequested,
    );
  }

  BlocListener<SupportBloc, SupportState> _externalLaunchListener() {
    return BlocListener<SupportBloc, SupportState>(
      listenWhen: _hasNewLaunchRequest,
      listener: _onExternalLaunchRequested,
    );
  }

  // Each request has a unique id, so listeners react once and do not replay
  // older navigation work during normal widget rebuilds.
  bool _hasNewNavigationRequest(SupportState previous, SupportState current) {
    return previous.navigationRequest?.id != current.navigationRequest?.id;
  }

  bool _hasNewLaunchRequest(SupportState previous, SupportState current) {
    return previous.launchRequest?.id != current.launchRequest?.id;
  }

  void _onNavigationRequested(BuildContext context, SupportState state) {
    final request = state.navigationRequest;
    if (request == null) return;

    _openInternalScreen(context, request);
  }

  Future<void> _onExternalLaunchRequested(
    BuildContext context,
    SupportState state,
  ) async {
    final request = state.launchRequest;
    if (request == null) return;

    await _openExternalBrowser(context, request);

    // Keep FAQ loading until url_launcher returns, then unlock the menu.
    if (context.mounted) {
      context.read<SupportBloc>().add(const SupportLaunchHandled());
    }
  }

  Future<void> _openExternalBrowser(
    BuildContext context,
    SupportLaunchRequest request,
  ) async {
    bool launched = false;

    // url_launcher may return false or throw depending on the platform.
    // Both cases use the same user-facing error message.
    try {
      launched = await launchUrl(
        request.uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      launched = false;
    }

    if (!launched && context.mounted) {
      AppToast.show(
        message: request.failureMessage.toString(),
        type: ToastType.error,
      );
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text(request.failureMessage)));
    }
  }

  void _openInternalScreen(
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
}

class _SupportScaffold extends StatelessWidget {
  const _SupportScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      appBar: _SupportAppBar(),
      body: _SupportBody(),
    );
  }
}

class _SupportAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SupportAppBar();

  static const Color _purple = Color(0xFF645D9C);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
    );
  }
}

class _SupportBody extends StatelessWidget {
  const _SupportBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: const [
          Expanded(child: _SupportMenuList()),
          BottomStripes(),
        ],
      ),
    );
  }
}

class _SupportMenuList extends StatelessWidget {
  const _SupportMenuList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupportBloc, SupportState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.only(left: 24, right: 20),
          children: [
            for (final item in state.menuItems)
              _SupportMenuTile(item: item, isFaqOpening: state.isFaqOpening),
          ],
        );
      },
    );
  }
}

class _SupportMenuTile extends StatelessWidget {
  final SupportMenuItem item;
  final bool isFaqOpening;

  const _SupportMenuTile({required this.item, required this.isFaqOpening});

  @override
  Widget build(BuildContext context) {
    final bool shouldShowFaqLoading =
        item.action == SupportMenuAction.faq && isFaqOpening;

    return SupportTile(
      title: item.title,
      isLoading: shouldShowFaqLoading,
      onTap: _buildTapHandler(context),
    );
  }

  VoidCallback? _buildTapHandler(BuildContext context) {
    // While FAQ is opening, block the whole menu so another external action
    // cannot start before the browser handoff completes.
    if (isFaqOpening) return null;

    return () {
      context.read<SupportBloc>().add(SupportMenuItemPressed(item));
    };
  }
}
