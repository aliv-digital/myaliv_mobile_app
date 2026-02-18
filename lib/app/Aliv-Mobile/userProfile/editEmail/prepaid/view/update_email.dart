import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../router/app_routes.dart';
import '../../../../login/widgets/login_bottom_stripes.dart';


class UpdateEmailPage extends StatefulWidget {
  const UpdateEmailPage({super.key});

  @override
  State<UpdateEmailPage> createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends State<UpdateEmailPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateEmail() {
    final email = _controller.text.trim();
    // if (email.isEmpty) return;

    context.push(
      Uri(
        path: AppRoutes.verifyEmail,
        queryParameters: {
          'email': email,
        },
      ).toString(),
    );
    // call API here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar:
      const SafeArea(top: false, child: BottomStripes()),
      // appBar: AppBar(
      //   backgroundColor:Colors.white,
      //   elevation: 0,
      //   leading: Padding(
      //     padding: const EdgeInsets.only(top: 16.0,left: 16),
      //     child: IconButton(
      //       icon: const Icon(Icons.arrow_back_ios,
      //           size: 17, color: Colors.black),
      //       onPressed: () => context.pop(),
      //     ),
      //   ),
      // ),
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 53.0,left: 16),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  size: 17, color: Colors.black),
              onPressed: () => context.pop(),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(41, 80, 41, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
            
            
                    // const SizedBox(height: 40),
            
                    /// Title
                    const Text(
                      'update email address',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF010101),
                        fontSize: 24,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            
                    const SizedBox(height: 16),
            
                    const Text(
                      'enter a new email address',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF58677D),
                        fontSize: 15,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w500,
                        height: 1.47,
                      ),
                    ),
            
                    const SizedBox(height: 32),
            
                    /// Input Field
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFDFDFDF),
                        ),
                      ),
                      child: Row(

                        children: [
                          SvgPicture.asset('assets/icons/EnvelopeSimple.svg'),
                          const SizedBox(width: 5),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'enter a new email',
                                hintStyle: TextStyle(
                                  color: const Color(0xFF667085) /* Colors-Text-text-placeholder */,
                                  fontSize: 14,
                                  fontFamily: 'CircularPro',
                                  fontWeight: FontWeight.w500,
                                  height: 1.43,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            
                    const SizedBox(height: 32),
            
                    /// Button
                    GestureDetector(
                      onTap: _updateEmail,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF645D9C),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'update email',
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
