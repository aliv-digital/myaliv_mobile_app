import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';

import '../../../../../../router/app_routes.dart';

class RewardPrepaidCard extends StatelessWidget {
  final String title;
  final String description;
  final String amount;
  final VoidCallback onGetThisPressed;
  final VoidCallback onReadMorePressed;

  const RewardPrepaidCard({
    super.key,
    required this.title,
    required this.description,
    required this.amount,
    required this.onGetThisPressed,
    required this.onReadMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    const cardRadius = 8.0;
    const cardHeight = 210.0;

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(8, 10),
            spreadRadius: 0,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AssetConstant.rewardsCardBackgroundPNG,
              fit: BoxFit.none,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                children: [
                  // Top area: icon + left-aligned text block
                  SizedBox(
                    height: 110,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/giftbox.png',
                          height: 60,
                          width: 72,
                        ),
                        const SizedBox(width: 8),

                        // Texts take remaining width; no overflow
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontFamily: 'Circular Pro',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                description,
                                maxLines: 3, // card space er vitor e thakbe
                                overflow: TextOverflow.ellipsis, // "..."
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: 'Circular Pro',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // SizedBox(height: 18,),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: DefaultButton(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            label: 'get this',
                            isLoading: false,
                            onPressed: (){},
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: DefaultButton(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            label: 'read more',
                            isLoading: false,
                            onPressed: (){
                              context.push(
                                AppRoutes.rewardDetailsPrepaidScreen,
                              );                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
