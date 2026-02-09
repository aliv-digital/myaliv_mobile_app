import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/send_top_up_phone_field.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/top_up_prepaid_amount_box.dart';
import '../theme/top_up_prepaid_theme.dart';
import '../view/send_top_up_confirmation_screen.dart';

class SendTopUpPlaceholderTab extends StatefulWidget {
  final String title;

  SendTopUpPlaceholderTab({super.key, required this.title});

  @override
  State<SendTopUpPlaceholderTab> createState() => _SendTopUpPlaceholderTabState();
}

class _SendTopUpPlaceholderTabState extends State<SendTopUpPlaceholderTab> {
  String _amount = '15.00';
 // 🔥 default amount (matches design)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TopUpPrepaidTheme.pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= TRANSFER FROM =================
              const _SectionLabel('transfer from'),
              const SizedBox(height: 8),

              _ReadOnlyField('wallet \$ 129.00'),

              const SizedBox(height: 24),

              // ================= ENTER NUMBER =================
              const _SectionLabel('enter number to top up'),
              const SizedBox(height: 8),
              SendTopUpPhoneField(hint: 'eg: 242-899-9999'),

              const SizedBox(height: 24),

              const _SectionLabel('confirm number to top up'),
              const SizedBox(height: 8),
              SendTopUpPhoneField(hint: 'eg: 242-899-9999'),

              const SizedBox(height: 32),

              // ================= CURRENT BALANCE =================
              Center(
                child:Text(
                  'current balance: \$129.00',
                  style: TextStyle(
                    color: const Color(0xFF1C1C1C) /* Black-100% */,
                    fontSize: 14,
                    fontFamily: 'Circular Pro',
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                  ),
                )
              ),

              const SizedBox(height: 24),

              // ================= AMOUNT CARD =================

              Center(
                child: TopUpPrepaidAmountBox(
                  value: _amount,
                  onChanged: (v) {
                    setState(() {
                      _amount = v;
                    });
                  },
                ),
              ),

              const SizedBox(height: 52),

              // ================= PROCEED =================
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SendTopUpConfirmationScreen(),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: TopUpPrepaidTheme.purple,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'proceed',
                    style: TextStyle(
                      color: const Color(0xFFF1F1F8),
                      fontSize: 13,
                      fontFamily: 'Circular Pro',
                      fontWeight: FontWeight.w500,
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

/* -------------------------------------------------------------------------- */
/*                                  WIDGETS                                   */
/* -------------------------------------------------------------------------- */

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color:  Color(0xFF1C1C1C) /* Black-100% */,

        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String value;
  const _ReadOnlyField(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        value,
        style: const TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 14,
          color: const Color(0xFF707070),
          fontWeight: FontWeight.w400,
          height: 1.43,
        ),
      ),
    );
  }
}

class _InputPlaceholder extends StatelessWidget {
  final String hint;
  const _InputPlaceholder(this.hint);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: TopUpPrepaidTheme.lightBg,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        hint,
        style: TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 15,
          color: TopUpPrepaidTheme.textMuted,
        ),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final int amount;
  const _AmountCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: TopUpPrepaidTheme.amountBorderGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        width: 220,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$ $amount.00',
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: TopUpPrepaidTheme.purple,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'enter top up amount',
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 13,
                color: TopUpPrepaidTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
