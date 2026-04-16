import 'package:flutter/material.dart';

class FuturePlanCard extends StatelessWidget {
  final String title;
  final String startDate;
  final String endDate;
  final String image;
  final bool isActivePlan;

  const FuturePlanCard({
    super.key,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.image,
    this.isActivePlan = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 151,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 16),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isActivePlan ? 'active plan' : 'future plan',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title.trim().isNotEmpty ? title : 'no plan',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              _DateBlock(title: 'starts', value: startDate),
              const Spacer(),
              _DateBlock(
                title: 'expire',
                value: endDate,
                alignRight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _DateBlock extends StatelessWidget {
  final String title;
  final String value;
  final bool alignRight;

  const _DateBlock({
    required this.title,
    required this.value,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white /* White-100% */,
            fontSize: 10,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white /* White-100% */,
            fontSize: 15,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
            letterSpacing: 2.25,
          ),
        ),
      ],
    );
  }
}

