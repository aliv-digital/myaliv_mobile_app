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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
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
                        color: Colors.white,
                        fontSize: 32,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w700,
                        // letterSpacing: 0.16,
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          plan.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'CircularPro',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.08,
                          ),
                        ),
                        // const SizedBox(height: 4),
                        Text(
                          plan.subtitle,
                          style: const TextStyle(
                            color:  Color(0xFFE5D0D0),
                            fontSize: 10,
                            fontFamily: 'CircularPro',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.04,
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
