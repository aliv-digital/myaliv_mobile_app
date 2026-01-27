import 'package:flutter/material.dart';

class CallLogsTab extends StatelessWidget {
  const CallLogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: const [
        _CallLogItem(
          number: '242-444-5555',
          subtitle: 'outgoing call, 1 min 21 secs',
          time: '12:00 PM',
          date: 'July 02, 2024',
          isVoicemail: false,
        ),
        _CallLogItem(
          number: '242-800-5555',
          subtitle: 'voicemail',
          time: 'Friday',
          date: 'July 02, 2024',
          isVoicemail: true,
        ),
        _CallLogItem(
          number: '242-444-5555',
          subtitle: 'outgoing call, 1 min 21 secs',
          time: '11:00 AM',
          date: 'July 02, 2024',
          isVoicemail: false,
        ),
        _CallLogItem(
          number: '242-444-5555',
          subtitle: 'outgoing call, 1 min 21 secs',
          time: '12:00 PM',
          date: 'July 02, 2024',
          isVoicemail: false,
        ),
        _CallLogItem(
          number: '242-800-5555',
          subtitle: 'voicemail',
          time: 'Friday',
          date: 'July 02, 2024',
          isVoicemail: true,
        ),
        SizedBox(height: 24),
        // _BackHomeButton(),
      ],
    );
  }
}
class _CallLogItem extends StatelessWidget {
  final String number;
  final String subtitle;
  final String time;
  final String date;
  final bool isVoicemail;

  const _CallLogItem({
    required this.number,
    required this.subtitle,
    required this.time,
    required this.date,
    required this.isVoicemail,
  });

  static const Color green = Color(0xFF27AE60);
  static const Color red = Color(0xFFEB5757);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isVoicemail ? Icons.call_missed : Icons.call_made,
              color: isVoicemail ? red : green,
            ),
            const SizedBox(width: 12),

            // LEFT TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 12,
                      color: Color(0xFF7A7A7A),
                    ),
                  ),
                ],
              ),
            ),

            // RIGHT DATE
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 11,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
