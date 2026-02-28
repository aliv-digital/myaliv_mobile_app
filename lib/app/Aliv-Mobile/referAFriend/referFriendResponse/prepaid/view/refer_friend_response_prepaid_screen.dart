import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import '../bloc/refer_friend_response_prepaid_bloc.dart';
import '../bloc/refer_friend_response_prepaid_event.dart';
import '../bloc/refer_friend_response_prepaid_state.dart';
import '../repository/refer_friend_response_prepaid_repository.dart';
import '../theme/refer_friend_response_prepaid_theme.dart';
import '../widgets/refer_friend_response_prepaid_card.dart';

class ReferFriendResponsePrepaidScreen extends StatelessWidget {
  const ReferFriendResponsePrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Keep status bar consistent with purple app bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return BlocProvider(
      create: (_) => ReferFriendResponsePrepaidBloc(
        repository: ReferFriendResponsePrepaidRepository(),
      )..add(const ReferFriendResponsePrepaidStarted()),
      child: const _ReferFriendResponsePrepaidView(),
    );
  }
}

class _ReferFriendResponsePrepaidView extends StatelessWidget {
  const _ReferFriendResponsePrepaidView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReferFriendResponsePrepaidTheme.bg,
      body: SafeArea(
        child: BlocListener<ReferFriendResponsePrepaidBloc,
            ReferFriendResponsePrepaidState>(
          listenWhen: (p, c) => p.toastMessage != c.toastMessage,
          listener: (context, state) {
            final msg = state.toastMessage;
            if (msg == null || msg.isEmpty) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );

            context
                .read<ReferFriendResponsePrepaidBloc>()
                .add(const ReferFriendResponsePrepaidToastConsumed());
          },
          child: Column(
            children: [
              // ✅ Sticky AppBar (won't scroll)
              const _HeaderBar(),

              // ✅ Body
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: const ReferFriendResponsePrepaidCard(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar();

  @override
  Widget build(BuildContext context) {
    return DefaultAppBar(
      title: 'success!',
      showHome: false,
      showBackArrow: true,centerTitle: false,
      backgroundColor: ReferFriendResponsePrepaidTheme.brand,
      onBack: () {},
    );
  }
}
