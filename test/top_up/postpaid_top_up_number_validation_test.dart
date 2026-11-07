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
