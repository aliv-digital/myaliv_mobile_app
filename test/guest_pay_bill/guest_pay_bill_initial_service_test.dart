import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/bloc/guest_pay_bill_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/bloc/guest_pay_bill_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/model/guest_pay_bill_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/repository/guest_pay_bill_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/view/guest_pay_bill_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/widgets/guest_pay_bill_pay_with_rev_card.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class MockGuestPayBillRepository extends Mock
    implements GuestPayBillRepository {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('GuestPayBillBloc initial service selection', () {
    late MockGuestPayBillRepository mockRepo;
    const services = [
      BillService(code: 'ALIV_POSTPAID', label: 'ALIV Postpaid'),
      BillService(code: 'ALIV_FIBR', label: 'ALIVFibr'),
      BillService(code: 'REV', label: 'REV'),
    ];

    setUp(() {
      mockRepo = MockGuestPayBillRepository();
      when(() => mockRepo.fetchServices()).thenAnswer((_) async => services);
    });

    test(
      'defaults to ALIV Postpaid when initialServiceCode is omitted',
      () async {
        final bloc = GuestPayBillBloc(repo: mockRepo);
        bloc.add(const GuestPayBillStarted());
        await pumpEventQueue();

        expect(bloc.state.selectedService?.code, 'ALIV_POSTPAID');
        await bloc.close();
      },
    );

    test('selects REV when initialServiceCode is REV', () async {
      final bloc = GuestPayBillBloc(repo: mockRepo);
      bloc.add(const GuestPayBillStarted(initialServiceCode: 'REV'));
      await pumpEventQueue();

      expect(bloc.state.selectedService?.code, 'REV');
      expect(bloc.state.isRev, isTrue);
      await bloc.close();
    });

    test(
      'selects REV case-insensitively when initialServiceCode is rev',
      () async {
        final bloc = GuestPayBillBloc(repo: mockRepo);
        bloc.add(const GuestPayBillStarted(initialServiceCode: 'rev'));
        await pumpEventQueue();

        expect(bloc.state.selectedService?.code, 'REV');
        expect(bloc.state.isRev, isTrue);
        await bloc.close();
      },
    );
  });

  group('GuestPayBillScreen initial service UI', () {
    testWidgets('renders REV initially when initialServiceCode is REV', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GuestPayBillScreen(initialServiceCode: 'REV')),
        ),
      );

      // Wait for fetchServices (delayed by 250ms in real repo)
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('REV'), findsWidgets);
      expect(find.byType(GuestPayBillPayWithRevCard), findsOneWidget);
    });
  });

  group('AppRouter navigation to guestPayBill with service query param', () {
    testWidgets('navigating with ?service=REV initializes REV', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.push(
                  '${AppRoutes.guestPayBill}?service=REV',
                  extra: 'REV',
                ),
                child: const Text('Go'),
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.guestPayBill,
            builder: (context, state) {
              final serviceCode =
                  state.uri.queryParameters['service'] ??
                  (state.extra is String ? state.extra as String : null);
              return GuestPayBillScreen(initialServiceCode: serviceCode);
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Go'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('REV'), findsWidgets);
      expect(find.byType(GuestPayBillPayWithRevCard), findsOneWidget);
    });
  });
}
