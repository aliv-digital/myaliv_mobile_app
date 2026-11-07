import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/purchaseAddOns/view/purchase_add_ons_screen.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_on_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
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
    registerFallbackValue(UserType.prepaid);
    registerFallbackValue(HomePlanTab.addOns);
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

    when(() => plansCubit.state).thenReturn(
      PlansState(
        status: PlansStatus.success,
        addOnsApiPrimaryPlans: [
          BasePlanModel.fromApiMap({
            'PlanID': 'primary',
            'PlanName': 'liberty70',
            'PlanType': 'P',
          }),
        ],
        selectedTab: HomePlanTab.addOns,
        addOns: const [
          HomePlanAddOnModel(
            id: 'addon_1',
            title: 'liberty data1',
            label: 'data balance',
            value: '1gb',
            price: 5.0,
            vatAmount: 0.5,
          ),
        ],
        selectedAddOnIds: const {'addon_1'},
      ),
    );
    when(() => plansCubit.isClosed).thenReturn(false);
    when(
      () => plansCubit.started(
        userType: any(named: 'userType'),
        initialTab: any(named: 'initialTab'),
      ),
    ).thenAnswer((_) async {});
    when(() => plansCubit.clearSelectedAddOns()).thenReturn(null);

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

  group(
    'PurchaseAddOnsScreen & HomePlanAddOnsActions secondary line support',
    () {
      testWidgets(
        'PurchaseAddOnsScreen clears selected add-ons on init and dispose',
        (tester) async {
          await tester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider<PlansCubit>.value(value: plansCubit),
                BlocProvider<AppUiConfigCubit>.value(value: uiConfigCubit),
              ],
              child: const MaterialApp(home: PurchaseAddOnsScreen()),
            ),
          );

          // Cleared on init
          verify(() => plansCubit.clearSelectedAddOns()).called(1);

          // Unmount / dispose
          await tester.pumpWidget(const SizedBox.shrink());

          // Cleared on dispose
          verify(() => plansCubit.clearSelectedAddOns()).called(1);
        },
      );
    },
  );
}
