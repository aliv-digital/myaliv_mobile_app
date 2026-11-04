import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/cubit/gift_data_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/cubit/gift_data_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/gift_data_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/repository/gift_data_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/gift_data_error_banner.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/gift_data_form_body.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/recipient_phone_field.dart';

class _MockGiftDataRepository extends Mock implements GiftDataRepository {}

class _MockAccountInfoCubit extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecipientVerificationResult model', () {
    test('identifies prepaid active account correctly', () {
      const activePrepaid = RecipientVerificationResult(
        accountStatus: 'AC',
        paymentOption: 'PrePay',
      );
      expect(activePrepaid.isPrepaid, isTrue);
      expect(activePrepaid.isPostpaid, isFalse);
      expect(activePrepaid.isActive, isTrue);
      expect(activePrepaid.isValidPrepaid, isTrue);
    });

    test('identifies postpaid account correctly', () {
      const activePostpaid = RecipientVerificationResult(
        accountStatus: 'AC',
        paymentOption: 'PostPay',
      );
      expect(activePostpaid.isPrepaid, isFalse);
      expect(activePostpaid.isPostpaid, isTrue);
      expect(activePostpaid.isActive, isTrue);
      expect(activePostpaid.isValidPrepaid, isFalse);
    });

    test('identifies inactive account correctly', () {
      const inactivePrepaid = RecipientVerificationResult(
        accountStatus: 'SU',
        paymentOption: 'PrePay',
      );
      expect(inactivePrepaid.isPrepaid, isTrue);
      expect(inactivePrepaid.isActive, isFalse);
      expect(inactivePrepaid.isValidPrepaid, isFalse);
    });
  });

  group('GiftDataCubit recipient validation', () {
    late _MockGiftDataRepository repository;
    late _MockAccountInfoCubit accountInfoCubit;

    setUp(() {
      repository = _MockGiftDataRepository();
      accountInfoCubit = _MockAccountInfoCubit();
      when(() => accountInfoCubit.state).thenReturn(
        const AccountInfoState(
          accountInfo: AccountInfoModel(
            primaryPhoneNumber: '2421234567',
            phoneNumber: '2421234567',
          ),
        ),
      );
    });

    test(
      'emits invalidActivePrepaidErrorMessage when recipient is postpaid',
      () async {
        when(() => repository.verifyRecipient('2428998888')).thenAnswer(
          (_) async => const RecipientVerificationResult(
            accountStatus: 'AC',
            paymentOption: 'PostPay',
          ),
        );

        final cubit = GiftDataCubit(
          repository: repository,
          accountInfoCubit: accountInfoCubit,
        );

        cubit.recipientChanged('2428998888');
        cubit.confirmRecipientChanged('2428998888');

        // Wait for debounce & verification
        await Future<void>.delayed(const Duration(milliseconds: 600));

        expect(
          cubit.state.recipientErrorMessage,
          GiftDataTheme.invalidActivePrepaidErrorMessage,
        );
        expect(cubit.state.amountOptions, isEmpty);

        await cubit.close();
      },
    );

    test(
      'emits invalidActivePrepaidErrorMessage when recipient is inactive',
      () async {
        when(() => repository.verifyRecipient('2428998888')).thenAnswer(
          (_) async => const RecipientVerificationResult(
            accountStatus: 'SU',
            paymentOption: 'PrePay',
          ),
        );

        final cubit = GiftDataCubit(
          repository: repository,
          accountInfoCubit: accountInfoCubit,
        );

        cubit.recipientChanged('2428998888');
        cubit.confirmRecipientChanged('2428998888');

        await Future<void>.delayed(const Duration(milliseconds: 600));

        expect(
          cubit.state.recipientErrorMessage,
          GiftDataTheme.invalidActivePrepaidErrorMessage,
        );
        expect(cubit.state.amountOptions, isEmpty);

        await cubit.close();
      },
    );

    test(
      'emits recipientErrorReason when API returns NoDataSharesActive with empty plans',
      () async {
        when(() => repository.verifyRecipient('2428998888')).thenAnswer(
          (_) async => const RecipientVerificationResult(
            accountStatus: 'AC',
            paymentOption: 'PrePay',
          ),
        );
        when(
          () => repository.fetchSendDataShareOptions('2428998888'),
        ).thenAnswer(
          (_) async => const GiftDataSendOptions(
            isSenderEligible: false,
            options: [],
            reason: 'NoDataSharesActive',
          ),
        );

        final cubit = GiftDataCubit(
          repository: repository,
          accountInfoCubit: accountInfoCubit,
        );

        cubit.recipientChanged('2428998888');
        cubit.confirmRecipientChanged('2428998888');

        await Future<void>.delayed(const Duration(milliseconds: 600));

        expect(cubit.state.hasRecipientErrorBanner, isTrue);
        expect(
          cubit.state.recipientErrorBannerTitle,
          'Error: RecipientNotEligible',
        );
        expect(
          cubit.state.recipientErrorBannerMessage,
          'Please confirm the phone numbers match',
        );
        expect(cubit.state.amountOptions, isEmpty);

        await cubit.close();
      },
    );

    test('loads amount options when recipient is active prepaid', () async {
      when(() => repository.verifyRecipient('2428998888')).thenAnswer(
        (_) async => const RecipientVerificationResult(
          accountStatus: 'AC',
          paymentOption: 'PrePay',
        ),
      );
      when(() => repository.fetchSendDataShareOptions('2428998888')).thenAnswer(
        (_) async => const GiftDataSendOptions(
          isSenderEligible: true,
          options: [
            GiftAmountOption(
              planId: 1,
              dataSharePlanId: 10,
              amountGb: 0.5,
              label: '500 mb',
            ),
          ],
          reason: '',
        ),
      );

      final cubit = GiftDataCubit(
        repository: repository,
        accountInfoCubit: accountInfoCubit,
      );

      cubit.recipientChanged('2428998888');
      cubit.confirmRecipientChanged('2428998888');

      await Future<void>.delayed(const Duration(milliseconds: 600));

      expect(cubit.state.recipientErrorMessage, isNull);
      expect(cubit.state.hasRecipientErrorBanner, isFalse);
      expect(cubit.state.amountOptions.length, 1);
      expect(cubit.state.amountOptions.first.label, '500 mb');

      await cubit.close();
    });
  });

  group('GiftDataFormBody UI inline error validation', () {
    late _MockGiftDataRepository repository;
    late _MockAccountInfoCubit accountInfoCubit;
    late GiftDataCubit cubit;
    late TextEditingController recipientController;
    late TextEditingController confirmRecipientController;

    setUp(() {
      repository = _MockGiftDataRepository();
      accountInfoCubit = _MockAccountInfoCubit();
      when(() => accountInfoCubit.state).thenReturn(
        const AccountInfoState(
          accountInfo: AccountInfoModel(
            primaryPhoneNumber: '2421234567',
            phoneNumber: '2421234567',
          ),
        ),
      );
      cubit = GiftDataCubit(
        repository: repository,
        accountInfoCubit: accountInfoCubit,
      );
      recipientController = TextEditingController();
      confirmRecipientController = TextEditingController();
    });

    tearDown(() async {
      recipientController.dispose();
      confirmRecipientController.dispose();
      await cubit.close();
    });

    Widget buildTestWidget({GiftDataState? customState}) {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<GiftDataCubit>.value(
            value: cubit,
            child: BlocBuilder<GiftDataCubit, GiftDataState>(
              builder: (context, state) => SingleChildScrollView(
                child: GiftDataFormBody(
                  state: customState ?? state,
                  recipientController: recipientController,
                  confirmRecipientController: confirmRecipientController,
                  onContinue: () {},
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets(
      'shows invalid Format error under recipient field when incomplete',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final phoneFields = find.byType(RecipientPhoneField);
        expect(phoneFields, findsNWidgets(2));

        // Enter incomplete format in recipient field
        final recipientInput = find.descendant(
          of: phoneFields.first,
          matching: find.byType(TextField),
        );
        await tester.enterText(recipientInput, '899');
        await tester.pump();

        expect(
          find.text(GiftDataTheme.invalidFormatErrorMessage),
          findsOneWidget,
        );
        await tester.pump(const Duration(milliseconds: 500));
      },
    );

    testWidgets('shows phone numbers do not match error under confirm field', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      final phoneFields = find.byType(RecipientPhoneField);
      final recipientInput = find.descendant(
        of: phoneFields.first,
        matching: find.byType(TextField),
      );
      final confirmInput = find.descendant(
        of: phoneFields.last,
        matching: find.byType(TextField),
      );

      await tester.enterText(recipientInput, '2428998888');
      await tester.pump();

      await tester.enterText(confirmInput, '2428999999');
      await tester.pump();

      expect(
        find.text(GiftDataTheme.phoneMismatchErrorMessage),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets(
      'shows invalidActivePrepaidErrorMessage under recipient field when server returns error',
      (tester) async {
        when(() => repository.verifyRecipient('2428998888')).thenAnswer(
          (_) async => const RecipientVerificationResult(
            accountStatus: 'AC',
            paymentOption: 'PostPay',
          ),
        );

        await tester.pumpWidget(
          buildTestWidget(
            customState: cubit.state.copyWith(
              recipient: '2428998888',
              confirmRecipient: '2428998888',
              recipientErrorMessage:
                  GiftDataTheme.invalidActivePrepaidErrorMessage,
            ),
          ),
        );

        final phoneFields = find.byType(RecipientPhoneField);
        final recipientInput = find.descendant(
          of: phoneFields.first,
          matching: find.byType(TextField),
        );
        final confirmInput = find.descendant(
          of: phoneFields.last,
          matching: find.byType(TextField),
        );

        await tester.enterText(recipientInput, '2428998888');
        await tester.enterText(confirmInput, '2428998888');
        await tester.pump();

        expect(
          find.text(GiftDataTheme.invalidActivePrepaidErrorMessage),
          findsOneWidget,
        );
        await tester.pump(const Duration(milliseconds: 500));
      },
    );

    testWidgets(
      'shows GiftDataErrorBanner when API returns NoDataSharesActive',
      (tester) async {
        when(() => repository.verifyRecipient('2428998888')).thenAnswer(
          (_) async => const RecipientVerificationResult(
            accountStatus: 'AC',
            paymentOption: 'PrePay',
          ),
        );
        when(
          () => repository.fetchSendDataShareOptions('2428998888'),
        ).thenAnswer(
          (_) async => const GiftDataSendOptions(
            isSenderEligible: false,
            options: [],
            reason: 'NoDataSharesActive',
          ),
        );

        await tester.pumpWidget(buildTestWidget());

        final phoneFields = find.byType(RecipientPhoneField);
        final recipientInput = find.descendant(
          of: phoneFields.first,
          matching: find.byType(TextField),
        );
        final confirmInput = find.descendant(
          of: phoneFields.last,
          matching: find.byType(TextField),
        );

        await tester.enterText(recipientInput, '2428998888');
        await tester.enterText(confirmInput, '2428998888');
        await tester.pump();

        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(GiftDataErrorBanner), findsOneWidget);
        expect(find.text('Error: RecipientNotEligible'), findsOneWidget);
        expect(
          find.text('Please confirm the phone numbers match'),
          findsOneWidget,
        );
        await tester.pump(const Duration(milliseconds: 500));
      },
    );
  });
}
