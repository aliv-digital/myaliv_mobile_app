import 'package:flutter/material.dart';

import '../model/support_models.dart';

class SupportMessageList extends StatelessWidget {
  final List<SupportChatMessage> messages;

  const SupportMessageList({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 24, 40, 32),
      children: messages.map(_buildMessage).toList(growable: false),
    );
  }

  Widget _buildMessage(SupportChatMessage message) {
    switch (message.type) {
      case SupportChatMessageType.time:
        return _TimeSeparator(time: message.text);
      case SupportChatMessageType.user:
        return UserBubble(text: message.text, avatarUrl: message.avatarUrl);
      case SupportChatMessageType.bot:
        return BotBubble(text: message.text);
      case SupportChatMessageType.typing:
        return TypingIndicator(text: message.text);
    }
  }
}

class _TimeSeparator extends StatelessWidget {
  final String time;

  const _TimeSeparator({required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Center(
        child: Text(
          time,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF979C9E),
          ),
        ),
      ),
    );
  }
}

class UserBubble extends StatelessWidget {
  final String text;
  final String? avatarUrl;

  const UserBubble({super.key, required this.text, this.avatarUrl});

  static const Color purple = Color(0xFF645D9C);

  @override
  Widget build(BuildContext context) {
    final avatar = avatarUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: purple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 12,
            backgroundImage: avatar == null ? null : NetworkImage(avatar),
          ),
        ],
      ),
    );
  }
}

class BotBubble extends StatelessWidget {
  final String text;

  const BotBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BotAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F4),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF222222),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  final String text;

  const TypingIndicator({super.key, this.text = 'Typing...'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _BotAvatar(),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 16,
            color: Color(0xFF979C9E),
          ),
        ),
      ],
    );
  }
}

class SupportMessageInputBar extends StatelessWidget {
  const SupportMessageInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(
        context,
      ).viewInsets.add(const EdgeInsets.fromLTRB(24, 12, 24, 32)),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0xFFE3E4E5)),
        ),
        alignment: Alignment.centerLeft,
        child: const Text(
          'Okay, Give me some I',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF121212),
          ),
        ),
      ),
    );
  }
}

class _BotAvatar extends StatelessWidget {
  const _BotAvatar();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 20,
      backgroundColor: Color(0xFFF2F4F5),
      child: Text(
        'T',
        style: TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF463C6E),
        ),
      ),
    );
  }
}
