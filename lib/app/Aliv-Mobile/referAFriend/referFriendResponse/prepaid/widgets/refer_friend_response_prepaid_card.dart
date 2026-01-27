import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../bloc/refer_friend_response_prepaid_bloc.dart';
import '../bloc/refer_friend_response_prepaid_event.dart';
import '../bloc/refer_friend_response_prepaid_state.dart';
import '../theme/refer_friend_response_prepaid_theme.dart';
import 'refer_friend_response_prepaid_button.dart';
import 'refer_friend_response_prepaid_icon.dart';
import 'refer_friend_response_prepaid_referral_row.dart';

class ReferFriendResponsePrepaidCard extends StatelessWidget {
  const ReferFriendResponsePrepaidCard({super.key});

  //  তোমার sms svg asset path এখানে বসাবে
  static const String _smsSvgAsset = AssetConstant.smsSVG;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ReferFriendResponsePrepaidTheme.border),
      ),
      child: BlocBuilder<ReferFriendResponsePrepaidBloc, ReferFriendResponsePrepaidState>(
        buildWhen: (p, c) => p.referralCode != c.referralCode,
        builder: (context, state) {
          final code = state.referralCode.isEmpty ? '—' : state.referralCode;

          return Column(
            children: [
              const SizedBox(height: 10),
              const ReferFriendResponsePrepaidIcon(assetPath: _smsSvgAsset),
              const SizedBox(height: 16),

              const Text('Inviting Success!', style: ReferFriendResponsePrepaidTheme.title),
              const SizedBox(height: 32),

              const Text(
                "Thank you for inviting your friend to join\n"
                    "the ALIV network! once they’re on the\n"
                    "network for three months, you will\n"
                    "receive your cash back reward.",
                textAlign: TextAlign.center,
                style: ReferFriendResponsePrepaidTheme.subtitle,
              ),

              const SizedBox(height: 24),

              const Text('Your referral code is:', style: ReferFriendResponsePrepaidTheme.label),
              const SizedBox(height: 10),

              ReferFriendResponsePrepaidReferralRow(
                code: code,
                onCopied: () => context
                    .read<ReferFriendResponsePrepaidBloc>()
                    .add(ReferFriendResponsePrepaidCopyPressed(code)),
              ),

              const SizedBox(height: 32),
              const Divider(height: 1, color: ReferFriendResponsePrepaidTheme.border),
              const SizedBox(height: 32),

              ReferFriendResponsePrepaidButton(
                label: 'back to home page',
                onTap: () {
                  // ✅ তুমি route set করবে
                  // context.go(AppRoutes.homeScreen);

                  // fallback:
                  context.pop();
                },
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}
