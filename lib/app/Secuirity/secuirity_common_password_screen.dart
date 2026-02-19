import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_bottom_stripes.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/addOrEditCards/prepaid/widgets/app_toast.dart';

import '../../resources/widgets/top_toast.dart';
import '../../router/app_routes.dart';

class CommonEnterPasswordPage extends StatefulWidget {
  final String appBarTitle;
  final String continueRoute;

  const CommonEnterPasswordPage({
    super.key,
    required this.appBarTitle,
    required this.continueRoute,
  });

  @override
  State<CommonEnterPasswordPage> createState() =>
      _CommonEnterPasswordPageState();
}

class _CommonEnterPasswordPageState extends State<CommonEnterPasswordPage> {
  final TextEditingController _controller = TextEditingController();
  bool _obscure = true;

  void _handleContinue() {
    // if (_controller.text.isEmpty) return;

    // context.go(widget.continueRoute);
    if (widget.continueRoute == 'call_logs') {
      // context.push('${AppRoutes.callLogs}?tab=call_logs',);
      context.push(
        Uri(
          path: AppRoutes.verificationCode,
          queryParameters: {'next': widget.continueRoute},
        ).toString(),
      );
    }
    if (widget.continueRoute == 'home') {
      context.push(
        Uri(
          path: AppRoutes.verificationCode,
          queryParameters: {'next': widget.continueRoute},
        ).toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// 🔥 APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF645D9C),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        centerTitle: false,
        toolbarHeight: 64,
        title: Text(
          widget.appBarTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFamily: 'CircularPro',
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(top: false, child: BottomStripes()),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(48, 24, 48, 24),
            child: Column(
              children: [
                const SizedBox(height: 70),

                /// Title
                const Text(
                  "Enter Password",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF010101),
                    fontFamily: 'CircularPro',
                  ),
                ),

                // const SizedBox(height: 12),

                /// Subtitle
                const SizedBox(
                  width: 308,
                  child: Text(
                    "For security reasons, please enter your password to continue.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.47,
                      color: Color(0xFF58677D),
                      fontFamily: 'CircularPro',
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                /// Password Field
                Container(
                  // width: 296,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFDFDFDF)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // const Icon(Icons.lock_out?line, size: 18),
                      SvgPicture.asset('assets/icons/LockKey.svg'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          obscureText: _obscure,
                          decoration: const InputDecoration(
                            hintText: "enter your password",
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF667085),
                              fontFamily: 'CircularPro',
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _obscure = !_obscure);
                        },
                        child: _obscure
                            ? SvgPicture.asset('assets/icons/eye.svg')
                            : Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// Terms Text
                Column(
                  children: [
                    const Text(
                      "By pressing ‘Continue’ button you agree",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF58677D),
                        fontFamily: 'CircularPro',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "to the ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF58677D),
                            fontFamily: 'CircularPro',
                          ),
                        ),
                        Text(
                          "Terms & Conditions",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            color: Color(0xFF645D9C),
                            fontFamily: 'CircularPro',
                          ),
                        ),
                        Text(
                          " & ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF58677D),
                            fontFamily: 'CircularPro',
                          ),
                        ),
                        Text(
                          "Privacy Policy",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            color: Color(0xFF645D9C),
                            fontFamily: 'CircularPro',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// Continue Button
                GestureDetector(
                  onTap: _handleContinue,
                  child: Container(
                    // width: 296,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF645D9C),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'CircularPro',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                /// Or Continue With
                // const Text(
                //   "Or Continue with",
                //   style: TextStyle(
                //     fontSize: 13,
                //     color: Color(0xFF8A8A8F),
                //     fontFamily: 'CircularPro',
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 47,
                  ), // match layout width
                  child: Row(
                    children: const [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Color(0xFF8A8A8F),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Or Continue with",
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w400,
                          height: 1.38,
                          letterSpacing: -0.08,
                          color: Color(0xFF8A8A8F),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Color(0xFF8A8A8F),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    children: [
                      Expanded(child: _biometricButton("Face ID")),
                      const SizedBox(width: 16),
                      Expanded(child: _biometricButton("Fingerprint")),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _biometricButton(String title) {
    return Container(
      // width: 140,
      height: 40,
      // padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF1F1F8)),
        borderRadius: BorderRadius.circular(100),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xCC5146A8),
          fontFamily: 'CircularPro',
        ),
      ),
    );
  }
}
