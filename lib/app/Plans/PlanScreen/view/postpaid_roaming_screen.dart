import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/postpaid_add_on.dart';


class PostpaidRoamingAddOnsScreen extends StatelessWidget {
  const PostpaidRoamingAddOnsScreen({super.key});

  static const Color purple = Color(0xFF645D9C);
  static const Color bg = Color(0xFFF1F1FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: purple,
        elevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: const Text(
            'roaming data add-ons',
            style: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        // actions: [
        //   Stack(
        //     children: [
        //       Padding(
        //         padding: EdgeInsets.only(right: 24),
        //         child: SvgPicture.asset(
        //           'assets/icons/bell with red.svg',
        //           height: 32,
        //           width: 32,
        //           color: Colors.white,
        //         ),
        //       ),
        //       Positioned(
        //         right: 26,
        //         top: 2,
        //         child: CircleAvatar(
        //           radius: 6,
        //           backgroundColor: Color(0xFFED3434),
        //         ),
        //       ),
        //     ],
        //   ),
        // ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            Text(
              'choose a roaming data add-on. these add-ons will only work in the usa, canada and or digicel caribbean countries.',
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),

            RoamingAddOnCard(
              title: 'travel20',
              duration: '7 days',
              data: '0.25gb',
              price: '\$18.18',
            ),
            SizedBox(height: 16),

            RoamingAddOnCard(
              title: 'travel30',
              duration: '7 days',
              data: '0.5gb',
              price: '\$27.27',
            ),
            SizedBox(height: 16),

            RoamingAddOnCard(
              title: 'travel50',
              duration: '14 days',
              data: '1gb',
              price: '\$45.45',
            ),
            SizedBox(height: 16),

          ],
        ),
      ),
    );
  }
}
