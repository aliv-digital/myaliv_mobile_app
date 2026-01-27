import 'package:flutter/material.dart';
import '../../../purchases/prepaid/widgets/currency_amount_input.dart';
import '../theme/top_up_prepaid_theme.dart';

class AutoRenewAuthorizationScreen extends StatelessWidget {
  const AutoRenewAuthorizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: TopUpPrepaidTheme.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'auto renew authorization form',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= TEXT BLOCK =================
              const Text(
                'by providing my credit card ending *xxxx as payment method, '
                'I authorize ALIV and/or its agents to store my payment method '
                'information and to automatically charge plan renewal costs of '
                'qualifying plans for all subscriber lines on my account. '
                'I am certifying I am the payment method owner or have '
                'authorization to use the payment method information provided '
                'for the automatic charging of plan renewal costs.',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 24),

              // ================= SECTION TITLE =================
              const Text(
                'electronic communication consent',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'by entering my pin, full name matching the name displayed and '
                'clicking agree, I am providing my electronic signature as '
                'evidence that I understand the terms I am agreeing. '
                'In addition, I understand this automatic payment authorization '
                'will remain in effect until canceled by me via the myALIV app. '
                'The complete ALIV automatic payment policy will be sent to your '
                'account email address.',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 24),

              // ================= SIGNATURE NAME =================
              const Text(
                'James Brown',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 24),

              // ================= INPUT LABEL =================
              const Text(
                'name',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              // ================= INPUT FIELD =================
              // Container(
              //   height: 52,
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   decoration: BoxDecoration(
              //     color: TopUpPrepaidTheme.lightBg,
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   alignment: Alignment.centerLeft,
              //   child: TopUpFormInputField(
              //     hint: 'type your name exactly as it appears on your account',
              //     isAmountType: false,
              //   ),
              // ),
              TopUpFormInputField(
                hint: 'type your name exactly as it appears on your account',
                isAmountType: false,
              ),
              const SizedBox(height: 40),

              // ================= SUBMIT =================
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // UI only – no logic yet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TopUpPrepaidTheme.purple,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'submit',
                    style: TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
