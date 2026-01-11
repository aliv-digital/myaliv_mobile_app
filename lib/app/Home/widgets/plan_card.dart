import 'package:flutter/material.dart';
import '../model/plan.dart';

class PlanCard extends StatelessWidget {
  final PlanModel plan;
  final double height;
  final double imageWidth;
  final VoidCallback? onTap;

  const PlanCard({
    super.key,
    required this.plan,
    required this.height,
    required this.imageWidth,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Color(plan.backgroundColor),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
              child: SizedBox(
                width: imageWidth,
                height: double.infinity,
                child: Image.network(
                  plan.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // CONTENT
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.price,
                      style: const TextStyle(
                        fontFamily: 'CircularPro',
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          plan.title,
                          style: const TextStyle(
                            fontFamily: 'CircularPro',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.subtitle,
                          style: const TextStyle(
                            fontFamily: 'CircularPro',
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
