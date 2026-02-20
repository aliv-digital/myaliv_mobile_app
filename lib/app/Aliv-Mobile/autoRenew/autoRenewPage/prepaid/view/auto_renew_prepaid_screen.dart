import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auto_renew_prepaid_bloc.dart';
import '../bloc/auto_renew_prepaid_event.dart';
import '../repository/auto_renew_prepaid_repository.dart';
import '../widgets/auto_renew_prepaid_page_content.dart';
import '../widgets/auto_renew_prepaid_state_listener.dart';

class AutoRenewPrepaidScreen extends StatelessWidget {
  const AutoRenewPrepaidScreen({super.key});

  // ==================== Screen Composition ====================
  // Provide feature dependencies once at the screen boundary.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: _createAutoRenewPrepaidBloc,
      child: const _AutoRenewPrepaidView(),
    );
  }

  // ==================== Bloc Factory ====================
  // Keep bloc creation isolated to simplify future dependency injection.
  AutoRenewPrepaidBloc _createAutoRenewPrepaidBloc(BuildContext context) {
    final AutoRenewPrepaidRepository autoRenewPrepaidRepository = AutoRenewPrepaidRepositoryImpl();

    final AutoRenewPrepaidBloc autoRenewPrepaidBloc = AutoRenewPrepaidBloc(
      repository: autoRenewPrepaidRepository,
    );

    autoRenewPrepaidBloc.add(const AutoRenewPrepaidStarted());

    return autoRenewPrepaidBloc;
  }
}

class _AutoRenewPrepaidView extends StatelessWidget {
  const _AutoRenewPrepaidView();

  // ==================== Screen Root ====================
  // Wrap content with a listener for one-off side effects.
  @override
  Widget build(BuildContext context) {
    return const AutoRenewPrepaidStateListener(
      child: AutoRenewPrepaidPageContent(),
    );
  }
}
