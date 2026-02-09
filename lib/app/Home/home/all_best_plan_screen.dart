import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AllBestPlansScreen extends StatelessWidget {
  const AllBestPlansScreen({super.key});

  static const Color purple = Color(0xFF645D9C);
  static const demoImages = [
    'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg',
    'https://images.pexels.com/photos/3762800/pexels-photo-3762800.jpeg',
    'https://images.pexels.com/photos/762020/pexels-photo-762020.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: purple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'our best plans',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _PlanCard(
            price: '\$15.00',
            title: 'freedom15',
            subtitle: '7 days plan',
            color: Color(0xFFB62A2A),
            imageUrl:
            'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg',
          ),
          SizedBox(height: 20),
          _PlanCard(
            price: '\$45.00',
            title: 'Freedom45',
            subtitle: '7 days plan',
            color: Color(0xFF245E55),
            imageUrl:
            'https://images.pexels.com/photos/3762800/pexels-photo-3762800.jpeg',
          ),
          SizedBox(height: 20),
          _PlanCard(
            price: '\$120.00',
            title: 'Liberty120',
            subtitle: 'Begins Immediately plan',
            color: Color(0xFFE6B83E),
            imageUrl:
            'https://images.pexels.com/photos/762020/pexels-photo-762020.jpeg',
          ),
        ],
      )
      ,
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String price;
  final String title;
  final String subtitle;
  final Color color;
  final String imageUrl;

  const _PlanCard({
    required this.price,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // ===== Image section =====
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
            child: SizedBox(
              width: 140,
              height: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // ===== Content section =====
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
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
    );
  }
}
