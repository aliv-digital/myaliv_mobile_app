import 'package:flutter/material.dart';

class UsageRoamingPlanCard extends StatelessWidget {
  const UsageRoamingPlanCard({super.key});

  static const Color startColor = Color(0xFF00C4B3);
  static const Color endColor = Color(0xFF00B3E3);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: const AssetImage('assets/icons/Future Plan 3.png'),
          fit: BoxFit.fill,
        ), // gradient: const LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [startColor, endColor],
        // ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'active',
                  style: TextStyle(
                    color: Colors.white /* White-100% */,
                    fontSize: 12,
                    fontFamily: 'Circular Pro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' plan',
                  style: TextStyle(
                    color: Colors.white /* White-100% */,
                    fontSize: 12,
                    fontFamily: 'Circular Pro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'roameasy usa and can',
            style: TextStyle(
              color: Colors.white /* White-100% */,
              fontSize: 24,
              fontFamily: 'Circular Pro',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: const [
              _DateColumn(title: 'active', value: '20/01/25'),
              Spacer(),
              _DateColumn(title: 'expire', value: '19/02/25', alignRight: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  final String title;
  final String value;
  final bool alignRight;

  const _DateColumn({
    required this.title,
    required this.value,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white /* White-100% */,
            fontSize: 10,
            fontFamily: 'Circular Pro',
            fontWeight: FontWeight.w500,
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            color: Colors.white /* White-100% */,
            fontSize: 15,
            fontFamily: 'Circular Pro',
            fontWeight: FontWeight.w700,
            letterSpacing: 2.25,
          ),
        ),
      ],
    );
  }
}
