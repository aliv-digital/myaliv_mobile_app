import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/model/guest_pay_bill_confirm_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/bloc/guest_pay_bill_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/bloc/guest_pay_bill_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/bloc/guest_pay_bill_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/model/guest_pay_bill_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/repository/guest_pay_bill_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/view/guest_pay_bill_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/widgets/guest_pay_bill_primary_submit_button.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Repository extends Mock implements GuestPayBillRepository {}

class _Network extends Mock implements NetworkService {}

const _postpaid = BillService(code: 'ALIV_POSTPAID', label: 'ALIV Postpaid');
const _fibr = BillService(code: 'ALIV_FIBR', label: 'ALIVFibr');
const _postpaidInfo = PayBillAccountInfo(
  status: 'AC',
  balance: 80,
  paymentOption: 'PostPay',
);
const _fibrInfo = PayBillAccountInfo(
  status: 'AC',
  balance: 150,
  fibrAccountId: 1001,
);

GuestPayBillState _verifiedPostpaid() => GuestPayBillState.initial().copyWith(
  selectedService: _postpaid,
  mobileNumber: '2425551234',
  confirmMobileNumber: '2425551234',
  accountInfo: _postpaidInfo,
  verifyStatus: GuestPayBillVerifyStatus.success,
  amountText: '15',
);

Future<GuestPayBillState> _send(
  GuestPayBillBloc bloc,
  GuestPayBillEvent event,
  bool Function(GuestPayBillState) matches,
) {
  final next = bloc.stream.firstWhere(matches);
  bloc.add(event);
  return next;
}

