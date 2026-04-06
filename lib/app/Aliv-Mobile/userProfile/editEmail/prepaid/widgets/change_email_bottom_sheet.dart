import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../router/app_routes.dart';

class ChangeEmailBottomSheet extends StatelessWidget {
  const ChangeEmailBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                icon: const Icon(Icons.arrow_back, size: 22),
                onPressed: () => context.pop(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// Message
          const SizedBox(
            width: 358,
            child: Text(
              'updating your email address will send you a verification link.\n\n'
                  'if your email is not verified within the allotted time, your network will be suspended.\n\n'
                  'would you like to continue?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF121212),
                fontSize: 16,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// Buttons
          Row(
            children: [

              /// NO
              Expanded(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: const Color(0xFFF1F1F8),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'no',
                      style: TextStyle(
                        color: Color(0xFF645D9C),
                        fontSize: 13,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 20),

              /// YES
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // close sheet
                    context.push(AppRoutes.updateEmail);
                    // context.pop(); // close sheet
                    // context.push(AppRoutes.updateEmail);

                    // Navigate to email update screen
                    // context.push('/update-email'); // change to your route
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF645D9C),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'yes',
                      style: TextStyle(
                        color: Color(0xFFF1F1F8),
                        fontSize: 13,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

        ],
      ),
    );
  }
}
