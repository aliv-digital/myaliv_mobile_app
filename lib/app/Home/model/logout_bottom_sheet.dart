import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';

class LogoutBottomSheet extends StatelessWidget {
  const LogoutBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: const ShapeDecoration(
          color: Color(0xFFF1F2FA),
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

            /// Title
            const SizedBox(
              width: 358,
              child: Text(
                'are you sure you want to logout?',
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

            /// Buttons Row
            Row(
              children: [
                /// NO BUTTON
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      height: 50,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFFF1F1F8),
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'no',
                        style: TextStyle(
                          color: Color(0xFF645D9C),
                          fontSize: 13,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                /// YES BUTTON
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.pop();
                      context.go(AppRoutes.welcome);
                      },
                    child: Container(
                      height: 50,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF645D9C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'yes, logout',
                        style: TextStyle(
                          color: Color(0xFFF1F1F8),
                          fontSize: 15,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
