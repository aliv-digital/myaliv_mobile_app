import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/bloc/pay_from_wallet/pay_from_wallet_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/bloc/pay_from_wallet/pay_from_wallet_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/pay_from_wallet.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/balance/models/balance_model.dart';

class _MockPayFromWalletCubit extends MockCubit<PayFromWalletState>
    implements PayFromWalletCubit {}

class _MockBalanceCubit extends MockCubit<BalanceState>
    implements BalanceCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _MockPayFromWalletCubit payFromWalletCubit;
  late _MockBalanceCubit balanceCubit;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    payFromWalletCubit = _MockPayFromWalletCubit();
    balanceCubit = _MockBalanceCubit();

    when(() => payFromWalletCubit.state).thenReturn(const PayFromWalletState());
    when(
      () => payFromWalletCubit.stream,
    ).thenAnswer((_) => const Stream<PayFromWalletState>.empty());
    when(() => balanceCubit.state).thenReturn(
      BalanceState(
        status: BalanceStatus.loaded,
        balance: BalanceModel(
          walletBalance: 129.0,
          bonusBalance: 0.0,
          bonusDetails: const [],
          fetchedAt: DateTime(2026, 1, 1),
        ),
      ),
    );
    when(
      () => balanceCubit.stream,
    ).thenAnswer((_) => const Stream<BalanceState>.empty());

    instance.registerFactory<PayFromWalletCubit>(() => payFromWalletCubit);
  });

  tearDown(() async {
    await instance.reset();
  });

  Widget buildDirectSheet({
    EdgeInsets padding = EdgeInsets.zero,
    double screenWidth = 390,
  }) {
    return MediaQuery(
      data: MediaQueryData(
        size: Size(screenWidth, 844),
        padding: padding,
        viewPadding: padding,
      ),
      child: MaterialApp(
        home: BlocProvider<BalanceCubit>.value(
          value: balanceCubit,
          child: Scaffold(
            backgroundColor: Colors.grey,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: screenWidth,
                child: const PayFromWalletSheet(
                  amount: 75.0,
                  phoneNumber: '2428999999',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('Bug 30: PayFromWalletSheet bottom position and background', () {
    testWidgets(
      'outer container has solid white background and wraps SafeArea inside',
      (tester) async {
        await tester.pumpWidget(buildDirectSheet());
        await tester.pumpAndSettle();

        expect(find.text('pay from wallet'), findsOneWidget);
        expect(find.text('confirm payment'), findsOneWidget);

        // Find the outer white Container
        final containerFinder = find.byWidgetPredicate((widget) {
          if (widget is Container && widget.decoration is BoxDecoration) {
            final decoration = widget.decoration as BoxDecoration;
            return decoration.color == Colors.white &&
                decoration.borderRadius ==
                    const BorderRadius.vertical(top: Radius.circular(20));
          }
          return false;
        });

        expect(containerFinder, findsOneWidget);

        // Assert that SafeArea is INSIDE the outer white Container (child of Container)
        final safeAreaInsideContainer = find.descendant(
          of: containerFinder,
          matching: find.byType(SafeArea),
        );
        expect(safeAreaInsideContainer, findsOneWidget);
      },
    );

    for (final width in [320.0, 390.0, 430.0]) {
      testWidgets('renders without overflow at width $width', (tester) async {
        await tester.pumpWidget(
          buildDirectSheet(
            screenWidth: width,
            padding: const EdgeInsets.only(bottom: 34),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('pay from wallet'), findsOneWidget);
        expect(find.text('confirm payment'), findsOneWidget);
        expect(find.text(r'$ 75.00'), findsOneWidget);
      });
    }

    testWidgets(
      'tapping confirm payment calls submitTransfer with recipient and amount',
      (tester) async {
        when(
          () => payFromWalletCubit.submitTransfer(
            toNumber: any(named: 'toNumber'),
            amount: any(named: 'amount'),
          ),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(buildDirectSheet());
        await tester.pumpAndSettle();

        await tester.tap(find.text('confirm payment'));
        await tester.pump();

        verify(
          () => payFromWalletCubit.submitTransfer(
            toNumber: '2428999999',
            amount: 75.0,
          ),
        ).called(1);
      },
    );
  });
}
