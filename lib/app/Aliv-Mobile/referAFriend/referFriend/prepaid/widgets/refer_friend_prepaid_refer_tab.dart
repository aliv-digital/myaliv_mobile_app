import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../../../../../../resources/widgets/custom_country_phone_input_row.dart';
import '../../../../../../router/app_routes.dart';
import '../../../../../Aliv-Mobile-Guest/guestTopUp/theme/guest_topup_theme.dart';
import '../../../../../Aliv-Mobile-Guest/guestTopUp/widgets/phone_number_input.dart';
import '../../../../login/widgets/login_phone_row.dart';
import '../bloc/refer_friend_prepaid_bloc.dart';
import '../bloc/refer_friend_prepaid_event.dart';
import '../bloc/refer_friend_prepaid_state.dart';
import '../theme/refer_friend_prepaid_theme.dart';
import 'refer_friend_prepaid_illustration.dart';
import 'refer_friend_prepaid_labeled_field.dart';
import 'refer_friend_prepaid_primary_button.dart';

class ReferFriendPrepaidReferTab extends StatefulWidget {

   const ReferFriendPrepaidReferTab({super.key});

  // TODO: তুমি path set করবে
  static const String _referSvgAsset = AssetConstant.announcePNG;
  static const CountryInfo _defaultCountry = CountryInfo(
    flagEmoji: '🇧🇸',
    dialCode: '1',
    isoCode: 'BS',
  );

  @override
  State<ReferFriendPrepaidReferTab> createState() => _ReferFriendPrepaidReferTabState();
}

class _ReferFriendPrepaidReferTabState extends State<ReferFriendPrepaidReferTab> {
  CountryInfo _selectedCountry = ReferFriendPrepaidReferTab._defaultCountry;

   void _pickCountry(BuildContext context) {
     showCountryPicker(
       context: context,
       showPhoneCode: true,
       // Keep using the previous package while rendering flat flag assets.
       customFlagBuilder: (Country country) {
         // `country_pickers` does not include `ac.png`, so map AC -> SH asset.
         final String assetIsoCode = country.countryCode.toUpperCase() == 'AC'
             ? 'sh'
             : country.countryCode.toLowerCase();

         return Image.asset(
           'assets/$assetIsoCode.png',
           package: 'country_pickers',
           width: 26,
           height: 20,
           fit: BoxFit.cover,
           errorBuilder: (context, error, stackTrace) {
             return Text(country.flagEmoji,
                 style: const TextStyle(fontSize: 18));
           },
         );
       },
       onSelect: (Country country) {
         setState(() {
           _selectedCountry = CountryInfo(
             flagEmoji: country.flagEmoji,
             dialCode: country.phoneCode.split(RegExp(r'[\\s-]')).first,
             isoCode: country.countryCode,
           );
         });
       },
     );
   }

   @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const ReferFriendPrepaidIllustration(assetPath: ReferFriendPrepaidReferTab._referSvgAsset),
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
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
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
            buildWhen: (p, c) =>
            p.friendPhone != c.friendPhone ||
                p.friendEmail != c.friendEmail ||
                p.shareStatus != c.shareStatus,
            builder: (context, state) {
              final loading = state.shareStatus == ReferFriendPrepaidSubmitStatus.submitting;

              return Column(
                children: [
                  // ReferFriendPrepaidLabeledField(
                  //   label: "friend’s number",
                  //   hint: "242-455-7878",
                  //   keyboardType: TextInputType.phone,
                  //   value: state.friendPhone,
                  //   onChanged: (v) => context
                  //       .read<ReferFriendPrepaidBloc>()
                  //       .add(ReferFriendPrepaidFriendPhoneChanged(v)),
                  // ),
                  //
                  // const LoginPhoneRow(),

                  CustomCountryPhoneInputRow(

                    labelText: "friend’s number",//GuestTopUpTheme.confirmMobileLabel,
                    hintText: "242-455-7878",//GuestTopUpTheme.phoneHintText,
                    flagEmoji: _selectedCountry.flagEmoji,
                    enableCountryPicker: true,
                    showCountryArrow: true,
                    dialCode: _selectedCountry.dialCode,
                    countryIsoCode: _selectedCountry.isoCode,
                    // onChanged: (value) {},
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
                    enabled: true,//state.canShare && !loading,
                    isLoading: loading,
                    // onTap: () => context
                    //     .read<ReferFriendPrepaidBloc>()
                    //     .add(const ReferFriendPrepaidSharePressed()),
                    onTap: (){
                      context.go(
                        '${AppRoutes.invitingSuccess}?code=REF026BFDFEA12',
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
