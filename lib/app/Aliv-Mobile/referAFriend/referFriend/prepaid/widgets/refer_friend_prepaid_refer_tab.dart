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

class ReferFriendPrepaidReferTab extends StatelessWidget {
  const ReferFriendPrepaidReferTab({super.key});

  // TODO: তুমি path set করবে
  static const String _referSvgAsset = AssetConstant.announcePNG;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const ReferFriendPrepaidIllustration(assetPath: _referSvgAsset),
          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.only(left: 32.0,right: 32),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'bring a friend and you’ll both receive a cash back reward when they join the ALIV network. ',
                    style: TextStyle(
                      color: const Color(0xFF58677D),
                      fontSize: 14,
                      fontFamily: 'Circular Pro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: const Color(0xFF58677D),
                      fontSize: 14,
                      fontFamily: 'Circular Pro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' apply',
                    style: TextStyle(
                      color: const Color(0xFF58677D),
                      fontSize: 14,
                      fontFamily: 'Circular Pro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 30),

          BlocBuilder<ReferFriendPrepaidBloc, ReferFriendPrepaidState>(
            buildWhen: (p, c) =>
            p.friendPhone != c.friendPhone ||
                p.friendEmail != c.friendEmail ||
                p.shareStatus != c.shareStatus,
            builder: (context, state) {
              final loading = state.shareStatus == ReferFriendPrepaidSubmitStatus.submitting;

              return Column(
                children: [
                  ReferFriendPrepaidLabeledField(
                    label: "friend’s number",
                    hint: "242-455-7878",
                    keyboardType: TextInputType.phone,
                    value: state.friendPhone,
                    onChanged: (v) => context
                        .read<ReferFriendPrepaidBloc>()
                        .add(ReferFriendPrepaidFriendPhoneChanged(v)),
                  ),
                  const SizedBox(height: 16),
                  ReferFriendPrepaidLabeledField(
                    label: "friend’s email address",
                    hint: "enter email address",
                    keyboardType: TextInputType.emailAddress,
                    value: state.friendEmail,
                    onChanged: (v) => context
                        .read<ReferFriendPrepaidBloc>()
                        .add(ReferFriendPrepaidFriendEmailChanged(v)),
                  ),
                  const SizedBox(height: 40),
                  ReferFriendPrepaidPrimaryButton(
                    label: 'share',
                    enabled: state.canShare && !loading,
                    isLoading: loading,
                    onTap: () => context
                        .read<ReferFriendPrepaidBloc>()
                        .add(const ReferFriendPrepaidSharePressed()),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
