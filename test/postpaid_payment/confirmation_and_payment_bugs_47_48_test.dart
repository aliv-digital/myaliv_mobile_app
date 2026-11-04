import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/confirmation/postpaid/bloc/make_payment_confirmation_postpaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/confirmation/postpaid/bloc/make_payment_confirmation_postpaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/confirmation/postpaid/bloc/make_payment_confirmation_postpaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/confirmation/postpaid/repository/make_payment_confirmation_postpaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/widgets/mp_amount_field.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/widgets/mp_custom_amount_field.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/theme/make_payment_postpaid_theme.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

class _MockConfirmationRepo extends Mock
    implements MakePaymentConfirmationPostPaidRepository {}

class _MockDeviceLimitsCubit extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _MockBalanceCubit extends MockCubit<BalanceState>
    implements BalanceCubit {}

class _MockAccountInfoCubit extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bug 47: Confirmation phone number format', () {
    late _MockConfirmationRepo repo;
    late _MockDeviceLimitsCubit deviceLimitsCubit;
    late _MockBalanceCubit balanceCubit;
    late _MockAccountInfoCubit accountInfoCubit;

    setUp(() {
      repo = _MockConfirmationRepo();
      deviceLimitsCubit = _MockDeviceLimitsCubit();
      balanceCubit = _MockBalanceCubit();
      accountInfoCubit = _MockAccountInfoCubit();

      when(
        () => deviceLimitsCubit.state,
      ).thenReturn(DeviceLimitsState.initial());
      when(() => balanceCubit.state).thenReturn(BalanceState.initial());
      when(
        () => accountInfoCubit.state,
      ).thenReturn(const AccountInfoState(status: AccountInfoStatus.initial));

      instance.registerSingleton<DeviceLimitsCubit>(deviceLimitsCubit);
      instance.registerSingleton<BalanceCubit>(balanceCubit);
      instance.registerSingleton<AccountInfoCubit>(accountInfoCubit);
    });

    tearDown(() async {
      await instance.reset();
    });

    blocTest<
      MakePaymentConfirmationPostPaidBloc,
      MakePaymentConfirmationPostPaidState
    >(
      'formats 10-digit phone number as (242)-XXX-XXXX',
      build: () {
        when(() => repo.fetchConfirmation()).thenAnswer(
          (_) async => const MakePaymentConfirmationPostPaidData(
            title: 'confirmation and payment',
            customerName: 'Alicia Major',
            accountNumber: '2428997442',
            headerLabel: 'amount due',
            amountPill: r'$ 129.00',
            subtotal: r'$ 129.00',
            vat: r'$ 0.00',
            total: r'$ 129.00',
            bottomSubtitle: 'no VAT applied',
            bottomAmount: r'$ 129.00',
          ),
        );
        return MakePaymentConfirmationPostPaidBloc(repository: repo);
      },
      act: (bloc) => bloc.add(const MakePaymentConfirmationPostPaidStarted()),
      expect: () => [
        isA<MakePaymentConfirmationPostPaidState>().having(
          (s) => s.accountNumber,
          'accountNumber',
          '(242)-899-7442',
        ),
      ],
    );

    blocTest<
      MakePaymentConfirmationPostPaidBloc,
      MakePaymentConfirmationPostPaidState
    >(
      'formats 11-digit phone number with country code 1 as (242)-XXX-XXXX',
      build: () {
        when(() => repo.fetchConfirmation()).thenAnswer(
          (_) async => const MakePaymentConfirmationPostPaidData(
            title: 'confirmation and payment',
            customerName: 'Alicia Major',
            accountNumber: '12428997442',
            headerLabel: 'amount due',
            amountPill: r'$ 129.00',
            subtotal: r'$ 129.00',
            vat: r'$ 0.00',
            total: r'$ 129.00',
            bottomSubtitle: 'no VAT applied',
            bottomAmount: r'$ 129.00',
          ),
        );
        return MakePaymentConfirmationPostPaidBloc(repository: repo);
      },
      act: (bloc) => bloc.add(const MakePaymentConfirmationPostPaidStarted()),
      expect: () => [
        isA<MakePaymentConfirmationPostPaidState>().having(
          (s) => s.accountNumber,
          'accountNumber',
          '(242)-899-7442',
        ),
      ],
    );

    blocTest<
      MakePaymentConfirmationPostPaidBloc,
      MakePaymentConfirmationPostPaidState
    >(
      'uses secondary child line phone and name when ActiveDevice is selected',
      build: () {
        final secondaryDevice = DeviceLimitsModel.fromJson({
          'DeviceID': 200,
          'TN': '2428997821',
          'FName': 'Secondary',
          'LName': 'Child',
          'ParentAccountID': 100,
        });
        when(() => deviceLimitsCubit.state).thenReturn(
          DeviceLimitsState(
            status: DeviceLimitsStatus.loaded,
            allDeviceLimits: [secondaryDevice],
          ),
        );
        final uiConfigCubit = AppUiConfigCubit(
          initialConfig: const HomeUiConfig(
            userType: UserType.postpaid,
            hasActivePlan: true,
            isFuturePlan: false,
            activeDeviceId: 200,
            isViewingChildLine: true,
          ),
        );
        instance.registerSingleton<AppUiConfigCubit>(uiConfigCubit);

        when(() => repo.fetchConfirmation()).thenAnswer(
          (_) async => const MakePaymentConfirmationPostPaidData(
            title: 'confirmation and payment',
            customerName: 'Primary User',
            accountNumber: '2428997442',
            headerLabel: 'amount due',
            amountPill: r'$ 129.00',
            subtotal: r'$ 129.00',
            vat: r'$ 0.00',
            total: r'$ 129.00',
            bottomSubtitle: 'no VAT applied',
            bottomAmount: r'$ 129.00',
          ),
        );
        return MakePaymentConfirmationPostPaidBloc(repository: repo);
      },
      act: (bloc) => bloc.add(const MakePaymentConfirmationPostPaidStarted()),
      expect: () => [
        isA<MakePaymentConfirmationPostPaidState>()
            .having((s) => s.accountNumber, 'accountNumber', '(242)-899-7821')
            .having((s) => s.customerName, 'customerName', 'Secondary Child'),
      ],
    );
  });

  group('Bug 48: Currency symbol styling on payment screen', () {
    test('bold currency resolves to the actual bold asset', () async {
      final manifest =
          jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
      final family = manifest.cast<Map<String, dynamic>>().firstWhere(
        (entry) =>
            entry['family'] ==
            MakePaymentPostPaidTheme.currencySymbolText.fontFamily,
      );

      expect(
        family['fonts'],
        contains(
          equals({'asset': 'assets/fonts/CircularPro-Bold.otf', 'weight': 700}),
        ),
      );
    });

    testWidgets('MpAmountField displays bold dollar sign', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MpAmountField(value: '100.00')),
        ),
      );

      final dollarFinder = find.text(r'$');
      expect(dollarFinder, findsOneWidget);

      final dollarText = tester.widget<Text>(dollarFinder);
      expect(dollarText.style?.fontWeight, FontWeight.w700);
      expect(dollarText.style?.fontSize, 14);
    });

    testWidgets('MpCustomAmountField displays bold dollar sign', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MpCustomAmountField(value: '', onChanged: (_) {}),
          ),
        ),
      );

      final dollarFinder = find.text(r'$');
      expect(dollarFinder, findsOneWidget);

      final dollarText = tester.widget<Text>(dollarFinder);
      expect(dollarText.style?.fontWeight, FontWeight.w700);
      expect(dollarText.style?.fontSize, 14);
    });
  });
}
