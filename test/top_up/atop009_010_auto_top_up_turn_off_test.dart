import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/auto_topup/auto_topup_tab.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/auto_topup/auto_topup_widgets.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/resources/widgets/common_switch_button_large.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class _Cards extends MockCubit<SavedCardsState> implements SavedCardsCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

const _confirmCopy = 'are you sure you want to turn off auto top-up?';
const _toast = 'auto top-up has been turned off';

void main() {
  late _Cards cards;
  late _Devices devices;
  late _Account account;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  setUp(() {
    cards = _Cards();
    devices = _Devices();
    account = _Account();
    when(() => account.state).thenReturn(const AccountInfoState());
    when(() => cards.fetchSavedCards()).thenAnswer((_) async {});
    when(() => cards.refreshSavedCards()).thenAnswer((_) async {});
    whenListen(
      cards,
      const Stream<SavedCardsState>.empty(),
      initialState: const SavedCardsState(status: SavedCardsStatus.success),
    );
    whenListen(
      devices,
      const Stream<DeviceLimitsState>.empty(),
      initialState: DeviceLimitsState.initial(),
    );
    when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<AccountInfoCubit>(account);
  });

  tearDown(() async {
    await cards.close();
    await devices.close();
    await account.close();
    await instance.reset();
  });

  Future<void> pumpTab(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [GoRoute(path: '/', builder: (_, _) => const AutoTopupTab())],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      BlocProvider<SavedCardsCubit>.value(
        value: cards,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder toggle() => find.byType(CommonSwitchButtonLarge);

  Finder toggleLabel(String label) =>
      find.descendant(of: toggle(), matching: find.text(label));

  bool applyEnabled(WidgetTester tester) =>
      tester
          .widget<ElevatedButton>(
            find.ancestor(
              of: find.text('apply'),
              matching: find.byType(ElevatedButton),
            ),
          )
          .onPressed !=
      null;

  double configOpacity(WidgetTester tester) => tester
      .widget<Opacity>(
        find.ancestor(
          of: find.byType(AutoTopupApplyButton),
          matching: find.byType(Opacity),
        ),
      )
      .opacity;

  Future<void> tapToggle(WidgetTester tester) async {
    await tester.tap(toggle());
    await tester.pumpAndSettle();
  }

  void verifyNoBackend() {
    verifyNever(
      () => devices.updateBalanceThresholdSettings(
        balanceThreshold: any(named: 'balanceThreshold'),
        autoTopUpAmount: any(named: 'autoTopUpAmount'),
        cardToken: any(named: 'cardToken'),
      ),
    );
    verifyNever(() => devices.disableAutoRenew(any()));
  }

  Future<void> expireToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  testWidgets('toggle starts ON with the config section enabled', (
    tester,
  ) async {
    await pumpTab(tester);
    expect(toggleLabel('on'), findsOneWidget);
    expect(configOpacity(tester), 1);
    expect(applyEnabled(tester), isTrue);
    expect(find.text(_confirmCopy), findsNothing);
    expect(find.text(_toast), findsNothing);
  });

  testWidgets('ON → OFF attempt shows the exact confirmation first', (
    tester,
  ) async {
    await pumpTab(tester);
    await tapToggle(tester);

    expect(find.byType(AutoTopupTurnOffBottomSheet), findsOneWidget);
    expect(find.text(_confirmCopy), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'ok'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'cancel'), findsOneWidget);
    // Not switched yet, and no success feedback before confirming.
    expect(toggleLabel('on'), findsOneWidget);
    expect(find.text(_toast), findsNothing);
    verifyNoBackend();
  });

  testWidgets('cancel keeps the toggle ON with no toast or backend call', (
    tester,
  ) async {
    await pumpTab(tester);
    await tapToggle(tester);
    await tester.tap(find.text('cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AutoTopupTurnOffBottomSheet), findsNothing);
    expect(toggleLabel('on'), findsOneWidget);
    expect(configOpacity(tester), 1);
    expect(applyEnabled(tester), isTrue);
    expect(find.text(_toast), findsNothing);
    verifyNoBackend();
  });

  testWidgets('back arrow dismiss behaves like cancel', (tester) async {
    await pumpTab(tester);
    await tapToggle(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(AutoTopupTurnOffBottomSheet),
        matching: find.byIcon(Icons.arrow_back),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AutoTopupTurnOffBottomSheet), findsNothing);
    expect(toggleLabel('on'), findsOneWidget);
    expect(find.text(_toast), findsNothing);
  });

  testWidgets('ok switches OFF locally, greys the form and shows the toast', (
    tester,
  ) async {
    await pumpTab(tester);
    await tapToggle(tester);
    await tester.tap(find.text('ok'));
    await tester.pump();

    expect(find.text(_toast), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(AutoTopupTurnOffBottomSheet), findsNothing);
    expect(toggleLabel('off'), findsOneWidget);
    // Existing OFF consequences of `_anyTimeEnabled == false`.
    expect(configOpacity(tester), 0.4);
    expect(applyEnabled(tester), isFalse);
    verifyNoBackend();
    await expireToast(tester);
  });

  testWidgets('OFF → ON is immediate with no confirmation or toast', (
    tester,
  ) async {
    await pumpTab(tester);
    await tapToggle(tester);
    await tester.tap(find.text('ok'));
    await tester.pumpAndSettle();
    await expireToast(tester);
    expect(find.text(_toast), findsNothing);

    await tapToggle(tester);

    expect(find.byType(AutoTopupTurnOffBottomSheet), findsNothing);
    expect(toggleLabel('on'), findsOneWidget);
    expect(configOpacity(tester), 1);
    expect(applyEnabled(tester), isTrue);
    expect(find.text(_toast), findsNothing);
    verifyNoBackend();
  });

  testWidgets('reopening the tab starts ON again (no persistence)', (
    tester,
  ) async {
    await pumpTab(tester);
    await tapToggle(tester);
    await tester.tap(find.text('ok'));
    await tester.pumpAndSettle();
    await expireToast(tester);
    expect(toggleLabel('off'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await pumpTab(tester);

    expect(toggleLabel('on'), findsOneWidget);
    expect(find.text(_toast), findsNothing);
    verifyNoBackend();
  });
}
