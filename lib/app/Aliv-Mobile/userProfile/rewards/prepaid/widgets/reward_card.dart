import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';

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
    const cardRadius = 16.0;
    const cardHeight = 210.0;

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AssetConstant.rewardsCardBackgroundPNG,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                children: [
                  // Top area: icon + left-aligned text block
                  SizedBox(
                    height: 110,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          AssetConstant.giftBoxPNG,
                          height: 44,
                          width: 44,
                        ),
                        const SizedBox(width: 12),

                        // Texts take remaining width; no overflow
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'CircularPro',
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                description,
                                maxLines: 3, // card space er vitor e thakbe
                                overflow: TextOverflow.ellipsis, // "..."
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'CircularPro',
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black.withOpacity(0.70),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: DefaultButton(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            label: 'get this',
                            isLoading: false,
                            onPressed: onGetThisPressed,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: DefaultButton(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            label: 'read more',
                            isLoading: false,
                            onPressed: onReadMorePressed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
