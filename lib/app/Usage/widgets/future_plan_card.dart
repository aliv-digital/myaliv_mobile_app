import 'package:flutter/material.dart';

class FuturePlanCard extends StatelessWidget {
  final String title;
  final String startDate;
  final String endDate;
  final String image;

  const FuturePlanCard({
    super.key,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        image: DecorationImage(
          image:  AssetImage(image),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(12),
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: gradient,
        // ),
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
          const Text(
            'future plan',
            style: TextStyle(
              color: Colors.white /* White-100% */,
              fontSize: 12,
              fontFamily: 'Circular Pro',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white /* White-100% */,
              fontSize: 24,
              fontFamily: 'Circular Pro',
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
            fontFamily: 'Circular Pro',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
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

