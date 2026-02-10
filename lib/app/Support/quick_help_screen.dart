import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_bottom_stripes.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickHelpScreen extends StatelessWidget {
  const QuickHelpScreen({super.key});

  static const Color purple = Color(0xFF645D9C);
  static const Color bg = Color(0xFFF1F2FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: purple,
        centerTitle: false,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          SvgPicture.asset('assets/icons/home.svg', color: Colors.white),
          SizedBox(width: 24),
        ],
        title: const Text(
          'support',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: const [
            Expanded(child: _Content()),
            BottomStripes(),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'get quick help!',
            style: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          _CallSupportCard(),
        ],
      ),
    );
  }
}

class _CallSupportCard extends StatelessWidget {
  const _CallSupportCard();

  static const Color border = Color(0xFFF2F2F2);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final uri = Uri(scheme: 'tel', path: '611');

        if (!await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        )) {
          throw 'Could not launch dialer';
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Please dial 611 from your mobile device for call center support',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Circular Pro',
                  fontWeight: FontWeight.w500,
                  height: 1.10,
                  letterSpacing: 0.07,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SvgPicture.asset('assets/icons/phone-call-01.svg', color: const Color(0xFF645D9C)),
          ],
        ),
      ),
    );
  }
}

class _BottomColorStrip extends StatelessWidget {
  const _BottomColorStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: Row(
        children: const [
          _ColorBlock(Color(0xFFFEC42E)),
          _ColorBlock(Color(0xFF13AEE1)),
          _ColorBlock(Color(0xFF040503)),
          _ColorBlock(Color(0xFFF397AD)),
          _ColorBlock(Color(0xFFF06B3C)),
        ],
      ),
    );
  }
}

class _ColorBlock extends StatelessWidget {
  final Color color;
  const _ColorBlock(this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(color: color));
  }
}