void main() {
  group('verification state', () {
    late _Repository repository;

    setUp(() => repository = _Repository());

    test(
      'copyWith explicitly clears account data and otherwise preserves it',
      () {
        final state = _verifiedPostpaid();
        expect(
          state.copyWith(amountText: '20').accountInfo,
          same(_postpaidInfo),
        );
        final cleared = state.copyWith(clearAccountInfo: true);
        expect(cleared.accountInfo, isNull);
        expect(cleared.canSubmit, isFalse);
        expect(cleared, isNot(state));
      },
    );

    test('payment needs a successful lookup and valid current inputs', () {
      final state = _verifiedPostpaid();
      expect(state.canSubmit, isTrue);
      for (final status in [
        GuestPayBillVerifyStatus.idle,
        GuestPayBillVerifyStatus.loading,
        GuestPayBillVerifyStatus.failure,
      ]) {
        expect(state.copyWith(verifyStatus: status).canSubmit, isFalse);
      }
      expect(state.copyWith(mobileNumber: '').canSubmit, isFalse);
      expect(
        state.copyWith(confirmMobileNumber: '2425551235').canSubmit,
        isFalse,
      );
      expect(state.copyWith(selectedService: _fibr).canSubmit, isFalse);
    });

    blocTest<GuestPayBillBloc, GuestPayBillState>(
      'service switch clears account, amount and inputs and blocks payment',
      build: () => GuestPayBillBloc(repo: repository),
      seed: _verifiedPostpaid,
      act: (bloc) async {
        await _send(
          bloc,
          const GuestPayBillServiceChanged(_fibr),
          (state) => state.isAlivFibr,
        );
        bloc.add(const GuestPayBillSubmitPressed());
      },
      verify: (bloc) {
        final state = bloc.state;
        expect(state.accountInfo, isNull);
        expect(state.amountText, isEmpty);
        expect(state.accountNumber, isEmpty);
        expect(state.name, isEmpty);
        expect(state.mobileNumber, isEmpty);
        expect(state.confirmMobileNumber, isEmpty);
        expect(state.verifyStatus, GuestPayBillVerifyStatus.idle);
        expect(state.canVerify, isFalse);
        expect(state.canSubmit, isFalse);
        verifyNever(
          () => repository.submitBillPayment(
            serviceCode: any(named: 'serviceCode'),
            identifier: any(named: 'identifier'),
            amount: any(named: 'amount'),
          ),
        );
      },
    );

    for (final event in <GuestPayBillEvent>[
      const GuestPayBillMobileChanged('2425559999'),
      const GuestPayBillConfirmMobileChanged('2425559999'),
      const GuestPayBillCountryChanged(
        PayBillCountry(flagEmoji: '🇺🇸', dialCode: '1', isoCode: 'US'),
      ),
    ]) {
      blocTest<GuestPayBillBloc, GuestPayBillState>(
        '$event invalidates the previous verified Postpaid account',
        build: () => GuestPayBillBloc(repo: repository),
        seed: _verifiedPostpaid,
        act: (bloc) => bloc.add(event),
        verify: (bloc) {
          expect(bloc.state.accountInfo, isNull);
          expect(bloc.state.verifyStatus, GuestPayBillVerifyStatus.idle);
          expect(bloc.state.canSubmit, isFalse);
        },
      );
    }

    for (final event in <GuestPayBillEvent>[
      const GuestPayBillAccountNumberChanged('new-account'),
      const GuestPayBillNameChanged('New Name'),
    ]) {
      blocTest<GuestPayBillBloc, GuestPayBillState>(
        '$event invalidates the previous verified Fibr account',
        build: () => GuestPayBillBloc(repo: repository),
        seed: () => _verifiedPostpaid().copyWith(
          selectedService: _fibr,
          accountNumber: '1001',
          name: 'Jane Doe',
          accountInfo: _fibrInfo,
        ),
        act: (bloc) => bloc.add(event),
        verify: (bloc) {
          expect(bloc.state.accountInfo, isNull);
          expect(bloc.state.verifyStatus, GuestPayBillVerifyStatus.idle);
          expect(bloc.state.canSubmit, isFalse);
        },
      );
    }

    blocTest<GuestPayBillBloc, GuestPayBillState>(
      'editing only the amount preserves current account verification',
      build: () => GuestPayBillBloc(repo: repository),
      seed: _verifiedPostpaid,
      act: (bloc) => bloc.add(const GuestPayBillAmountChanged('20')),
      verify: (bloc) {
        expect(bloc.state.accountInfo, same(_postpaidInfo));
        expect(bloc.state.verifyStatus, GuestPayBillVerifyStatus.success);
        expect(bloc.state.canSubmit, isTrue);
      },
    );

    blocTest<GuestPayBillBloc, GuestPayBillState>(
      'a current lookup failure clears old details and a retry can verify again',
      build: () => GuestPayBillBloc(repo: repository),
      seed: _verifiedPostpaid,
      act: (bloc) async {
        when(
          () => repository.verifyAlivPostpaid(
            mobileNumber: any(named: 'mobileNumber'),
            confirmMobileNumber: any(named: 'confirmMobileNumber'),
          ),
        ).thenThrow(Exception('lookup failed'));
        final failed = await _send(
          bloc,
          const GuestPayBillVerifyPressed(),
          (state) => state.verifyStatus == GuestPayBillVerifyStatus.failure,
        );
        expect(failed.accountInfo, isNull);
        expect(failed.canSubmit, isFalse);
        expect(failed.errorMessage, 'Mobile number mismatch or invalid.');
        when(
          () => repository.verifyAlivPostpaid(
            mobileNumber: any(named: 'mobileNumber'),
            confirmMobileNumber: any(named: 'confirmMobileNumber'),
          ),
        ).thenAnswer((_) async => _postpaidInfo);
        await _send(
          bloc,
          const GuestPayBillVerifyPressed(),
          (state) => state.verifyStatus == GuestPayBillVerifyStatus.success,
        );
      },
      verify: (bloc) {
        expect(bloc.state.accountInfo, same(_postpaidInfo));
        expect(bloc.state.errorMessage, isNull);
        expect(bloc.state.canSubmit, isTrue);
      },
    );

    for (final fails in [false, true]) {
      blocTest<GuestPayBillBloc, GuestPayBillState>(
        'late Postpaid ${fails ? 'failure' : 'success'} cannot overwrite a newer Fibr lookup',
        build: () => GuestPayBillBloc(repo: repository),
        seed: _verifiedPostpaid,
        act: (bloc) async {
          final pending = Completer<PayBillAccountInfo>();
          when(
            () => repository.verifyAlivPostpaid(
              mobileNumber: any(named: 'mobileNumber'),
              confirmMobileNumber: any(named: 'confirmMobileNumber'),
            ),
          ).thenAnswer((_) => pending.future);
          when(
            () => repository.verifyAlivFibr(
              accountNumberOrUsername: '1001',
              enteredName: 'Jane Doe',
            ),
          ).thenAnswer((_) async => _fibrInfo);
          await _send(
            bloc,
            const GuestPayBillVerifyPressed(),
            (state) => state.verifyStatus == GuestPayBillVerifyStatus.loading,
          );
          await _send(
            bloc,
            const GuestPayBillServiceChanged(_fibr),
            (state) => state.isAlivFibr,
          );
          await _send(
            bloc,
            const GuestPayBillAccountNumberChanged('1001'),
            (state) => state.accountNumber == '1001',
          );
          await _send(
            bloc,
            const GuestPayBillNameChanged('Jane Doe'),
            (state) => state.canVerify,
          );
          await _send(
            bloc,
            const GuestPayBillVerifyPressed(),
            (state) => state.verifyStatus == GuestPayBillVerifyStatus.success,
          );
          if (fails) {
            pending.completeError(Exception('old Postpaid request failed'));
          } else {
            pending.complete(_postpaidInfo);
          }
        },
        verify: (bloc) {
          expect(bloc.state.isAlivFibr, isTrue);
          expect(bloc.state.accountInfo, same(_fibrInfo));
          expect(bloc.state.verifyStatus, GuestPayBillVerifyStatus.success);
          expect(bloc.state.errorMessage, isNull);
        },
      );

      blocTest<GuestPayBillBloc, GuestPayBillState>(
        'editing and restoring a number still discards its old ${fails ? 'failure' : 'success'}',
        build: () => GuestPayBillBloc(repo: repository),
        seed: _verifiedPostpaid,
        act: (bloc) async {
          final pending = Completer<PayBillAccountInfo>();
          when(
            () => repository.verifyAlivPostpaid(
              mobileNumber: any(named: 'mobileNumber'),
              confirmMobileNumber: any(named: 'confirmMobileNumber'),
            ),
          ).thenAnswer((_) => pending.future);
          await _send(
            bloc,
            const GuestPayBillVerifyPressed(),
            (state) => state.verifyStatus == GuestPayBillVerifyStatus.loading,
          );
          await _send(
            bloc,
            const GuestPayBillMobileChanged('2425559999'),
            (state) => state.mobileNumber == '2425559999',
          );
          await _send(
            bloc,
            const GuestPayBillMobileChanged('2425551234'),
            (state) => state.mobileNumber == '2425551234',
          );
          if (fails) {
            pending.completeError(Exception('outdated lookup failed'));
          } else {
            pending.complete(_postpaidInfo);
          }
        },
        verify: (bloc) {
          expect(bloc.state.accountInfo, isNull);
          expect(bloc.state.verifyStatus, GuestPayBillVerifyStatus.idle);
          expect(bloc.state.canSubmit, isFalse);
          expect(bloc.state.errorMessage, isNull);
        },
      );
    }
  });

  group('service switch form', () {
    late _Network network;
    late List<GuestPayBillConfirmArgs> confirmations;

    setUp(() async {
      await instance.reset();
      network = _Network();
      confirmations = [];
      instance.registerSingleton<NetworkService>(network);
      for (final path in [Api.guestBalanceUrl, Api.guestFibrBalanceUrl]) {
        when(
          () => network.request<dynamic>(
            path,
            method: HttpMethod.post,
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response<dynamic>(
            requestOptions: RequestOptions(path: path),
            data: path == Api.guestBalanceUrl
                ? {
                    'Balance': 80.0,
                    'AccountStatus': 'AC',
                    'PaymentOption': 'PostPay',
                  }
                : {'Balance': 150.0, 'AccountStatus': 'AC', 'id_acc': 1001},
          ),
        );
      }
    });
    tearDown(() async => instance.reset());

    Finder field(String hint) => find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.hintText == hint,
    );

    String text(WidgetTester tester, Finder finder) => tester
        .widget<EditableText>(
          find.descendant(of: finder, matching: find.byType(EditableText)),
        )
        .controller
        .text;

    Future<void> pumpScreen(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        routes: [
          GoRoute(path: '/', builder: (_, _) => const GuestPayBillScreen()),
          GoRoute(
            path: AppRoutes.guestPayBillConfirm,
            builder: (_, state) {
              confirmations.add(state.extra! as GuestPayBillConfirmArgs);
              return const Scaffold(body: Text('confirmation destination'));
            },
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
    }

    Future<void> selectService(WidgetTester tester, String label) async {
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.ensureVisible(find.byType(DropdownButton<BillService>));
      await tester.tap(find.byType(DropdownButton<BillService>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    Future<void> verifyFibr(WidgetTester tester) async {
      await tester.enterText(field('enter ID'), '1001');
      await tester.enterText(field('enter name'), 'Jane Doe');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    for (final size in [const Size(320, 800), const Size(430, 932)]) {
      testWidgets(
        'Postpaid to Fibr requires fresh details and verification at $size',
        (tester) async {
          await pumpScreen(tester, size);
          final phones = field('eg: (242)-899-9999');
          await tester.enterText(phones.at(0), '2425551234');
          await tester.enterText(phones.at(1), '2425551234');
          await tester.pump();
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          await tester.enterText(field(r'$ 0.00'), '15');
          await tester.pumpAndSettle();
          await selectService(tester, 'ALIVFibr');

          expect(find.text('Active'), findsNothing);
          expect(find.text('------'), findsNWidgets(2));
          expect(text(tester, field('enter ID')), isEmpty);
          expect(text(tester, field('enter name')), isEmpty);
          expect(text(tester, field(r'$ 0.00')), isEmpty);
          final bloc = tester
              .element(find.byType(SingleChildScrollView))
              .read<GuestPayBillBloc>();
          expect(bloc.state.accountInfo, isNull);
          expect(bloc.state.canVerify, isFalse);
          expect(bloc.state.canSubmit, isFalse);
          bloc.add(const GuestPayBillSubmitPressed());
          await tester.pumpAndSettle();
          expect(confirmations, isEmpty);
          verifyNever(
            () => network.request<dynamic>(
              Api.guestFibrBalanceUrl,
              method: HttpMethod.post,
              data: any(named: 'data'),
              options: any(named: 'options'),
            ),
          );

          await verifyFibr(tester);
          expect(find.text('Active'), findsOneWidget);
          expect(bloc.state.accountInfo?.balance, 150);
          await tester.enterText(field(r'$ 0.00'), '20');
          await tester.pumpAndSettle();
          final button = find.byType(GuestPayBillPrimarySubmitButton);
          await tester.ensureVisible(button);
          await tester.tap(
            find.descendant(of: button, matching: find.byType(ElevatedButton)),
          );
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();
          expect(confirmations, hasLength(1));
          expect(confirmations.single.serviceName, 'ALIVFibr');
          expect(confirmations.single.identifierValue, '1001');
          expect(confirmations.single.fibrAccountId, 1001);
          expect(confirmations.single.amount, 20);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('switching away from Fibr and back leaves all inputs empty', (
      tester,
    ) async {
      await pumpScreen(tester, const Size(430, 932));
      await selectService(tester, 'ALIVFibr');
      await verifyFibr(tester);
      await tester.enterText(field(r'$ 0.00'), '25');
      await tester.pumpAndSettle();
      await selectService(tester, 'ALIV Postpaid');
      expect(text(tester, field('eg: (242)-899-9999').at(0)), isEmpty);
      expect(text(tester, field('eg: (242)-899-9999').at(1)), isEmpty);
      expect(text(tester, field(r'$ 0.00')), isEmpty);
      await selectService(tester, 'ALIVFibr');
      expect(text(tester, field('enter ID')), isEmpty);
      expect(text(tester, field('enter name')), isEmpty);
      expect(text(tester, field(r'$ 0.00')), isEmpty);
      expect(find.text('Active'), findsNothing);
      expect(confirmations, isEmpty);
      expect(tester.takeException(), isNull);
    });
  });
}
