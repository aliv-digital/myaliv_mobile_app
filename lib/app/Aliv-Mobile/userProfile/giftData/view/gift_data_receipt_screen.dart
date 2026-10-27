import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/gift_data_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/gift_receipt_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class GiftDataReceiptScreen extends StatelessWidget {
  const GiftDataReceiptScreen({super.key, required this.data});

  final GiftDataReceiptData data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GiftDataTheme.receiptBg,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: DefaultAppBar(
                showBackArrow: false,
                title: 'my receipt',
                onBack: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 29, 24, 30),
                child: GiftReceiptCard(
                  data: data,
                  onGiftAgain: () =>
                      context.pushReplacement(AppRoutes.giftData),
                  onBackHome: () => context.go(AppRoutes.home),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
