import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/models/usage_model.dart';

/// Reusable tile widget for displaying a call log entry
class CallLogTile extends StatelessWidget {
  final UsageModel usage;

  const CallLogTile({super.key, required this.usage});

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
            _buildIcon(),
            const SizedBox(width: 12),
            _buildContent(),
            _buildDateInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final isIncoming = usage.isIncoming;
    final iconPath = isIncoming
        ? 'assets/icons/phone-hang-up.svg'
        : 'assets/icons/phone-outgoing-01.svg';

    return SvgPicture.asset(iconPath, height: 14, width: 14);
  }

  Widget _buildContent() {
    final phoneNumber = usage.numberDialed.isNotEmpty
        ? usage.numberDialed
        : usage.callingParty;
    final subtitle = _buildSubtitle();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            phoneNumber.isNotEmpty ? phoneNumber : 'Unknown',
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
              color: Color(0xFF858692),
            ),
          ),
        ],
      ),
    );
  }

  String _buildSubtitle() {
    final callType = usage.isOutgoing ? 'outgoing call' : 'incoming call';
    if (usage.duration.isNotEmpty) {
      return '$callType, ${usage.duration}';
    }
    return callType;
  }

  Widget _buildDateInfo() {
    final time = DateFormat('h:mm a').format(usage.date);
    final date = DateFormat('MMMM dd, yyyy').format(usage.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          time,
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1C1C1C),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1C1C1C),
          ),
        ),
      ],
    );
  }
}
