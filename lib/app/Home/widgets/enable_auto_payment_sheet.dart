import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class EnableAutoPaymentSheet extends StatelessWidget {
  const EnableAutoPaymentSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x07101828),
            blurRadius: 8,
            offset: Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x14101828),
            blurRadius: 24,
            offset: Offset(0, 20),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// Back Arrow
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 24,
              height: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back,
                  size: 22,
                  color: Colors.black,
                ),
                onPressed: () => context.pop(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// Message
          Padding(
            padding: const EdgeInsets.only(left: 16.0,right: 16),
            child: Text(
              'you are about to enabled your credit card for automatic payment of your postpaid plans.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF121212),
                fontSize: 16,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          const SizedBox(height: 32),

          /// OK Button
          Padding(
            padding: const EdgeInsets.only(left: 16.0,right: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: GestureDetector(
                onTap: () {
                  context.pop();
                  context.push(AppRoutes.autoPayPostpaidScreen);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF645D9C),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'ok',
                    style: TextStyle(
                      color: Color(0xFFF1F1F8),
                      fontSize: 13,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

        ],
      ),
    );
  }
}
