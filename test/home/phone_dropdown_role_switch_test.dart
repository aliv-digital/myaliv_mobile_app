import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/repository/services/role_api_client.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/phone_dropdown.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

class _AccountMock extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _DevicesMock extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _BalanceMock extends MockCubit<BalanceState> implements BalanceCubit {}

class _PlansMock extends MockCubit<PlansState> implements PlansCubit {}

class _BucketMock extends MockCubit<BucketUsageSummaryState>
    implements BucketUsageSummaryCubit {}

class _RoleMock extends Mock implements RoleApiClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(UserType.prepaid);
  });

  late _AccountMock accountCubit;
  late _DevicesMock devicesCubit;
  late _BalanceMock balanceCubit;
  late _PlansMock plansCubit;
  late _BucketMock bucketCubit;
  late _RoleMock roleApiClient;
  late AppUiConfigCubit uiConfigCubit;

  final primaryDevice = DeviceLimitsModel.fromJson({
    'DeviceID': 100,
    'TN': '2428997820',
    'FName': 'Primary',
    'LName': 'User',
    'ParentAccountID': 0,
  });

  final secondaryDevice = DeviceLimitsModel.fromJson({
    'DeviceID': 200,
    'TN': '2428997821',
    'FName': 'Secondary',
    'LName': 'Child',
    'ParentAccountID': 100,
  });

  setUp(() {
    accountCubit = _AccountMock();
    devicesCubit = _DevicesMock();
    balanceCubit = _BalanceMock();
    plansCubit = _PlansMock();
    bucketCubit = _BucketMock();
    roleApiClient = _RoleMock();

    uiConfigCubit = AppUiConfigCubit(
      initialConfig: const HomeUiConfig(
        userType: UserType.prepaid,
        hasActivePlan: true,
        isFuturePlan: false,
        lineRole: LineRole.parent,
      ),
    );

    const accountInfo = AccountInfoModel(
      phoneNumber: '2428997820',
      primaryPhoneNumber: '2428997820',
      tNs: ['2428997820', '2428997821'],
    );

    when(
      () => accountCubit.state,
    ).thenReturn(const AccountInfoState(accountInfo: accountInfo));
    when(() => devicesCubit.state).thenReturn(
      DeviceLimitsState(
        status: DeviceLimitsStatus.loaded,
        allDeviceLimits: [primaryDevice, secondaryDevice],
      ),
    );
    when(() => balanceCubit.state).thenReturn(
      const BalanceState(status: BalanceStatus.initial),
    );
    when(() => plansCubit.state).thenReturn(const PlansState());
    when(() => bucketCubit.state).thenReturn(
      const BucketUsageSummaryState(status: BucketUsageSummaryStatus.initial),
    );

    when(
      () => balanceCubit.loadBalances(
        deviceAccountId: any(named: 'deviceAccountId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => plansCubit.loadInitialPlans(
        userType: any(named: 'userType'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => bucketCubit.loadBucketUsageSummary(
        deviceAccountId: any(named: 'deviceAccountId'),
        activePlans: any(named: 'activePlans'),
        standAlonePlans: any(named: 'standAlonePlans'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async {});

    instance.registerSingleton<AccountInfoCubit>(accountCubit);
    instance.registerSingleton<DeviceLimitsCubit>(devicesCubit);
    instance.registerSingleton<BalanceCubit>(balanceCubit);
    instance.registerSingleton<PlansCubit>(plansCubit);
    instance.registerSingleton<BucketUsageSummaryCubit>(bucketCubit);
    instance.registerSingleton<RoleApiClient>(roleApiClient);
  });

  tearDown(() async {
    await uiConfigCubit.close();
    await instance.reset();
  });

  testWidgets(
    'switching to secondary readonly user sets lineRole to readOnly and isRestricted to true',
    (tester) async {
      when(
        () => roleApiClient.fetchRoleId(200),
      ).thenAnswer((_) async => 5); // 5 = ReadOnly

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AppUiConfigCubit>.value(
            value: uiConfigCubit,
            child: const Scaffold(body: PhoneDropdown()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(uiConfigCubit.state.lineRole, LineRole.parent);
      expect(uiConfigCubit.state.isRestricted, isFalse);

      // Open dropdown
      await tester.tap(find.byType(PhoneDropdown));
      await tester.pumpAndSettle();

      // Select secondary number
      final secondaryItem = find.text('(242)-899-7821').last;
      await tester.tap(secondaryItem);
      await tester.pumpAndSettle();

      // Confirm dialog "yes"
      expect(find.text('switch phone number'), findsOneWidget);
      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();

      // Verified: fetched role for secondary device 200
      verify(() => roleApiClient.fetchRoleId(200)).called(1);
      expect(uiConfigCubit.state.activeDeviceId, 200);
      expect(uiConfigCubit.state.lineRole, LineRole.readOnly);
      expect(uiConfigCubit.state.isRestricted, isTrue);

      // Now switch back to primary number
      await tester.tap(find.byType(PhoneDropdown));
      await tester.pumpAndSettle();

      final primaryItem = find.text('(242)-899-7820').last;
      await tester.tap(primaryItem);
      await tester.pumpAndSettle();

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();

      // Verified: reset to primary/parent device restores LineRole.parent
      expect(uiConfigCubit.state.activeDeviceId, isNull);
      expect(uiConfigCubit.state.lineRole, LineRole.parent);
      expect(uiConfigCubit.state.isRestricted, isFalse);
    },
  );

  testWidgets(
    'switching to secondary full access user sets lineRole to fullAccess and isRestricted to false',
    (tester) async {
      when(
        () => roleApiClient.fetchRoleId(200),
      ).thenAnswer((_) async => 4); // 4 = FullAccess

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AppUiConfigCubit>.value(
            value: uiConfigCubit,
            child: const Scaffold(body: PhoneDropdown()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open dropdown and select secondary
      await tester.tap(find.byType(PhoneDropdown));
      await tester.pumpAndSettle();

      final secondaryItem = find.text('(242)-899-7821').last;
      await tester.tap(secondaryItem);
      await tester.pumpAndSettle();

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();

      verify(() => roleApiClient.fetchRoleId(200)).called(1);
      expect(uiConfigCubit.state.activeDeviceId, 200);
      expect(uiConfigCubit.state.lineRole, LineRole.fullAccess);
      expect(uiConfigCubit.state.isRestricted, isFalse);
    },
  );
}
