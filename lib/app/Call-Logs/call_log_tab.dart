import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/call_logs_cubit.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/call_logs_state.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/widgets/call_log_tile.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/widgets/call_logs_empty_state.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class CallLogsTab extends StatelessWidget {
  const CallLogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2FA),
      bottomNavigationBar: const _BackToHomeButton(),
      body: BlocBuilder<CallLogsCubit, CallLogsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CallLogsStatus.failure) {
            return CallLogsErrorState(
              message: state.errorMessage ?? 'Failed to load call logs',
              onRetry: () => context.read<CallLogsCubit>().fetchUsages(),
            );
          }

          if (!state.hasData) {
            return const CallLogsEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            itemCount: state.usages.length,
            itemBuilder: (_, index) => CallLogTile(usage: state.usages[index]),
          );
        },
      ),
    );
  }
}

class _BackToHomeButton extends StatelessWidget {
  const _BackToHomeButton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.home),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 68.0, vertical: 20),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: Alignment.center,
            child: const Text(
              'back to home page',
              style: TextStyle(
                color: Color(0xFF645D9C),
                fontSize: 15,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
