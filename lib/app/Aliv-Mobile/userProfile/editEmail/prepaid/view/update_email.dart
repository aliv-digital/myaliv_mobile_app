import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

import '../../../../../../router/app_routes.dart';
import '../../../../login/widgets/login_bottom_stripes.dart';
import '../repository/edit_email_prepaid_repository.dart';
import '../theme/edit_email_prepaid_theme.dart';

class UpdateEmailPage extends StatefulWidget {
  const UpdateEmailPage({super.key});

  @override
  State<UpdateEmailPage> createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends State<UpdateEmailPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final EditEmailPrepaidRepository _repository = EditEmailPrepaidRepository();

  bool _hasEmailFocus = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onEmailFocusChanged);
  }

  @override
  void dispose() {
    _emailFocusNode.removeListener(_onEmailFocusChanged);
    _emailFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onEmailFocusChanged() {
    if (_hasEmailFocus != _emailFocusNode.hasFocus) {
      setState(() {
        _hasEmailFocus = _emailFocusNode.hasFocus;
      });
    }
  }

  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> _updateEmail() async {
    final email = _controller.text.trim();

    // Validate email
    if (email.isEmpty) {
      setState(() => _errorMessage = 'please enter an email address');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = 'please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _repository.updateEmail(email);

      if (success) {
        // Refresh account data
        await _repository.refreshAccountData();

        if (!mounted) return;

        // Navigate to success screen
        context.pushReplacement(
          Uri(
            path: AppRoutes.verifyEmail,
            queryParameters: {'email': email},
          ).toString(),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'failed to update email. please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'failed to update email. please try again.';
      });

      AppToast.show(
        message: 'failed to update email',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const SafeArea(top: false, child: BottomStripes()),
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 64,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 24),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 17, color: Colors.black),
            onPressed: _isLoading ? null : () => context.pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(41, 80, 41, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                Builder(
                  builder: (context) {
                    final innerRadius =
                        (EditEmailPrepaidTheme.updateEmailInputRadius -
                                EditEmailPrepaidTheme.inputBorderWidth)
                            .clamp(
                      0.0,
                      EditEmailPrepaidTheme.updateEmailInputRadius,
                    );

                    return Container(
                      decoration: BoxDecoration(
                        gradient: _hasEmailFocus
                            ? EditEmailPrepaidTheme.focusedInputBorderGradient
                            : null,
                        border: _hasEmailFocus
                            ? null
                            : Border.all(
                                color: _errorMessage != null
                                    ? Colors.red
                                    : EditEmailPrepaidTheme.inputBorder,
                                width: EditEmailPrepaidTheme.inputBorderWidth,
                              ),
                        borderRadius: BorderRadius.circular(
                          EditEmailPrepaidTheme.updateEmailInputRadius,
                        ),
                      ),
                      padding: const EdgeInsets.all(
                        EditEmailPrepaidTheme.inputBorderWidth,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(innerRadius),
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              EditEmailPrepaidTheme.updateEmailInputRadius,
                            ),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/EnvelopeSimple.svg',
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: TextField(
                                  focusNode: _emailFocusNode,
                                  controller: _controller,
                                  enabled: !_isLoading,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (_) {
                                    if (_errorMessage != null) {
                                      setState(() => _errorMessage = null);
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'enter a new email',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF667085),
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
                      ),
                    );
                  },
                ),

                /// Error Message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontFamily: 'CircularPro',
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                /// Button
                GestureDetector(
                  onTap: _isLoading ? null : _updateEmail,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? const Color(0xFF645D9C).withOpacity(0.6)
                          : const Color(0xFF645D9C),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
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
    );
  }
}
