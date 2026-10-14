import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/editEmail/prepaid/bloc/edit_email_prepaid_bloc.dart';
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
    expect(tester.widget<EditEmailPrepaidSaveButton>(save).enabled, isTrue);
    await tester.tap(save);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> settleToasts(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  testWidgets('Save is unavailable until email data has loaded', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EditEmailPrepaidScreen()));
    final save = find.byType(EditEmailPrepaidSaveButton);
    expect(save, findsNothing);
    await tester.pumpAndSettle();
    expect(tester.widget<EditEmailPrepaidSaveButton>(save).enabled, isTrue);
    verifyZeroInteractions(network);
  });

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
    verify(() => account.fetchAccountInfo(forceRefresh: true)).called(1);
    await settleToasts(tester);
    // Existing behaviour: the screen closes after success.
    expect(find.text('my profile'), findsOneWidget);
  });

  testWidgets('PROF-005 failed update shows no success toast', (tester) async {
    respond(success: false);
    await openAndSave(tester, 'new@example.com');
    expect(find.text(_success), findsNothing);
    expect(find.text('Failed to save'), findsOneWidget);
    expect(
      find.text('This email is already in use. Please enter a different one.'),
      findsNothing,
    );
    await settleToasts(tester);
  });

  testWidgets('PROF-005 API error shows no success toast', (tester) async {
    respond(success: true, throws: true);
    await openAndSave(tester, 'new@example.com');
    expect(find.text(_success), findsNothing);
    expect(find.text('Failed to save'), findsOneWidget);
    await settleToasts(tester);
  });

  testWidgets('PROF-005 invalid email never calls the API', (tester) async {
    respond(success: true);
    await openAndSave(tester, 'not-an-email');
    expect(find.text(_success), findsNothing);
    expect(find.text('Invalid email address format.'), findsOneWidget);
    expect(find.text('Email address is required.'), findsNothing);
    verifyNever(
      () => network.request<dynamic>(any(), method: any(named: 'method')),
    );
    await settleToasts(tester);
  });

  for (final email in ['', '   ']) {
    testWidgets('empty or whitespace email "$email" shows required feedback', (
      tester,
    ) async {
      await openAndSave(tester, email);
      expect(find.text('Email address is required.'), findsOneWidget);
      expect(find.text('Invalid email address format.'), findsNothing);
      expect(find.text(_success), findsNothing);
      verifyZeroInteractions(network);
      verifyNever(() => account.updateEmailLocally(any()));
      expect(find.byType(EditEmailPrepaidScreen), findsOneWidget);
      await settleToasts(tester);
    });
  }

  testWidgets('valid email keeps existing trimming and update behaviour', (
    tester,
  ) async {
    respond(success: true);
    await openAndSave(tester, '  new@example.com  ');
    expect(find.text(_success), findsOneWidget);
    verify(
      () => network.request<dynamic>(
        '/v1/MyAliv/Account/UpdateEmailAddress?Email=new%40example.com',
        method: HttpMethod.put,
      ),
    ).called(1);
    verify(() => account.updateEmailLocally('new@example.com')).called(1);
    await settleToasts(tester);
    expect(find.text('my profile'), findsOneWidget);
  });

  testWidgets('editing and submitting replaces local feedback without an API', (
    tester,
  ) async {
    await openAndSave(tester, '');
    expect(find.text('Email address is required.'), findsOneWidget);
    final input = find.descendant(
      of: find.byType(EditEmailPrepaidEmailInput),
      matching: find.byType(TextField),
    );
    await tester.enterText(input, 'not-an-email');
    await tester.pump();
    final bloc = tester.element(input).read<EditEmailPrepaidBloc>();
    expect(bloc.state.email, 'not-an-email');
    expect(bloc.state.errorMessage, isNull);
    await tester.tap(find.byType(EditEmailPrepaidSaveButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Invalid email address format.'), findsOneWidget);
    expect(find.text('Email address is required.'), findsNothing);
    await tester.enterText(input, 'new@example.com');
    await tester.pump();
    expect(bloc.state.isEmailValid, isTrue);
    expect(bloc.state.errorMessage, isNull);
    verifyZeroInteractions(network);
    await settleToasts(tester);
    expect(find.text('Invalid email address format.'), findsNothing);
  });

  testWidgets('pending update protects Save and waits for backend success', (
    tester,
  ) async {
    final response = Completer<Response<dynamic>>();
    when(
      () => network.request<dynamic>(any(), method: any(named: 'method')),
    ).thenAnswer((_) => response.future);
    await openAndSave(tester, 'new@example.com');
    final save = find.byType(EditEmailPrepaidSaveButton);
    expect(tester.widget<EditEmailPrepaidSaveButton>(save).enabled, isFalse);
    expect(tester.widget<EditEmailPrepaidSaveButton>(save).isLoading, isTrue);
    expect(
      tester
          .widget<EditEmailPrepaidEmailInput>(
            find.byType(EditEmailPrepaidEmailInput),
          )
          .enabled,
      isFalse,
    );
    expect(find.text(_success), findsNothing);
    verifyNever(() => account.updateEmailLocally(any()));
    response.complete(
      Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        data: <String, dynamic>{'Success': true},
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(_success), findsOneWidget);
    verify(
      () => network.request<dynamic>(any(), method: any(named: 'method')),
    ).called(1);
    verify(() => account.updateEmailLocally('new@example.com')).called(1);
    verify(() => account.fetchAccountInfo(forceRefresh: true)).called(1);
    await settleToasts(tester);
    expect(find.text('my profile'), findsOneWidget);
  });
}
