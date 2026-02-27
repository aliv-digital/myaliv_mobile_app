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
              fit: BoxFit.fitHeight,
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
                        // Image.asset(
                        //   'assets/icons/giftbox.png',
                        //   height: 60,
                        //   width: 72,
                        // ),
                        SvgPicture.asset('assets/icons/reward.svg',
                          height: 48,
                          width: 48,
                        ),

                        const SizedBox(width: 20),

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
                                  fontFamily: 'CircularPro',
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
                                  fontFamily: 'CircularPro',
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
                        child: GestureDetector(
                          onTap: (){
                            context.push(
                              AppRoutes.rewardDetailsPrepaidScreen,
                            );
                          },
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: const Color(0xFFF1F1F8),
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: Text(
                              'read more',textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF645D9C),
                                fontSize: 13,
                                fontFamily: 'CircularPro',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
                            label: 'get this',
                            isLoading: false,
                            onPressed: (){
                              context.go(
                                AppRoutes.plans,
                              );

                              },
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
