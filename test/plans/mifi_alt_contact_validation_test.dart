import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/cubit/alt_number_validation_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/cubit/alt_number_validation_state.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/model/mifi_alt_contact_route_args.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/view/mifi_alt_contact_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/widgets/mifi_alt_phone_field.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _AltCubit extends MockCubit<AltNumberValidationState>
    implements AltNumberValidationCubit {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

const _empty = 'enter a mobile number we can reach you on';
const _invalid = 'enter a valid 10-digit mobile number';
const _sameAsMifi = "enter a number that's different from your mifi number";
const _allMessages = [_empty, _invalid, _sameAsMifi];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _AltCubit altCubit;
  late _Account account;
  late _Devices devices;
  late StreamController<AltNumberValidationState> altStates;
  HomePlanConfirmationRouteArgs? confirmation;

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
    altCubit = _AltCubit();
    account = _Account();
    devices = _Devices();
    when(() => devices.state).thenReturn(DeviceLimitsState.initial());
    altStates = StreamController<AltNumberValidationState>.broadcast();
    confirmation = null;
    whenListen(
      altCubit,
      altStates.stream,
      initialState: const AltNumberValidationState(),
    );
    when(
      () => altCubit.submit(
        altNumber: any(named: 'altNumber'),
        isOptedIn: any(named: 'isOptedIn'),
      ),
    ).thenAnswer((_) async {});
    instance.registerFactory<AltNumberValidationCubit>(() => altCubit);
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
  });

  tearDown(() async {
    await altStates.close();
    await altCubit.close();
    await account.close();
    await devices.close();
    await instance.reset();
  });

  void givenMifiLine({String primary = '242-801-1616', String phone = ''}) {
    when(() => account.state).thenReturn(
      AccountInfoState(
        accountInfo: AccountInfoModel(
          paymentOption: 'PrePay',
          primaryPhoneNumber: primary,
          phoneNumber: phone,
        ),
      ),
    );
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const MifiAltContactScreen(
            args: MifiAltContactRouteArgs(
              fallbackPlan: HomePlanModel(
                id: '77',
                title: 'mifi 30',
                subtitle: '30 days',
                price: 30,
                description: '',
                benefits: [],
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.homePlanConfirmationScreen,
          builder: (_, state) {
            confirmation = state.extra! as HomePlanConfirmationRouteArgs;
            return const Scaffold(body: Text('existing plan confirmation'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  Finder phoneInput() => find.descendant(
    of: find.byType(MifiAltPhoneField),
    matching: find.byType(TextField),
  );

  Future<void> enterPhone(WidgetTester tester, String value) async {
    await tester.enterText(phoneInput(), value);
    await tester.pumpAndSettle();
  }

  Future<void> chooseOffersAndContinue(WidgetTester tester) async {
    await tester.tap(find.text('yes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('continue'));
    await tester.pumpAndSettle();
  }

  void expectOnlyMessage(String? expected) {
    for (final message in _allMessages) {
      expect(
        find.text(message),
        message == expected ? findsOneWidget : findsNothing,
        reason: message,
      );
    }
    // The shared sign-in copy is no longer used on this screen.
    expect(find.text('invalid phone number'), findsNothing);
  }

  void expectNotSubmitted() {
    verifyNever(
      () => altCubit.submit(
        altNumber: any(named: 'altNumber'),
        isOptedIn: any(named: 'isOptedIn'),
      ),
    );
    expect(confirmation, isNull);
  }

  testWidgets('initial screen shows no validation message', (tester) async {
    givenMifiLine();
    await pumpScreen(tester);
    expectOnlyMessage(null);
  });

  for (final value in ['', '   ']) {
    testWidgets('MIFI-002 empty "$value" + continue is blocked inline', (
      tester,
    ) async {
      givenMifiLine();
      await pumpScreen(tester);
      await enterPhone(tester, value);
      await chooseOffersAndContinue(tester);
      expectOnlyMessage(_empty);
      expectNotSubmitted();
    });
  }

  for (final value in ['24233', '3051234567', '242801161']) {
    testWidgets('MIFI-003 malformed $value + continue is blocked inline', (
      tester,
    ) async {
      // `242801161` is a prefix of the MiFi line: it must never be compared.
      givenMifiLine();
      await pumpScreen(tester);
      await enterPhone(tester, value);
      expectOnlyMessage(_invalid);
      await chooseOffersAndContinue(tester);
      expectOnlyMessage(_invalid);
      expectNotSubmitted();
    });
  }

  for (final value in ['2428011616', '(242)-801-1616', '8011616']) {
    testWidgets('MIFI-005 same as MiFi line $value is blocked inline', (
      tester,
    ) async {
      givenMifiLine();
      await pumpScreen(tester);
      await enterPhone(tester, value);
      expectOnlyMessage(null);
      await chooseOffersAndContinue(tester);
      expectOnlyMessage(_sameAsMifi);
      expectNotSubmitted();
    });
  }

  testWidgets('MIFI-005 falls back to the account phone number', (
    tester,
  ) async {
    givenMifiLine(primary: '', phone: '2428011616');
    await pumpScreen(tester);
    await enterPhone(tester, '2428011616');
    await chooseOffersAndContinue(tester);
    expectOnlyMessage(_sameAsMifi);
    expectNotSubmitted();
  });

  testWidgets('valid different number keeps the existing submit and route', (
    tester,
  ) async {
    givenMifiLine();
    await pumpScreen(tester);
    await enterPhone(tester, '2423334444');
    await chooseOffersAndContinue(tester);
    expectOnlyMessage(null);
    verify(
      () => altCubit.submit(altNumber: '2423334444', isOptedIn: true),
    ).called(1);
    expect(confirmation, isNull);

    altStates.add(
      const AltNumberValidationState(
        status: AltNumberValidationStatus.valid,
        signalId: 1,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('existing plan confirmation'), findsOneWidget);
    expect(confirmation!.altContactNumber, '2423334444');
    expect(confirmation!.marketingOptIn, isTrue);
    expect(confirmation!.phoneNumber, '242-801-1616');
  });

  testWidgets('editing clears a stale error and allows resubmission', (
    tester,
  ) async {
    givenMifiLine();
    await pumpScreen(tester);
    await enterPhone(tester, '2428011616');
    await chooseOffersAndContinue(tester);
    expectOnlyMessage(_sameAsMifi);

    // Clear first: replacing formatted text in one step reads as a backspace
    // to the existing Bahamas formatter.
    await enterPhone(tester, '');
    await enterPhone(tester, '2423334444');
    expectOnlyMessage(null);
    await tester.tap(find.text('continue'));
    await tester.pumpAndSettle();
    expectOnlyMessage(null);
    verify(
      () => altCubit.submit(altNumber: '2423334444', isOptedIn: true),
    ).called(1);
  });

  testWidgets('empty error clears once the user starts typing', (tester) async {
    givenMifiLine();
    await pumpScreen(tester);
    await chooseOffersAndContinue(tester);
    expectOnlyMessage(_empty);
    await enterPhone(tester, '242');
    expectOnlyMessage(_invalid);
  });

  testWidgets('offers choice still gates continue without validating', (
    tester,
  ) async {
    givenMifiLine();
    await pumpScreen(tester);
    await tester.tap(find.text('continue'));
    await tester.pumpAndSettle();
    expectOnlyMessage(null);
    expectNotSubmitted();
  });
}
