import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

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
              final loading =
                  state.redeemStatus ==
                  ReferFriendPrepaidSubmitStatus.submitting;

              return Column(
                children: [
                  ReferFriendPrepaidLabeledField(
                    label: "enter referral code",
                    hint: "405783",
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
                    onTap: (){
                      AppToast.show(message: 'success! you will receive bonus wallet credit via the myALIV app within 24 hours',);
                    },
                    // onTap: () => context.read<ReferFriendPrepaidBloc>().add(
                    //   const ReferFriendPrepaidRedeemPressed(),
                    // ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 30),

          Text(
            "if you are a postpaid customer, you will\nreceive an invoice credit.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF58677D),
              fontSize: 14,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "or",
            style: TextStyle(
              color: const Color(0xFF58677D),
              fontSize: 14,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "if you are a prepaid customer, you will\nreceive bonus wallet credit via the myALIV\napp within 24 hours.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF58677D),
              fontSize: 14,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
