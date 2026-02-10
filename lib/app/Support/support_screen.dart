import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_bottom_stripes.dart';
import 'package:myaliv_mobile_app/app/Support/widgets/support_tile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../router/app_routes.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const Color purple = Color(0xFF645D9C);
  static const Color divider = Color(0xFFE1E1E1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: purple,
        centerTitle: false,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 29.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
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
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(left: 24,right: 20),
                children: [
                  GestureDetector(
                    onTap: () {
                      context.push(AppRoutes.chatScreen);
                    },
                    child: SupportTile(title: 'chat Bot'),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(
                        'https://www.bealiv.com/store-locator/',
                      );

                      if (!await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      )) {
                        throw 'Could not open store locator';
                      }
                    },

                    child: SupportTile(title: 'store locator'),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.push(AppRoutes.callSupportScreen);
                    },

                    child: SupportTile(title: 'support'),
                  ),
                  SupportTile(title: 'whatsapp'),
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(
                        'https://www.bealiv.com/aliv-mobile-faqs/',
                      );

                      if (!await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                      )) {
                      throw 'Could not open store locator';
                      }
                    },
                      child: SupportTile(title: 'FAQ')),
                ],
              ),
            ),

            /// Decorative bottom strip
            const BottomStripes(),
          ],
        ),
      ),
    );
  }
}
