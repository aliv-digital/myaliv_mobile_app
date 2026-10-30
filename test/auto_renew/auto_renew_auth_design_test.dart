import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/repository/auto_renew_auth_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/theme/auto_renew_auth_prepaid_theme.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';

class MockAccountInfoCubit extends Mock implements AccountInfoCubit {}

class MockDeviceLimitsCubit extends Mock implements DeviceLimitsCubit {}

void main() {
  group('Bug 36 - Auto Renew Authorization Form Design Tests', () {
    late MockAccountInfoCubit mockAccountInfoCubit;
    late MockDeviceLimitsCubit mockDeviceLimitsCubit;

    setUp(() {
      mockAccountInfoCubit = MockAccountInfoCubit();
      mockDeviceLimitsCubit = MockDeviceLimitsCubit();
      when(() => mockAccountInfoCubit.state).thenReturn(
        const AccountInfoState(
          accountInfo: AccountInfoModel(fName: 'James', lName: 'Brown'),
        ),
      );
      when(
        () => mockDeviceLimitsCubit.state,
      ).thenReturn(DeviceLimitsState.initial());

      if (instance.isRegistered<AccountInfoCubit>()) {
        instance.unregister<AccountInfoCubit>();
      }
      if (instance.isRegistered<DeviceLimitsCubit>()) {
        instance.unregister<DeviceLimitsCubit>();
      }

      instance.registerSingleton<AccountInfoCubit>(mockAccountInfoCubit);
      instance.registerSingleton<DeviceLimitsCubit>(mockDeviceLimitsCubit);
    });

    tearDown(() {
      if (instance.isRegistered<AccountInfoCubit>()) {
        instance.unregister<AccountInfoCubit>();
      }
      if (instance.isRegistered<DeviceLimitsCubit>()) {
        instance.unregister<DeviceLimitsCubit>();
      }
    });
    test(
      'AutoRenewAuthPrepaidTheme typography and spacing matches Figma specs',
      () {
        // Paragraph text style
        final paragraphStyle = AutoRenewAuthPrepaidTheme.paragraphTextStyle();
        expect(paragraphStyle.fontSize, 14);
        expect(paragraphStyle.fontWeight, FontWeight.w400);
        expect(paragraphStyle.height, 1.43);
        expect(paragraphStyle.color, const Color(0xFF707070));

        // Section header text style
        final headerStyle = AutoRenewAuthPrepaidTheme.sectionHeaderTextStyle();
        expect(headerStyle.fontSize, 16);
        expect(headerStyle.fontWeight, FontWeight.w700);
        expect(headerStyle.height, 1.25);
        expect(headerStyle.color, const Color(0xFF707070));

        // Signature text style
        final signatureStyle = AutoRenewAuthPrepaidTheme.signatureTextStyle();
        expect(signatureStyle.fontSize, 14);
        expect(signatureStyle.fontWeight, FontWeight.w700);
        expect(signatureStyle.height, 1.43);
        expect(signatureStyle.color, const Color(0xFF707070));

        // Vertical gaps between paragraphs and consent header
        expect(AutoRenewAuthPrepaidTheme.paragraphToConsentHeaderGap, 14.0);
        expect(AutoRenewAuthPrepaidTheme.consentHeaderToParagraphGap, 14.0);
        expect(AutoRenewAuthPrepaidTheme.paragraphToSignatureGap, 14.0);
      },
    );

    test(
      'AutoRenewAuthPrepaidRepository content matches Figma text formatting',
      () async {
        final repository = AutoRenewAuthPrepaidRepositoryImpl();
        final content = await repository.fetchContent(cardLastDigits: '0071');

        expect(
          content.paragraph1,
          'by providing my credit card ending *0071 as payment method, i authorize aliv and/or its agents to store my payment method information and to automatically charge plan renewal costs of qualifying plans for all subscriber lines on my account. i am certifying i am the payment method owner or have authorization to use the payment method information provided for the automatic charging of plan renewal costs.',
        );
        expect(content.consentTitle, 'electronic communication consent');
        expect(
          content.paragraph2,
          'by entering my pin, full name matching the name displayed and clicking agree, i am providing my electronic signature as evidence that i understand the terms i am to which i am agreeing. In addition, i understand this automatic payment authorization will remain in effect until canceled by me via the myaliv app. The complete aliv automatic payment policy will be sent to your account email address.',
        );
      },
    );
  });
}
