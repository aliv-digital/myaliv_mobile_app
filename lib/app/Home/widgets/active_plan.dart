import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../router/app_routes.dart';
import 'auto_renew_toggle.dart';

class PrepaidActivePlanCard extends StatelessWidget {
  final bool showRenewButton;

  const PrepaidActivePlanCard({
    super.key,
    this.showRenewButton = true, // 🔥 default OFF
  });

  static const Color red = Color(0xFFD94B4B);
  static const Color redDark = Color(0xFFCC3F3F);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: showRenewButton
          ? const EdgeInsets.symmetric(horizontal: 24)
          : EdgeInsetsGeometry.zero,
      child: Container(
        height: showRenewButton ? 200 : 160,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/icons/Home Active Plan.png'),
            fit: BoxFit.fill,
          ),
          // gradient: const LinearGradient(
          //   colors: [red, redDark],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topRow(),
            // const SizedBox(height: 6),
            // _planName(),
            const SizedBox(height: 20),
            _datesRow(),
            // 🔥 CONDITIONAL RENEW BUTTON
            if (showRenewButton) ...[
              const SizedBox(height: 14),
              _renewButton(context),
            ],
            // showRenewButton? const SizedBox(height: 14):const SizedBox(height: 0),
            // showRenewButton?  _renewButton():const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }

  Widget _topRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'active',
                    style: TextStyle(
                      color: Colors.white /* White-100% */,
                      fontSize: 12,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' plan',
                    style: TextStyle(
                      color: Colors.white /* White-100% */,
                      fontSize: 12,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _planName(),
          ],
        ),
        Spacer(),
        AutoRenewToggle(initialValue: false),
      ],
    );
  }

  Widget _planName() {
    return Text(
      'liberty70',
      style: TextStyle(
        color: Colors.white /* White-100% */,
        fontSize: 24,
        fontFamily: 'CircularPro',
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _datesRow() {
    return Row(
      children: const [
        _DateBlock(title: 'active', value: '20/08/24'),
        Spacer(),
        _DateBlock(title: 'expire', value: '19/09/24', alignRight: true),
      ],
    );
  }

  Widget _renewButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,isDismissible: true,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black.withOpacity(0.5),
            builder: (_) => const AutoRenewBottomSheet(),
          );

        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF3F4FA),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/card-add.svg',
              width: 18,
              height: 18,
              color: Color(0xFFEF3A4B),
            ),
            SizedBox(width: 10),
            Text(
              'renew your plan',
              style: TextStyle(
                color: const Color(0xFFEF3A4B),
                fontSize: 13,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= Date Block =================
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
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
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

class AutoRenewBottomSheet extends StatelessWidget {
  const AutoRenewBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.width,
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
                  icon: const Icon(Icons.arrow_back, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Text
            Text(
              'enable auto-renew using your credit card or wallet balance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF121212),
                fontSize: 16,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w400, // w450 ≈ w400 in Flutter
              ),
            ),

            const SizedBox(height: 20),

            /// Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF645D9C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  context.push(
                    AppRoutes.autoRenewPrepaidScreen,
                  );

                },
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
          ],
        ),
      ),
    );
  }
}
