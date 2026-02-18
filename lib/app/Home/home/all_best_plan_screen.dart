import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: AppBar(
          toolbarHeight: 64,
          backgroundColor: purple,
          elevation: 0, centerTitle: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
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
          padding: const EdgeInsets.all(25),
          children: const [
            _PlanCard(
              price: '\$15.00',
              title: 'freedom15',
              subtitle: '7 days plan',
              color: Color(0xFFB62A2A),
              imageUrl:'assets/images/Group 176584.png'
              // 'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg',
            ),
            SizedBox(height: 20),
            _PlanCard(
              price: '\$45.00',
              title: 'Freedom45',
              subtitle: '7 days plan',
              color: Color(0xFF245E55),
              imageUrl:'assets/images/Group 176596.png'
              // 'https://images.pexels.com/photos/3762800/pexels-photo-3762800.jpeg',
            ),
            SizedBox(height: 20),
            _PlanCard(
              price: '\$120.00',
              title: 'Liberty120',
              subtitle: 'Begins Immediately plan',
              color: Color(0xFFE6B83E),
              imageUrl: 'assets/images/Group 176597.png'
              // 'https://images.pexels.com/photos/762020/pexels-photo-762020.jpeg',
            ),
          ],
        )
        ,
      ),
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
        // color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Image.asset(imageUrl,fit: BoxFit.fill,)
      // Row(
      //   children: [
      //     // ===== Image section =====
      //     ClipRRect(
      //       borderRadius: const BorderRadius.only(
      //         topLeft: Radius.circular(16),
      //         bottomLeft: Radius.circular(16),
      //       ),
      //       child: SizedBox(
      //         width: 140,
      //         height: double.infinity,
      //         child: Image.network(
      //           imageUrl,
      //           fit: BoxFit.cover,
      //           alignment: Alignment.topCenter,
      //         ),
      //       ),
      //     ),
      //
      //     // ===== Content section =====
      //     Expanded(
      //       child: Padding(
      //         padding: const EdgeInsets.fromLTRB(20, 24, 24, 24),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.end,
      //           children: [
      //             Text(
      //               price,
      //               style: const TextStyle(
      //                 fontFamily: 'CircularPro',
      //                 fontSize: 50,
      //                 fontWeight: FontWeight.w700,
      //                 color: Colors.white,
      //                 letterSpacing: 0.25,
      //               ),
      //             ),
      //             const Spacer(),
      //             Column(
      //               crossAxisAlignment: CrossAxisAlignment.end,
      //               children: [
      //                 Text(
      //                   title,
      //                   style: const TextStyle(
      //                     fontFamily: 'CircularPro',
      //                     fontSize: 24,
      //                     fontWeight: FontWeight.w700,
      //                     letterSpacing: 0.12,
      //                     color: Colors.white,
      //                   ),
      //                 ),
      //                 const SizedBox(height: 4),
      //                 Text(
      //                   subtitle,
      //                   style: const TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 13,
      //                     fontFamily: 'Circular Pro',
      //                     fontWeight: FontWeight.w500,
      //                     letterSpacing: 0.07,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
