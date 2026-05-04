import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../bloc/refer_friend_prepaid_bloc.dart';
import '../bloc/refer_friend_prepaid_event.dart';
import '../bloc/refer_friend_prepaid_state.dart';
import 'refer_friend_prepaid_illustration.dart';
import 'refer_friend_prepaid_info_html.dart';
import 'refer_friend_prepaid_labeled_field.dart';
import 'refer_friend_prepaid_primary_button.dart';

class ReferFriendPrepaidRedeemTab extends StatelessWidget {
  const ReferFriendPrepaidRedeemTab({super.key});

  static const String _redeemSvgAsset = AssetConstant.redeemPNG;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          const ReferFriendPrepaidIllustration(assetPath: _redeemSvgAsset),
          const SizedBox(height: 30),
          BlocBuilder<ReferFriendPrepaidBloc, ReferFriendPrepaidState>(
            buildWhen: (p, c) =>
                p.redeemCode != c.redeemCode ||
                p.redeemStatus != c.redeemStatus,
            builder: (context, state) {
              final loading = state.redeemStatus ==
                  ReferFriendPrepaidSubmitStatus.submitting;

              return Column(
                children: [
                  ReferFriendPrepaidLabeledField(
                    label: "enter referral code",
                    hint: "code",
                    keyboardType: TextInputType.text,
                    value: state.redeemCode,
                    onChanged: (v) => context
                        .read<ReferFriendPrepaidBloc>()
                        .add(ReferFriendPrepaidRedeemCodeChanged(v)),
                  ),
                  const SizedBox(height: 26),
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
          const SizedBox(height: 30),
          BlocSelector<ReferFriendPrepaidBloc, ReferFriendPrepaidState, String>(
            selector: (state) => state.redeemInfoHtml,
            builder: (context, redeemInfoHtml) {
              return ReferFriendPrepaidInfoHtml(htmlContent: redeemInfoHtml);
            },
          ),
        ],
      ),
    );
  }
}
