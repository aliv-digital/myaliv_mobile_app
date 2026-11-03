import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/widgets/app_keyboard_toolbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../bloc/refer_friend_prepaid_bloc.dart';
import '../bloc/refer_friend_prepaid_event.dart';
import '../bloc/refer_friend_prepaid_state.dart';
import '../utils/refer_friend_prepaid_email_helper.dart';
import 'refer_friend_prepaid_illustration.dart';
import 'refer_friend_prepaid_info_html.dart';
import 'refer_friend_prepaid_labeled_field.dart';
import 'refer_friend_prepaid_phone_row.dart';
import 'refer_friend_prepaid_primary_button.dart';

class ReferFriendPrepaidReferTab extends StatefulWidget {
  const ReferFriendPrepaidReferTab({super.key});

  static const String _referSvgAsset = AssetConstant.announcePNG;

  @override
  State<ReferFriendPrepaidReferTab> createState() =>
      _ReferFriendPrepaidReferTabState();
}

class _ReferFriendPrepaidReferTabState
    extends State<ReferFriendPrepaidReferTab> {
  final FocusNode _phoneFocusNode = FocusNode(debugLabel: 'referFriendPhone');
  final FocusNode _emailFocusNode = FocusNode(debugLabel: 'referFriendEmail');

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _share() {
    context.read<ReferFriendPrepaidBloc>().add(
      const ReferFriendPrepaidSharePressed(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppKeyboardToolbar(
      focusNodes: [_phoneFocusNode, _emailFocusNode],
      onDone: _share,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const ReferFriendPrepaidIllustration(
              assetPath: ReferFriendPrepaidReferTab._referSvgAsset,
            ),
            const SizedBox(height: 30),
            BlocSelector<
              ReferFriendPrepaidBloc,
              ReferFriendPrepaidState,
              String
            >(
              selector: (state) => state.referInfoHtml,
              builder: (context, referInfoHtml) {
                return ReferFriendPrepaidInfoHtml(
                  htmlContent: referInfoHtml,
                  linkTermsText: true,
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                );
              },
            ),
            const SizedBox(height: 30),
            BlocBuilder<ReferFriendPrepaidBloc, ReferFriendPrepaidState>(
              buildWhen: (p, c) =>
                  p.friendEmail != c.friendEmail ||
                  p.friendEmailFieldError != c.friendEmailFieldError,
              builder: (context, state) {
                const emailHelper = ReferFriendPrepaidEmailHelper();
                final showLiveEmailValidationError = emailHelper
                    .hasLiveValidationError(state.friendEmail);
                final showEmailError =
                    state.friendEmailFieldError || showLiveEmailValidationError;

                return Column(
                  children: [
                    ReferFriendPrepaidPhoneRow(focusNode: _phoneFocusNode),
                    const SizedBox(height: 16),
                    ReferFriendPrepaidLabeledField(
                      focusNode: _emailFocusNode,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _share(),
                      label: "friend’s email address",
                      hint: "enter email address",
                      keyboardType: TextInputType.emailAddress,
                      value: state.friendEmail,
                      showError: showEmailError,
                      highlightInputAsError: showLiveEmailValidationError,
                      errorText: state.friendEmail.trim().isEmpty
                          ? "Please enter your referral's email address."
                          : ReferFriendPrepaidEmailHelper.invalidEmailMessage,
                      // Email stays borderless in the neutral idle state.
                      showUnfocusedBorder: false,
                      onChanged: (v) => context
                          .read<ReferFriendPrepaidBloc>()
                          .add(ReferFriendPrepaidFriendEmailChanged(v)),
                    ),
                    const SizedBox(height: 40),
                    BlocSelector<
                      ReferFriendPrepaidBloc,
                      ReferFriendPrepaidState,
                      ({bool canShare, bool loading})
                    >(
                      selector: (state) => (
                        canShare: state.canShare,
                        loading:
                            state.shareStatus ==
                            ReferFriendPrepaidSubmitStatus.submitting,
                      ),
                      builder: (context, buttonState) {
                        return ReferFriendPrepaidPrimaryButton(
                          label: 'share',
                          enabled: !buttonState.loading,
                          isLoading: buttonState.loading,
                          onTap: () => context
                              .read<ReferFriendPrepaidBloc>()
                              .add(const ReferFriendPrepaidSharePressed()),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
