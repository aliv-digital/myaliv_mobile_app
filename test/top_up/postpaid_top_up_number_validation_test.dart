import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/postpaid/bloc/top_up_prepaid_number_postpaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/postpaid/bloc/top_up_prepaid_number_postpaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/postpaid/bloc/top_up_prepaid_number_postpaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/postpaid/repository/top_up_prepaid_number_postpaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/postpaid/widgets/sections/top_up_prepaid_number_postpaid_confirm_number_section.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/postpaid/widgets/sections/top_up_prepaid_number_postpaid_number_section.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/top_up_limit_left_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/top_up_prepaid_repository.dart';

class MockAccountInfoCubit extends Mock implements AccountInfoCubit {}

class MockTopUpPrepaidNumberPostPaidRepository extends Mock
    implements TopUpPrepaidNumberPostPaidRepository {}

class MockTopUpPrepaidRepository extends Mock
    implements TopUpPrepaidRepository {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Postpaid Top-Up State Number Validation', () {
    test('both 7-digit and 10-digit Bahamas numbers match and normalize', () {
      final state1 = TopUpPrepaidNumberPostPaidState.initial().copyWith(
        number: '8011616',
        confirmNumber: '2428011616',
      );
      expect(state1.numbersMatch, isTrue);
      expect(state1.hasConfirmMismatchError, isFalse);
      expect(state1.hasConfirmFormatError, isFalse);

      final state2 = TopUpPrepaidNumberPostPaidState.initial().copyWith(
        number: '2428011616',
        confirmNumber: '8011616',
      );
      expect(state2.numbersMatch, isTrue);
      expect(state2.hasConfirmMismatchError, isFalse);
      expect(state2.hasConfirmFormatError, isFalse);

      final state3 = TopUpPrepaidNumberPostPaidState.initial().copyWith(
        number: '(242)-801-1616',
        confirmNumber: '801-1616',
      );
      expect(state3.numbersMatch, isTrue);
      expect(state3.hasConfirmMismatchError, isFalse);
    });

    test('different valid numbers flag mismatch', () {
      final state = TopUpPrepaidNumberPostPaidState.initial().copyWith(
        number: '2428011616',
        confirmNumber: '2428011617',
      );
      expect(state.numbersMatch, isFalse);
      expect(state.hasConfirmMismatchError, isTrue);
    });

    test('typing matching prefix does not flash mismatch or format error', () {
      for (final prefix in ['2', '24', '242', '2428', '24280', '242801']) {
        final state = TopUpPrepaidNumberPostPaidState.initial().copyWith(
          number: '2428011616',
          confirmNumber: prefix,
        );
        expect(state.hasConfirmMismatchError, isFalse);
        expect(state.hasConfirmFormatError, isFalse);
      }
    });

    test(
      'typing matching 242 prefix for 7-digit recipient does not flash error',
      () {
        for (final prefix in ['2', '24', '242', '2428', '24280', '242801']) {
          final state = TopUpPrepaidNumberPostPaidState.initial().copyWith(
            number: '8011616',
            confirmNumber: prefix,
          );
          expect(state.hasConfirmMismatchError, isFalse);
          expect(state.hasConfirmFormatError, isFalse);
        }
      },
    );

    test('typing mismatching digit immediately flags mismatch', () {
      final state = TopUpPrepaidNumberPostPaidState.initial().copyWith(
        number: '2428011616',
        confirmNumber: '2429',
      );
      expect(state.hasConfirmMismatchError, isTrue);
    });

    test('invalid format in both fields flags format error on confirm', () {
      final state = TopUpPrepaidNumberPostPaidState.initial().copyWith(
        number: '24255',
        confirmNumber: '24255',
      );
      expect(state.numberValidation.isValid, isFalse);
      expect(state.hasConfirmFormatError, isTrue);
      expect(state.hasConfirmMismatchError, isFalse);
    });

    test(
      'own number detection detects primary, secondary, and activeTn numbers',
      () {
        const account = AccountInfoModel(
          primaryPhoneNumber: '2428011616',
          phoneNumber: '2428012222',
        );

        final stateMatchesPrimary7Digit =
            TopUpPrepaidNumberPostPaidState.initial().copyWith(
              number: '8011616',
            );
        expect(stateMatchesPrimary7Digit.isOwnNumber(account, null), isTrue);

        final stateMatchesPrimary10Digit =
            TopUpPrepaidNumberPostPaidState.initial().copyWith(
              number: '2428011616',
            );
        expect(stateMatchesPrimary10Digit.isOwnNumber(account, null), isTrue);

        final stateMatchesSecondary = TopUpPrepaidNumberPostPaidState.initial()
            .copyWith(number: '8012222');
        expect(stateMatchesSecondary.isOwnNumber(account, null), isTrue);

        final stateMatchesActiveTn = TopUpPrepaidNumberPostPaidState.initial()
            .copyWith(number: '8019999');
        expect(stateMatchesActiveTn.isOwnNumber(account, '2428019999'), isTrue);

        final stateDifferent = TopUpPrepaidNumberPostPaidState.initial()
            .copyWith(number: '8013333');
        expect(stateDifferent.isOwnNumber(account, '2428019999'), isFalse);
      },
    );
  });

  group('Postpaid Top-Up Bloc Own Number Rejection', () {
    late MockAccountInfoCubit mockAccountInfoCubit;
    late MockTopUpPrepaidNumberPostPaidRepository mockRepo;
    late MockTopUpPrepaidRepository mockTopUpRepo;

    setUp(() {
      mockAccountInfoCubit = MockAccountInfoCubit();
      mockRepo = MockTopUpPrepaidNumberPostPaidRepository();
      mockTopUpRepo = MockTopUpPrepaidRepository();
      when(
        () => mockTopUpRepo.fetchTopUpLimitLeft(),
      ).thenAnswer((_) async => const TopUpLimitLeft(limitLeft: 500));
      when(() => mockAccountInfoCubit.state).thenReturn(
        const AccountInfoState(
          accountInfo: AccountInfoModel(primaryPhoneNumber: '2428011616'),
        ),
      );
    });

    test('rejects own number when apply is pressed', () async {
      final bloc = TopUpPrepaidNumberPostPaidBloc(
        repo: mockRepo,
        topUpRepo: mockTopUpRepo,
        accountInfoCubit: mockAccountInfoCubit,
      );

      bloc.add(const TopUpPrepaidNumberPostPaidStarted());
      await Future<void>.delayed(const Duration(milliseconds: 200));
      bloc.add(const TopUpPrepaidNumberPostPaidNumberChanged('8011616'));
      bloc.add(
        const TopUpPrepaidNumberPostPaidConfirmNumberChanged('2428011616'),
      );
      bloc.add(const TopUpPrepaidNumberPostPaidAmountChanged('25.00'));
      await pumpEventQueue();

      expect(bloc.state.canApply, isTrue);

      bloc.add(const TopUpPrepaidNumberPostPaidApplyPressed());
      await pumpEventQueue();

      expect(
        bloc.state.applyStatus,
        TopUpPrepaidNumberPostPaidApplyStatus.failure,
      );
      expect(
        bloc.state.errorMessage,
        'You cannot send a top-up to your own number.',
      );

      await bloc.close();
    });
  });

  group('TopUpPrepaidNumberPostPaidConfirmNumberSection UI', () {
    testWidgets('displays invalid Format when hasFormatError is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopUpPrepaidNumberPostPaidConfirmNumberSection(
              value: '24255',
              hasFormatError: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('invalid Format'), findsOneWidget);
      expect(find.text('phone numbers do not match'), findsNothing);
    });

    testWidgets(
      'displays phone numbers do not match when hasMismatchError is true',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TopUpPrepaidNumberPostPaidConfirmNumberSection(
                value: '2428011617',
                hasMismatchError: true,
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('phone numbers do not match'), findsOneWidget);
        expect(find.text('invalid Format'), findsNothing);
      },
    );
  });

  group('Postpaid Top-Up Focus Traversal', () {
    testWidgets('advances focus from number to confirm on submit', (
      tester,
    ) async {
      final numberFocusNode = FocusNode();
      final confirmFocusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TopUpPrepaidNumberPostPaidNumberSection(
                  value: '8011616',
                  focusNode: numberFocusNode,
                  onChanged: (_) {},
                  onSubmitted: (_) => confirmFocusNode.requestFocus(),
                ),
                TopUpPrepaidNumberPostPaidConfirmNumberSection(
                  value: '',
                  focusNode: confirmFocusNode,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      );

      numberFocusNode.requestFocus();
      await tester.pump();
      expect(numberFocusNode.hasFocus, isTrue);
      expect(confirmFocusNode.hasFocus, isFalse);

      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      expect(confirmFocusNode.hasFocus, isTrue);

      numberFocusNode.dispose();
      confirmFocusNode.dispose();
    });
  });
}
