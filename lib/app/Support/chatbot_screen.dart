import 'package:flutter/material.dart';

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({super.key});

  static const Color purple = Color(0xFF645D9C);
  static const Color bg = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: purple,
        centerTitle: false,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0),
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
          children: const [
            Expanded(child: _MessageList()),
            _MessageInputBar(),
          ],
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 24, 40, 32),
      children: const [
        _TimeSeparator(time: '09:41 AM'),

        UserBubble(text: 'Hi, Mandy'),
        UserBubble(text: 'I’ve tried the app'),

        BotBubble(text: 'Really?'),

        UserBubble(text: 'Yeah, It’s really good!'),

        TypingIndicator(),
      ],
    );
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

  const UserBubble({super.key, required this.text});

  static const Color purple = Color(0xFF645D9C);

  @override
  Widget build(BuildContext context) {
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
          const CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage('https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg'),
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
          const CircleAvatar(
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
          ),
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
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        CircleAvatar(
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
        ),
        SizedBox(width: 8),
        Text(
          'Typing...',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 16,
            color: Color(0xFF979C9E),
          ),
        ),
      ],
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar();

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
