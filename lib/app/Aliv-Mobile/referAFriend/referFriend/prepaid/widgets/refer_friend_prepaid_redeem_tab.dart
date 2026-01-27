import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../bloc/refer_friend_prepaid_bloc.dart';
import '../bloc/refer_friend_prepaid_event.dart';
import '../bloc/refer_friend_prepaid_state.dart';
import '../theme/refer_friend_prepaid_theme.dart';
import 'refer_friend_prepaid_illustration.dart';
import 'refer_friend_prepaid_labeled_field.dart';
import 'refer_friend_prepaid_primary_button.dart';

class ReferFriendPrepaidRedeemTab extends StatelessWidget {
  const ReferFriendPrepaidRedeemTab({super.key});

  // TODO: তুমি path set করবে
  static const String _redeemSvgAsset = AssetConstant.redeemPNG;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const ReferFriendPrepaidIllustration(assetPath: _redeemSvgAsset),
          const SizedBox(height: 18),

          BlocBuilder<ReferFriendPrepaidBloc, ReferFriendPrepaidState>(
            buildWhen: (p, c) => p.redeemCode != c.redeemCode || p.redeemStatus != c.redeemStatus,
            builder: (context, state) {
              final loading = state.redeemStatus == ReferFriendPrepaidSubmitStatus.submitting;

              return Column(
                children: [
                  ReferFriendPrepaidLabeledField(
                    label: "enter referral code",
                    hint: "405783",
                    keyboardType: TextInputType.number,
                    value: state.redeemCode,
                    onChanged: (v) => context
                        .read<ReferFriendPrepaidBloc>()
                        .add(ReferFriendPrepaidRedeemCodeChanged(v)),
                  ),
                  const SizedBox(height: 18),
                  ReferFriendPrepaidPrimaryButton(
                    label: 'redeem',
                    enabled: state.canRedeem && !loading,
                    isLoading: loading,
                    onTap: () => context
                        .read<ReferFriendPrepaidBloc>()
                        .add(const ReferFriendPrepaidRedeemPressed()),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 22),

          Text(
            "if you are a postpaid customer, you will\nreceive an invoice credit.",
            textAlign: TextAlign.center,
            style: ReferFriendPrepaidTheme.helper,
          ),
          const SizedBox(height: 14),
          const Text(
            "or",
            style: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: ReferFriendPrepaidTheme.muted,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "if you are a prepaid customer, you will\nreceive bonus wallet credit via the myALIV\napp within 24 hours.",
            textAlign: TextAlign.center,
            style: ReferFriendPrepaidTheme.helper,
          ),
        ],
      ),
    );
  }
}
