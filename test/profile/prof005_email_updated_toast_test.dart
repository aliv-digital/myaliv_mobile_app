import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/editEmail/prepaid/view/edit_email_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/editEmail/prepaid/widgets/edit_email_prepaid_email_input.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/editEmail/prepaid/widgets/edit_email_prepaid_save_button.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class _Network extends Mock implements NetworkService {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

const _success = 'your email has been successfully updated';

void main() {
  late _Network network;
  late _Account account;
  late _Devices devices;

  setUpAll(() async {
    registerFallbackValue(HttpMethod.put);
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  setUp(() {
    network = _Network();
    account = _Account();
    devices = _Devices();
    when(() => account.state).thenReturn(const AccountInfoState());
    when(() => account.updateEmailLocally(any())).thenReturn(null);
    when(
      () => account.fetchAccountInfo(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async {});
    when(() => devices.state).thenReturn(DeviceLimitsState.initial());
    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
  });

  tearDown(() async {
    await account.close();
    await devices.close();
    await instance.reset();
  });

  void respond({required bool success, bool throws = false}) {
    when(
      () => network.request<dynamic>(any(), method: any(named: 'method')),
    ).thenAnswer((invocation) async {
      if (throws) throw Exception('offline');
      return Response<dynamic>(
        requestOptions: RequestOptions(
          path: invocation.positionalArguments.first as String,
        ),
        data: <String, dynamic>{'Success': success},
      );
    });
  }

  Future<void> openAndSave(WidgetTester tester, String email) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/edit'),
              child: const Text('my profile'),
            ),
          ),
        ),
        GoRoute(
          path: '/edit',
          builder: (_, _) => const EditEmailPrepaidScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('my profile'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(EditEmailPrepaidEmailInput),
        matching: find.byType(TextField),
      ),
      email,
    );
    await tester.pump();
    final save = find.byType(EditEmailPrepaidSaveButton);
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> settleToasts(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  testWidgets('PROF-005 successful update shows the exact toast', (
    tester,
  ) async {
    respond(success: true);
    await openAndSave(tester, 'new@example.com');
    expect(find.text(_success), findsOneWidget);
    expect(find.text('email address updated successfully'), findsNothing);
    verify(
      () => network.request<dynamic>(
        '/v1/MyAliv/Account/UpdateEmailAddress?Email=new%40example.com',
        method: HttpMethod.put,
      ),
    ).called(1);
    verify(() => account.updateEmailLocally('new@example.com')).called(1);
    await settleToasts(tester);
    // Existing behaviour: the screen closes after success.
    expect(find.text('my profile'), findsOneWidget);
  });

  testWidgets('PROF-005 failed update shows no success toast', (tester) async {
    respond(success: false);
    await openAndSave(tester, 'new@example.com');
    expect(find.text(_success), findsNothing);
    expect(find.text('Failed to save'), findsOneWidget);
    await settleToasts(tester);
  });

  testWidgets('PROF-005 API error shows no success toast', (tester) async {
    respond(success: true, throws: true);
    await openAndSave(tester, 'new@example.com');
    expect(find.text(_success), findsNothing);
    await settleToasts(tester);
  });

  testWidgets('PROF-005 invalid email never calls the API', (tester) async {
    respond(success: true);
    await openAndSave(tester, 'not-an-email');
    expect(find.text(_success), findsNothing);
    verifyNever(
      () => network.request<dynamic>(any(), method: any(named: 'method')),
    );
    await settleToasts(tester);
  });
}
