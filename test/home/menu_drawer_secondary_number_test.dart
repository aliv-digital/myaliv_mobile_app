import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/drawer.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

class _AccountMock extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _DevicesMock extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _AccountMock accountCubit;
  late _DevicesMock devicesCubit;
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
    'TN': '2428997821_97dc5ea5-fdf7-49d3-83ab-50e735c45791',
    'FName': 'Secondary',
    'LName': 'Child',
    'ParentAccountID': 100,
  });

  setUp(() {
    accountCubit = _AccountMock();
    devicesCubit = _DevicesMock();
    uiConfigCubit = AppUiConfigCubit(
      initialConfig: const HomeUiConfig(
        userType: UserType.prepaid,
        hasActivePlan: true,
        isFuturePlan: false,
      ),
    );

    when(() => accountCubit.state).thenReturn(const AccountInfoState());
    when(() => devicesCubit.state).thenReturn(
      DeviceLimitsState(
        status: DeviceLimitsStatus.loaded,
        allDeviceLimits: [primaryDevice, secondaryDevice],
      ),
    );

    instance.registerSingleton<AccountInfoCubit>(accountCubit);
    instance.registerSingleton<DeviceLimitsCubit>(devicesCubit);
    instance.registerSingleton<AppUiConfigCubit>(uiConfigCubit);
  });

  tearDown(() async {
    await uiConfigCubit.close();
    await instance.reset();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<AppUiConfigCubit>.value(
        value: uiConfigCubit,
        child: const Scaffold(drawer: AppMenuDrawer(), body: Text('body')),
      ),
    );
  }

  testWidgets(
    'Menu drawer shows primary number and name by default, and switches to secondary when selected',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // By default: primary line is shown
      expect(find.text('(242)-899-7820'), findsOneWidget);
      expect(find.text('Primary User'), findsOneWidget);

      // Select secondary device (e.g. from Home dropdown)
      uiConfigCubit.switchToDevice(200);
      await tester.pumpAndSettle();

      // Menu section drawer now reflects secondary phone number and name
      expect(find.text('(242)-899-7821'), findsOneWidget);
      expect(find.text('Secondary Child'), findsOneWidget);
      expect(find.text('(242)-899-7820'), findsNothing);

      // Reset to own device
      uiConfigCubit.resetToOwnDevice();
      await tester.pumpAndSettle();

      // Reverts back to primary number and name
      expect(find.text('(242)-899-7820'), findsOneWidget);
      expect(find.text('Primary User'), findsOneWidget);
      expect(find.text('(242)-899-7821'), findsNothing);
    },
  );
}
