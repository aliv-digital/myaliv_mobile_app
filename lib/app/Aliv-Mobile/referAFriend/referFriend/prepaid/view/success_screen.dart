import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../router/app_routes.dart';

class InvitingSuccessScreen extends StatelessWidget {
  final String referralCode;

  const InvitingSuccessScreen({super.key, required this.referralCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF645D9C),
        elevation: 0,
        toolbarHeight: 64,
        automaticallyImplyLeading: false,
        centerTitle: false,
        leading: null,
        title: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text(
            'success!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 32),

                // ===== ICON =====
                SvgPicture.asset('assets/icons/Success Icon.svg'),

                // Container(
                //   width: 72,
                //   height: 72,
                //   alignment: Alignment.center,
                //   decoration: const BoxDecoration(
                //     shape: BoxShape.circle,
                //     color: Color(0x1E23A26D),
                //   ),
                //   child: Container(
                //     width: 48,
                //     height: 48,
                //     alignment: Alignment.center,
                //     decoration: const BoxDecoration(
                //       shape: BoxShape.circle,
                //       color: Color(0xFF23A26D),
                //     ),
                //     child: const Icon(
                //       Icons.mail_outline,
                //       color: Colors.white,
                //       size: 24,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 24),

                // ===== TITLE =====
                Text(
                  'Inviting Success!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 32),

                // ===== DESCRIPTION =====
                Text(
                  'Thank you for inviting your friend to join the ALIV network! once they’re on the network for three months, you will receive your cash back reward.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF707070),
                    fontSize: 16,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                // ===== REFERRAL CODE SECTION =====
                Text(
                  'Your referral code is:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF707070),
                    fontSize: 16,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                _ReferralCodeBox(code: referralCode),

                const SizedBox(height: 32),

                const Divider(color: Color(0xFFE8EAED)),

                const SizedBox(height: 32),

                // ===== CTA =====
                GestureDetector(
                  onTap: () {
                    context.go(AppRoutes.home);
                  },
                  child: Container(
                    width: 200,
                    height: 48,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Text(
                          'back to home page',
                          style: TextStyle(
                            color: const Color(0xFF645D9C),
                            fontSize: 15,
                            fontFamily: 'CircularPro',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReferralCodeBox extends StatelessWidget {
  final String code;

  const _ReferralCodeBox({required this.code});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width - 96;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 160, maxWidth: maxWidth),
      child: Container(
        height: 48,
        padding: const EdgeInsets.only(left: 16, right: 4),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFF1F1F8)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                code,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF707070),
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Copied')));
              },
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F1F9),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset('assets/icons/copy2.svg'),
                    const SizedBox(width: 4),
                    const Text(
                      'copy',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF645D9C),
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w500,
                      ),
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
