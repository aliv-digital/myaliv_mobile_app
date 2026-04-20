import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/model/reward_model.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';

class RewardPrepaidCard extends StatelessWidget {
  final RewardModel reward;
  final VoidCallback onGetThisPressed;
  final VoidCallback onReadMorePressed;

  const RewardPrepaidCard({
    super.key,
    required this.reward,
    required this.onGetThisPressed,
    required this.onReadMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(8, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(AssetConstant.rewardsCardBackgroundPNG, fit: BoxFit.fitHeight),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildTopSection(),
                  _buildButtonRow(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/icons/reward.svg', height: 48, width: 48),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reward.shortDesc,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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
    );
  }

  Widget _buildButtonRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onReadMorePressed,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFF1F1F8)),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: const Text(
                'read more',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF645D9C),
                  fontSize: 15,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
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
              fontSize: 15,
              fontWeight: FontWeight.w700,
              label: 'get this',
              isLoading: false,
              onPressed: onGetThisPressed,
            ),
          ),
        ),
      ],
    );
  }
}
