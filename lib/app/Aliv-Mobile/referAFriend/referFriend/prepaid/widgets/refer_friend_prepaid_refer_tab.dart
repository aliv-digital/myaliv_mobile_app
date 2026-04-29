import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/refer_friend_prepaid_bloc.dart';
import '../bloc/refer_friend_prepaid_event.dart';
import '../bloc/refer_friend_prepaid_state.dart';
import '../utils/refer_friend_prepaid_email_helper.dart';
import 'refer_friend_prepaid_illustration.dart';
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
  late TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        final uri = Uri.parse('https://www.bealiv.com/terms-of-use/');

        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw 'Could not open store locator';
        }
      };
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const ReferFriendPrepaidIllustration(
            assetPath: ReferFriendPrepaidReferTab._referSvgAsset,
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 32),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text:
                        'bring a friend and you’ll both receive a cash back reward when they join the ALIV network. ',
                    style: TextStyle(
                      color: const Color(0xFF58677D),
                      fontSize: 14,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    recognizer: _termsRecognizer,
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: const Color(0xFF58677D),
                      fontSize: 14,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' apply',
                    style: TextStyle(
                      color: const Color(0xFF58677D),
                      fontSize: 14,
                      fontFamily: 'CircularPro',
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
            buildWhen: (p, c) => p.friendEmail != c.friendEmail || p.friendEmailFieldError != c.friendEmailFieldError,
            builder: (context, state) {
              const ReferFriendPrepaidEmailHelper emailHelper = ReferFriendPrepaidEmailHelper();
              final bool showLiveEmailValidationError = emailHelper.hasLiveValidationError(state.friendEmail);
              final bool showEmailError = state.friendEmailFieldError || showLiveEmailValidationError;

              return Column(
                children: [
                  const ReferFriendPrepaidPhoneRow(),
                  const SizedBox(height: 16),
                  ReferFriendPrepaidLabeledField(
                    label: "friend’s email address",
                    hint: "enter email address",
                    keyboardType: TextInputType.emailAddress,
                    value: state.friendEmail,
                    showError: showEmailError,
                    highlightInputAsError: showLiveEmailValidationError,
                    errorText: ReferFriendPrepaidEmailHelper.invalidEmailMessage,
                    // Email stays borderless in the neutral idle state.
                    showUnfocusedBorder: false,
                    onChanged: (v) => context.read<ReferFriendPrepaidBloc>().add(ReferFriendPrepaidFriendEmailChanged(v)),
                  ),
                  const SizedBox(height: 40),
                  BlocSelector<ReferFriendPrepaidBloc,ReferFriendPrepaidState,({bool canShare, bool loading})>(
                    selector: (state) => (
                      canShare: state.canShare,
                      loading: state.shareStatus == ReferFriendPrepaidSubmitStatus.submitting,
                    ),
                    builder: (context, buttonState) {
                      return ReferFriendPrepaidPrimaryButton(
                        label: 'share',
                        enabled: buttonState.canShare && !buttonState.loading,
                        isLoading: buttonState.loading,
                        onTap: () => context.read<ReferFriendPrepaidBloc>().add(
                          const ReferFriendPrepaidSharePressed(),
                        ),
                      );
                    },
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
