import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../../../login/widgets/login_bottom_stripes.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;

  const VerifyEmailPage({super.key, required this.email});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}



class _VerifyEmailPageState extends State<VerifyEmailPage> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      AppToast.show(
        message:
        'email address updated. please check your email to verify',
        type: ToastType.success,
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F5),
      bottomNavigationBar: const SafeArea(top: false, child: BottomStripes()),
      body: SafeArea(
        child: Stack(
          children: [
            /// Main Content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(41, 130, 41, 24),
                child: Column(
                  children: [
                    /// Illustration (replace with SVG if needed)
                    SvgPicture.asset('assets/icons/undraw_mail-sent_ujev 1.svg',height: 80,width: 72,),

                    const SizedBox(height: 32),

                    const Text(
                      'verify email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF010101),
                        fontSize: 24,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'we’ve sent a verification link to your ',
                            style: TextStyle(
                              color: const Color(0xFF58677D),
                              fontSize: 15,
                              fontFamily: 'Circular Pro',
                              fontWeight: FontWeight.w500,
                              height: 1.47,
                            ),
                          ),
                          TextSpan(
                            text: 'sumon@bealiv.com',
                            style: TextStyle(
                              color: const Color(0xFF58677D),
                              fontSize: 15,
                              fontFamily: 'Circular Pro',
                              fontWeight: FontWeight.w700,
                              height: 1.47,
                            ),
                          ),
                          TextSpan(
                            text: ' email address. please check your email and verify',
                            style: TextStyle(
                              color: const Color(0xFF58677D),
                              fontSize: 15,
                              fontFamily: 'Circular Pro',
                              fontWeight: FontWeight.w500,
                              height: 1.47,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    GestureDetector(
                      onTap: ()
                      {
                        context.go(AppRoutes.home);
                      },
                      child: Container(
                        // width: 307.84,
                        width: double.infinity,
                        height: 52,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF645D9C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'back to home',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontFamily: 'Circular Pro',
                              fontWeight: FontWeight.w700,
                              height: 1.80,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),


                    /// Resend Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "didn't receive a link?",
                          style: TextStyle(
                            color: Color(0xFF121212),
                            fontSize: 14,
                            fontFamily: 'CircularPro',
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            // call resend API
                          },
                          child: const Text(
                            'resend link',
                            style: TextStyle(
                              color: Color(0xFF645D9C),
                              fontSize: 13,
                              fontFamily: 'CircularPro',
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    /// Edit Email Section
                    const Text(
                      'have you entered the wrong email address?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF121212),
                        fontSize: 14,
                        fontFamily: 'CircularPro',
                      ),
                    ),

                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Text(
                        'edit email',
                        style: TextStyle(
                          color: Color(0xFF645D9C),
                          fontSize: 13,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// SUCCESS BANNER
            // Positioned(
            //   top: 41,
            //   left: 15,
            //   right: 15,
            //   child: Container(
            //     padding: const EdgeInsets.all(12),
            //     decoration: BoxDecoration(
            //       color: const Color(0xFF4DDBC0),
            //       borderRadius: BorderRadius.circular(8),
            //       boxShadow: const [
            //         BoxShadow(
            //           color: Color(0x19000000),
            //           blurRadius: 10,
            //           offset: Offset(0, 4),
            //         ),
            //       ],
            //     ),
            //     child: Row(
            //       children: const [
            //         CircleAvatar(
            //           radius: 10,
            //           backgroundColor: Colors.white70,
            //           child: Icon(
            //             Icons.check,
            //             size: 14,
            //             color: Color(0xFF094338),
            //           ),
            //         ),
            //         SizedBox(width: 10),
            //         Expanded(
            //           child: Text(
            //             'email address updated. please check your email to verify',
            //             style: TextStyle(
            //               color: Color(0xFF084338),
            //               fontSize: 14,
            //               fontFamily: 'CircularPro',
            //               fontWeight: FontWeight.w700,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
