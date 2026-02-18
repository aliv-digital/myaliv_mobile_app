import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../resources/constants/asset_constants.dart';
import '../../router/app_routes.dart';
import '../Aliv-Mobile/login/widgets/login_bottom_stripes.dart';

class VerificationCodePage extends StatefulWidget {
  final String nextRoute;

  const VerificationCodePage({super.key, required this.nextRoute});

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final List<TextEditingController> _controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  void _verify() {
    // final code =
        // _controllers.map((c) => c.text).join();
        //
        // if (code.length < 5) return;
        // context.go(widget.nextRoute); // replace stack
    if(widget.nextRoute == 'call_logs'){
      context.push('${AppRoutes.callLogs}?tab=call_logs',);
      // context.push(
      //   Uri(
      //     path: AppRoutes.verificationCode,
      //     queryParameters: {'next': widget.continueRoute},
      //   ).toString(),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 17.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        // centerTitle: false,
        // toolbarHeight: 64,
        // title: Text(
        //   widget.appBarTitle,
        //   style: const TextStyle(
        //     color: Colors.white,
        //     fontSize: 17,
        //     fontWeight: FontWeight.w700,
        //     fontFamily: 'CircularPro',
        //   ),
        // ),
      ),
      bottomNavigationBar: const SafeArea(top: false, child: BottomStripes()),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(41, 24, 41, 24),
            child: Column(
              children: [
                const SizedBox(height: 32),

                /// Illustration (replace with SVG if needed)
                SvgPicture.asset(
                  AssetConstant.otpPhoneSVG,
                  // width: LoginOtpSizes.otpImageWidth,
                  height: 170,
                ),
                const SizedBox(height: 21),

                Text(
                  'verification code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF010101),
                    fontSize: 24,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'we have sent a verification code to your email and via sms',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF58677D),
                    fontSize: 15,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                    height: 1.47,
                  ),
                ),

                const SizedBox(height: 24),

                /// OTP Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: TextField(
                          controller: _controllers[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          decoration: InputDecoration(
                            counterText: '',
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFDFDFDF),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF645D9C),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 54),

                /// Verify Button
                GestureDetector(
                  onTap: _verify,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF645D9C),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'verify',
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

                const SizedBox(height: 20),

                /// Resend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'didn\'t receive a code? ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF121212),
                        fontSize: 14,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                      ),
                    ),

                    // const SizedBox(height: 20),

                    Text(
                      'resend code',
                      style: TextStyle(
                        color: const Color(0xFF645D9C),
                        fontSize: 13,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
