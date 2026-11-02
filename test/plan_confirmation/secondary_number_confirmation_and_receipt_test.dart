import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/confirmation/utils/confirmation_formatters.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/confirmation/widgets/confirmation_plan_card_my_number_content.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/confirmation/widgets/confirmation_plan_card_postpaid_content.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanPurchaseReceipt/bloc/home_plan_purchase_receipt_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanPurchaseReceipt/view/home_plan_purchase_receipt_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/view/services/payment_receipt_builder.dart';
import 'package:myaliv_mobile_app/app/common/services/phone_number_formatter_service.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

class _MockAccountInfoCubit extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _MockDeviceLimitsCubit extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _MockPlansCubit extends MockCubit<PlansState> implements PlansCubit {}

class _MockNetworkService extends Mock implements NetworkService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _MockAccountInfoCubit accountInfoCubit;
  late _MockDeviceLimitsCubit deviceLimitsCubit;
  late _MockPlansCubit plansCubit;
  late _MockNetworkService networkService;
  late AppUiConfigCubit uiConfigCubit;

  final primaryDevice = DeviceLimitsModel.fromJson({
    'DeviceID': 100,
    'TN': '2428997820',
    'FName': 'John',
    'LName': 'Doe',
    'ParentAccountID': 0,
  });

  final secondaryDevice = DeviceLimitsModel.fromJson({
    'DeviceID': 200,
    'TN': '2428997783_97dc5ea5-fdf7-49d3-83ab-50e735c45791',
    'FName': 'Denise',
    'LName': 'Grimes',
    'ParentAccountID': 100,
  });

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    accountInfoCubit = _MockAccountInfoCubit();
    deviceLimitsCubit = _MockDeviceLimitsCubit();
    plansCubit = _MockPlansCubit();
    networkService = _MockNetworkService();
    uiConfigCubit = AppUiConfigCubit(
      initialConfig: const HomeUiConfig(
        userType: UserType.prepaid,
        hasActivePlan: true,
        isFuturePlan: false,
      ),
    );

    when(() => plansCubit.state).thenReturn(const PlansState());
    when(() => plansCubit.isClosed).thenReturn(false);
    when(() => plansCubit.refreshBundlesOnly()).thenAnswer((_) async {});

    when(() => accountInfoCubit.state).thenReturn(
      const AccountInfoState(
        status: AccountInfoStatus.success,
        accountInfo: AccountInfoModel(
          fName: 'John',
          lName: 'Doe',
          primaryPhoneNumber: '2428997820',
        ),
      ),
    );

    when(() => deviceLimitsCubit.state).thenReturn(
      DeviceLimitsState(
        status: DeviceLimitsStatus.loaded,
        allDeviceLimits: [primaryDevice, secondaryDevice],
      ),
    );

    instance.registerSingleton<NetworkService>(networkService);
    instance.registerSingleton<AccountInfoCubit>(accountInfoCubit);
    instance.registerSingleton<DeviceLimitsCubit>(deviceLimitsCubit);
    instance.registerSingleton<AppUiConfigCubit>(uiConfigCubit);
  });

  tearDown(() async {
    await uiConfigCubit.close();
    await instance.reset();
  });

  group('Secondary Number Formatting on Confirmation & Receipt', () {
    test(
      'formatConfirmationPhone strips suffixes and formats to (242)-899-7783',
      () {
        expect(
          formatConfirmationPhone(
            '2428997783_97dc5ea5-fdf7-49d3-83ab-50e735c45791',
          ),
          '(242)-899-7783',
        );
        expect(formatConfirmationPhone('2428997783*dc*'), '(242)-899-7783');
        expect(formatConfirmationPhone('2428997783'), '(242)-899-7783');
      },
    );

    test(
      'PhoneNumberFormatterService strips suffixes and formats to (242)-899-7783',
      () {
        expect(
          PhoneNumberFormatterService.format(
            '2428997783_97dc5ea5-fdf7-49d3-83ab-50e735c45791',
          ),
          '(242)-899-7783',
        );
        expect(
          PhoneNumberFormatterService.format('2428997783*dc*'),
          '(242)-899-7783',
        );
      },
    );

    testWidgets(
      'ConfirmationPlanCardMyNumberContent formats secondary number as (242)-899-7783 and shows Denise Grimes',
      (tester) async {
        // Switch to secondary device
        uiConfigCubit.switchToDevice(200);

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppUiConfigCubit>.value(
              value: uiConfigCubit,
              child: const Scaffold(
                body: ConfirmationPlanCardMyNumberContent(topUpAmount: 25.0),
              ),
            ),
          ),
        );

        expect(find.text('Denise Grimes'), findsOneWidget);
        expect(find.text('(242)-899-7783'), findsOneWidget);
        expect(find.text('2428997783'), findsNothing);
      },
    );

    testWidgets(
      'ConfirmationPlanCardPostpaidContent formats secondary number as (242)-899-7783 and shows Denise Grimes',
      (tester) async {
        // Switch to secondary device
        uiConfigCubit.switchToDevice(200);

        final plan = HomePlansPostPaidPlanModel.fromJson({
          'PlanID': '1',
          'PlanName': 'Postpaid Liberty',
          'PlanType': 'P',
          'PlanAmount': 50.0,
          'VatAmount': 5.0,
          'PlanAmountWithVat': 55.0,
          'Duration': '30 days',
        });

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppUiConfigCubit>.value(
              value: uiConfigCubit,
              child: Scaffold(
                body: ConfirmationPlanCardPostpaidContent(plan: plan),
              ),
            ),
          ),
        );

        expect(find.text('Denise Grimes'), findsOneWidget);
        expect(find.text('(242)-899-7783'), findsOneWidget);
      },
    );

    testWidgets(
      'PaymentReceiptBuilder and HomePlanPurchaseReceiptScreen display secondary number formatted',
      (tester) async {
        // Switch to secondary device
        uiConfigCubit.switchToDevice(200);

        final paymentState = HomePlansPaymentMethodState.initial().copyWith(
          status: HomePlansPaymentMethodStatus.success,
          amount: 55.0,
          phoneNumber: '2428997783_97dc5ea5-fdf7-49d3-83ab-50e735c45791',
          subscriberType: HomePlansSubscriberType.postpaid,
          selectedItems: const [
            HomePlansPaymentSelectedItem(
              id: '1',
              label: 'primary plan',
              title: 'Postpaid Liberty',
              subtitle: 'begins immediately',
              price: 50.0,
              planType: HomePlansPaymentPlanType.primary,
            ),
          ],
        );

        late Map<String, dynamic> receiptPayload;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (ctx) {
                return BlocProvider<AccountInfoCubit>.value(
                  value: accountInfoCubit,
                  child: Builder(
                    builder: (innerCtx) {
                      receiptPayload = PaymentReceiptBuilder.build(
                        innerCtx,
                        paymentState,
                      );
                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
            ),
          ),
        );

        expect(receiptPayload['phoneNumber'], '(242)-899-7783');

        // Now pump the receipt screen with this payload
        tester.view.physicalSize = const Size(390, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final details =
            receiptPayload['details']
                as List<HomePlanPurchaseReceiptDetailItem>;

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<PlansCubit>.value(value: plansCubit),
              BlocProvider<AppUiConfigCubit>.value(value: uiConfigCubit),
            ],
            child: MaterialApp(
              home: HomePlanPurchaseReceiptScreen(
                phoneNumber: receiptPayload['phoneNumber'] as String,
                amount: receiptPayload['amount'] as double,
                dateText: receiptPayload['dateText'] as String,
                timeText: receiptPayload['timeText'] as String,
                paymentMethod: receiptPayload['paymentMethod'] as String,
                details: details,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('(242)-899-7783'), findsOneWidget);
        await tester.pump(const Duration(seconds: 4));
      },
    );
  });
}
