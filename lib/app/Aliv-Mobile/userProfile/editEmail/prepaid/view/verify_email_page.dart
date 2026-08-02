import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

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
        message: 'email address updated successfully',
        type: ToastType.success,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return StripedScaffold(
      backgroundColor: const Color(0xFFF1F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(41, 130, 41, 24),
            child: Column(
              children: [
                /// Illustration
                SvgPicture.asset(
                  'assets/icons/undraw_mail-sent_ujev 1.svg',
                  height: 80,
                  width: 72,
                ),

                const SizedBox(height: 32),

                /// Title
                const Text(
                  'email updated successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF010101),
                    fontSize: 24,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 16),

                /// Description with email
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'your email has been updated to ',
                        style: TextStyle(
                          color: Color(0xFF58677D),
                          fontSize: 15,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w500,
                          height: 1.47,
                        ),
                      ),
                      TextSpan(
                        text: widget.email,
                        style: const TextStyle(
                          color: Color(0xFF58677D),
                          fontSize: 15,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                          height: 1.47,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                /// Back to Home Button
                GestureDetector(
                  onTap: () {
                    context.go(AppRoutes.home);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF645D9C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'back to home',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                          height: 1.80,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
