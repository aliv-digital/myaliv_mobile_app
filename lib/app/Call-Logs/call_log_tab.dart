import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CallLogsTab extends StatelessWidget {
  const CallLogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon(
            //   isVoicemail ? Icons.call_missed : Icons.call_made,
            //   color: isVoicemail ? red : green,
            // ),
            isVoicemail
                ? SvgPicture.asset(
                    height: 14,
                    width: 14,
                    'assets/icons/phone-hang-up.svg',
                  )
                : SvgPicture.asset(
                    height: 14,
                    width: 14,
                    'assets/icons/phone-outgoing-01.svg',
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
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF858692),
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
                    fontWeight: FontWeight.w500,

                    fontSize: 13,
                    color: const Color(0xFF1C1C1C) /* Black-100% */,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,

                    color: const Color(0xFF1C1C1C) /* Black-100% */,
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
