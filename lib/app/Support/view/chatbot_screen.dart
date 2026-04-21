import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/support_bloc.dart';
import '../bloc/support_event.dart';
import '../bloc/support_state.dart';
import '../repository/support_repository.dart';
import '../widgets/support_chat_widgets.dart';

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => SupportRepository(dio: Dio()),
      child: BlocProvider(
        create: (context) =>
        SupportBloc(repository: context.read<SupportRepository>())
          ..add(const SupportStarted()),
        child: const _ChatBotView(),
      ),
    );
  }
}

class _ChatBotView extends StatelessWidget {
  const _ChatBotView();

  static const Color _purple = Color(0xFF645D9C);
  static const Color _bg = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text(
          'chat',
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
                  return SupportMessageList(messages: state.chatMessages);
                },
              ),
            ),
            const SupportMessageInputBar(),
          ],
        ),
      ),
    );
  }
}