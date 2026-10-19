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
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/bloc/top_up_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/send_topup_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/top_up_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/send_top_up_placeholder_tab.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/top_up_prepaid_amount_box.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';

class _MockSendTopupRepository extends Mock implements SendTopupRepository {}

class _MockTopUpPrepaidRepository extends Mock
    implements TopUpPrepaidRepository {}

class _MockBalanceCubit extends MockCubit<BalanceState>
    implements BalanceCubit {}

class _MockAccountInfoCubit extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _MockBalanceState extends Mock implements BalanceState {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockSendTopupRepository sendRepo;
  late _MockTopUpPrepaidRepository topUpRepo;
  late _MockBalanceCubit balanceCubit;
  late _MockAccountInfoCubit accountInfoCubit;
  late _MockBalanceState balanceState;
  late TopUpPrepaidBloc bloc;

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
    sendRepo = _MockSendTopupRepository();
    topUpRepo = _MockTopUpPrepaidRepository();
    balanceCubit = _MockBalanceCubit();
    accountInfoCubit = _MockAccountInfoCubit();
    balanceState = _MockBalanceState();

    when(() => balanceState.walletBalance).thenReturn(100.0);
    when(() => balanceCubit.state).thenReturn(balanceState);
    when(() => accountInfoCubit.state).thenReturn(
      const AccountInfoState(
        accountInfo: AccountInfoModel(primaryPhoneNumber: '2428999999'),
      ),
    );

    bloc = TopUpPrepaidBloc(repo: topUpRepo);
    instance.registerSingleton<SendTopupRepository>(sendRepo);
  });

  tearDown(() async {
    await bloc.close();
    await balanceCubit.close();
    await accountInfoCubit.close();
    await instance.reset();
  });

  Widget buildTestWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TopUpPrepaidBloc>.value(value: bloc),
        BlocProvider<BalanceCubit>.value(value: balanceCubit),
        BlocProvider<AccountInfoCubit>.value(value: accountInfoCubit),
      ],
      child: const MaterialApp(
        home: Scaffold(body: SendTopUpPlaceholderTab(title: 'send top-up')),
      ),
    );
  }

  group('Bug 28: Send Top-Up Phone Fields & Amount Design', () {
    testWidgets(
      'renders phone fields with lavender background, transparent border, and eg: (242)-899-9999 hint',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final phoneRows = tester
            .widgetList<CustomCountryPhoneInputRow>(
              find.byType(CustomCountryPhoneInputRow),
            )
            .toList();

        // There should be 2 phone input rows: enter number and confirm number.
        expect(phoneRows.length, 2);

        for (final row in phoneRows) {
          expect(row.hintText, 'eg: (242)-899-9999');
          expect(row.backgroundColor, const Color(0xFFF2F1F9));
          expect(row.showCountryPickerBorder, isFalse);
          expect(row.showCountryArrow, isFalse);
        }

        // Old placeholder should not be present anywhere.
        expect(find.text('(242)-345-4356'), findsNothing);

        // When valid inputs are entered, both unfocused borders are transparent
        final fields = find.descendant(
          of: find.byType(CustomCountryPhoneInputRow),
          matching: find.byType(TextField),
        );
        await tester.enterText(fields.at(0), '2428011616');
        await tester.enterText(fields.at(1), '2428011616');
        await tester.pumpAndSettle();

        final updatedRows = tester
            .widgetList<CustomCountryPhoneInputRow>(
              find.byType(CustomCountryPhoneInputRow),
            )
            .toList();

        for (final row in updatedRows) {
          expect(row.unfocusedBorderColor, Colors.transparent);
        }
      },
    );

    testWidgets(
      'renders TopUpPrepaidAmountBox with centered design matching Figma and My Number',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(TopUpPrepaidAmountBox), findsOneWidget);
        expect(find.text('enter top-up amount'), findsOneWidget);

        // When empty, TopUpPrepaidAmountBox displays the centered hint $0.00
        expect(find.text(r'$0.00'), findsOneWidget);

        // Enter amount and verify display
        final amountField = find.descendant(
          of: find.byType(TopUpPrepaidAmountBox),
          matching: find.byType(TextField),
        );
        await tester.enterText(amountField, '15.00');
        await tester.pumpAndSettle();

        expect(find.text(r'$'), findsOneWidget);
        expect(find.text('15.00'), findsOneWidget);
      },
    );

    for (final width in [360.0, 390.0, 430.0]) {
      testWidgets('renders without overflow at width $width', (tester) async {
        tester.view.physicalSize = Size(width * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(TopUpPrepaidAmountBox), findsOneWidget);
        expect(find.byType(CustomCountryPhoneInputRow), findsNWidgets(2));
      });
    }
  });
}
