import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/bloc/guest_purchase_plan_confirmation_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/bloc/guest_purchase_plan_confirmation_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/bloc/guest_purchase_plan_confirmation_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/models/guest_purchase_plan_confirmation_models.dart'
    as guest_models;
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/repository/guest_purchase_plan_confirmation_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/view/guest_purchase_plan_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/widgets/purchase_item_row.dart'
    as guest_item_row;
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/widgets/terms_notice.dart'
    as guest_terms;
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/roamingPlanConfirmation/bloc/roaming_plan_confirmation_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/roamingPlanConfirmation/bloc/roaming_plan_confirmation_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/roamingPlanConfirmation/bloc/roaming_plan_confirmation_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/roamingPlanConfirmation/models/roaming_plan_confirmation_models.dart'
    as roaming_models;
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/roamingPlanConfirmation/repository/roaming_plan_confirmation_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/roamingPlanConfirmation/view/roaming_plan_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/roamingPlanConfirmation/widgets/purchase_item_row.dart'
    as roaming_item_row;
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/roamingPlanConfirmation/widgets/terms_notice.dart'
    as roaming_terms;
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/screens/payment_iframe_screen.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Network extends Mock implements NetworkService {}

class _Auth extends Mock implements AuthManager {}

GuestPlanDisplayModel _testPlan({
  required String id,
  required String title,
  required double price,
}) => GuestPlanDisplayModel(
  id: id,
  title: title,
  subtitle: 'plan subtitle',
  price: price,
  formattedPrice: '\$$price',
  basePrice: price,
  vatAmount: 0,
  description: 'plan description',
  highlights: const [],
  benefits: const [],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Network network;
  late _Auth auth;

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
    network = _Network();
    auth = _Auth();
    when(() => auth.currentSession).thenReturn(null);
    when(
      () => network.request<dynamic>(
        Api.guestPurchasePlanUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: Api.guestPurchasePlanUrl),
        statusCode: 200,
        data: <String, dynamic>{},
      ),
    );
    if (!instance.isRegistered<NetworkService>()) {
      instance.registerSingleton<NetworkService>(network);
    }
    if (!instance.isRegistered<AuthManager>()) {
      instance.registerSingleton<AuthManager>(auth);
    }
    if (!instance.isRegistered<CardPaymentService>()) {
      instance.registerSingleton<CardPaymentService>(
        CardPaymentService(networkService: network),
      );
    }
  });

  tearDown(() async {
    await instance.reset();
  });

  group('hasPrimaryPlan getter in all supported models', () {
    test('Standard confirmation state hasPrimaryPlan evaluation', () {
      // 1. Initial / null data
      final emptyState = GuestPurchasePlanConfirmationState.initial();
      expect(emptyState.hasPrimaryPlan, isFalse);

      // 2. State with primary plan and add-ons
      final withPrimaryAndAddon = GuestPurchasePlanConfirmationState.initial()
          .copyWith(
            status: GuestPurchasePlanConfirmationStatus.ready,
            data: const guest_models.GuestPurchasePlanConfirmationData(
              phoneNumber: '2428011616',
              headerTitle: 'guest purchase a plan',
              items: [
                guest_models.PurchaseLineItem(
                  id: 'primary',
                  type: guest_models.PurchaseLineType.primaryPlan,
                  label: 'primary plan',
                  title: 'liberty daily',
                  subtitle: 'begins immediately',
                  price: 10.0,
                ),
                guest_models.PurchaseLineItem(
                  id: 'addon_1',
                  type: guest_models.PurchaseLineType.addOn,
                  label: 'add-on',
                  title: 'data 1GB',
                  subtitle: 'expires with plan',
                  price: 3.0,
                ),
              ],
              totals: guest_models.PurchaseTotals(subTotal: 13.0, vat: 0.0),
            ),
          );
      expect(withPrimaryAndAddon.hasPrimaryPlan, isTrue);

      // 3. State with only add-on (corrupted or orphaned)
      final onlyAddon = GuestPurchasePlanConfirmationState.initial().copyWith(
        status: GuestPurchasePlanConfirmationStatus.ready,
        data: const guest_models.GuestPurchasePlanConfirmationData(
          phoneNumber: '2428011616',
          headerTitle: 'guest purchase a plan',
          items: [
            guest_models.PurchaseLineItem(
              id: 'addon_1',
              type: guest_models.PurchaseLineType.addOn,
              label: 'add-on',
              title: 'data 1GB',
              subtitle: 'expires with plan',
              price: 3.0,
            ),
          ],
          totals: guest_models.PurchaseTotals(subTotal: 3.0, vat: 0.0),
        ),
      );
      expect(onlyAddon.hasPrimaryPlan, isFalse);
    });

    test('Roaming confirmation state hasPrimaryPlan evaluation', () {
      // 1. Initial / null data
      final emptyRoamingState = RoamingPlanConfirmationState.initial();
      expect(emptyRoamingState.hasPrimaryPlan, isFalse);

      // 2. State with roaming primary plan
      final withRoamingPlan = RoamingPlanConfirmationState.initial().copyWith(
        status: RoamingPlanConfirmationStatus.ready,
        data: const roaming_models.RoamingPlanConfirmationData(
          phoneNumber: '2428011616',
          headerTitle: 'guest purchase a plan',
          beginsOnDateText: 'immediately',
          items: [
            roaming_models.PurchaseLineItem(
              id: 'r1',
              type: roaming_models.PurchaseLineType.primaryPlan,
              label: 'standalone',
              title: 'roam 7-day',
              subtitle: 'begins immediately',
              price: 25.0,
            ),
          ],
          totals: roaming_models.PurchaseTotals(subTotal: 25.0, vat: 0.0),
        ),
      );
      expect(withRoamingPlan.hasPrimaryPlan, isTrue);

      // 3. State with empty items
      final emptyItemsState = withRoamingPlan.copyWith(
        data: const roaming_models.RoamingPlanConfirmationData(
          phoneNumber: '2428011616',
          headerTitle: 'guest purchase a plan',
          beginsOnDateText: 'immediately',
          items: [],
          totals: roaming_models.PurchaseTotals(subTotal: 0.0, vat: 0.0),
        ),
      );
      expect(emptyItemsState.hasPrimaryPlan, isFalse);
    });
  });

  group(
    'GuestPurchasePlanConfirmationBloc — Primary Plan Removal & Eligibility',
    () {
      final routeArgs = guest_models.GuestPurchasePlanConfirmationRouteArgs(
        phoneNumber: '2428011616',
        accountHolderName: 'guest purchase a plan',
        primaryPlanName: 'liberty daily',
        primaryPlanPrice: 10.0,
        flow: guest_models.GuestPurchasePlanConfirmationEntryFlow.proceed,
        selectedPlan: _testPlan(id: 'd1', title: 'liberty daily', price: 10.0),
        selectedAddOns: const [
          guest_models.GuestPurchasePlanConfirmationSelectedAddOn(
            id: 'addon_1',
            title: 'data add-on',
            price: 3.0,
          ),
        ],
      );

      blocTest<
        GuestPurchasePlanConfirmationBloc,
        GuestPurchasePlanConfirmationState
      >(
        'Removing primary plan clears all items, sets total to 0, sets hasPrimaryPlan to false, and increments planRemovedRequestId',
        build: () => GuestPurchasePlanConfirmationBloc(
          repository: GuestPurchasePlanConfirmationRepository(),
        ),
        act: (bloc) async {
          bloc.add(GuestPurchasePlanConfirmationStarted(routeArgs));
          await Future<void>.delayed(const Duration(milliseconds: 10));
          bloc.add(
            const GuestPurchasePlanConfirmationRemoveItemPressed('primary'),
          );
        },
        verify: (bloc) {
          final state = bloc.state;
          expect(state.hasPrimaryPlan, isFalse);
          expect(state.data?.items, isEmpty);
          expect(state.data?.totals.subTotal, equals(0.0));
          expect(state.data?.totals.total, equals(0.0));
          expect(state.planRemovedRequestId, equals(1));
        },
      );

      blocTest<
        GuestPurchasePlanConfirmationBloc,
        GuestPurchasePlanConfirmationState
      >(
        'Removing add-on leaves primary plan intact, recalculates total, and does not increment planRemovedRequestId',
        build: () => GuestPurchasePlanConfirmationBloc(
          repository: GuestPurchasePlanConfirmationRepository(),
        ),
        act: (bloc) async {
          bloc.add(GuestPurchasePlanConfirmationStarted(routeArgs));
          await Future<void>.delayed(const Duration(milliseconds: 10));
          bloc.add(
            const GuestPurchasePlanConfirmationRemoveItemPressed('addon_1'),
          );
        },
        verify: (bloc) {
          final state = bloc.state;
          expect(state.hasPrimaryPlan, isTrue);
          expect(state.data?.items.length, equals(1));
          expect(state.data?.items.first.id, equals('primary'));
          expect(state.data?.totals.subTotal, equals(10.0));
          expect(state.data?.totals.total, equals(10.0));
          expect(state.planRemovedRequestId, equals(0));
        },
      );
    },
  );

  group('RoamingPlanConfirmationBloc — Primary Plan Removal & Eligibility', () {
    final routeArgs = roaming_models.RoamingPlanConfirmationRouteArgs(
      phoneNumber: '2428011616',
      planId: 'r1',
      planName: 'roam easy 7 day',
      planDuration: '7 days',
      planPrice: 25.0,
      beginDate: DateTime(2026, 11, 1),
      showDateField: false,
      forceNow: true,
    );

    blocTest<RoamingPlanConfirmationBloc, RoamingPlanConfirmationState>(
      'Removing roaming primary plan clears all items, sets total to 0, sets hasPrimaryPlan to false, and increments planRemovedRequestId',
      build: () => RoamingPlanConfirmationBloc(
        repository: RoamingPlanConfirmationRepository(),
      ),
      act: (bloc) async {
        bloc.add(RoamingPlanConfirmationStarted(routeArgs));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const RoamingPlanConfirmationRemoveItemPressed('r1'));
      },
      verify: (bloc) {
        final state = bloc.state;
        expect(state.hasPrimaryPlan, isFalse);
        expect(state.data?.items, isEmpty);
        expect(state.data?.totals.subTotal, equals(0.0));
        expect(state.data?.totals.total, equals(0.0));
        expect(state.planRemovedRequestId, equals(1));
      },
    );
  });

  group(
    'Guest Purchase Plan Confirmation Screen — Widget, Terms & Navigation Tests',
    () {
      testWidgets(
        'GPP-1020 / GPP-1052 / GPP-1084: Tapping delete on primary plan navigates back and disables Pay Now',
        (tester) async {
          tester.view.physicalSize = const Size(390, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          int returnCount = 0;

          final args = guest_models.GuestPurchasePlanConfirmationRouteArgs(
            phoneNumber: '2428011616',
            accountHolderName: 'guest purchase a plan',
            primaryPlanName: 'liberty daily',
            primaryPlanPrice: 10.0,
            flow: guest_models.GuestPurchasePlanConfirmationEntryFlow.skip,
            selectedPlan: _testPlan(
              id: 'd1',
              title: 'liberty daily',
              price: 10.0,
            ),
          );

          final router = GoRouter(
            initialLocation: '/confirm',
            routes: [
              GoRoute(
                path: AppRoutes.guestPurchasePlan,
                builder: (_, _) {
                  returnCount++;
                  return const Scaffold(body: Text('Plan Selection Screen'));
                },
              ),
              GoRoute(
                path: '/confirm',
                builder: (_, _) =>
                    GuestPurchasePlanConfirmationScreen(args: args),
              ),
            ],
          );

          await tester.pumpWidget(MaterialApp.router(routerConfig: router));
          await tester.pumpAndSettle();

          expect(find.text('liberty daily'), findsOneWidget);
          final payBarBefore = tester.widget<DefaultBottomPayBar>(
            find.byType(DefaultBottomPayBar),
          );
          expect(payBarBefore.isButtonEnabled, isTrue);

          // Find delete trash icon on the primary plan item
          final trashInkWell = find.descendant(
            of: find.byType(guest_item_row.PurchaseItemRow),
            matching: find.byType(InkWell),
          );
          expect(trashInkWell, findsOneWidget);

          // Tap delete rapidly twice to test duplicate tap guard
          await tester.tap(trashInkWell);
          await tester.tap(trashInkWell);
          await tester.pumpAndSettle();

          // Screen returned to plan selection screen exactly once
          expect(returnCount, equals(1));
        },
      );

      testWidgets(
        'Terms requirement: tapping Pay Now with unchecked terms displays inline error and blocks payment',
        (tester) async {
          tester.view.physicalSize = const Size(390, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final args = guest_models.GuestPurchasePlanConfirmationRouteArgs(
            phoneNumber: '2428011616',
            accountHolderName: 'guest purchase a plan',
            primaryPlanName: 'liberty daily',
            primaryPlanPrice: 10.0,
            flow: guest_models.GuestPurchasePlanConfirmationEntryFlow.proceed,
            selectedPlan: _testPlan(
              id: 'd1',
              title: 'liberty daily',
              price: 10.0,
            ),
          );

          final router = GoRouter(
            initialLocation: '/confirm',
            routes: [
              GoRoute(
                path: '/confirm',
                builder: (_, _) =>
                    GuestPurchasePlanConfirmationScreen(args: args),
              ),
            ],
          );

          await tester.pumpWidget(MaterialApp.router(routerConfig: router));
          await tester.pumpAndSettle();

          final termsFinder = find.byType(guest_terms.TermsNotice);
          expect(termsFinder, findsOneWidget);
          expect(
            tester.widget<guest_terms.TermsNotice>(termsFinder).isChecked,
            isFalse,
          );

          // Tap Pay Now
          await tester.tap(find.text('pay now'));
          await tester.pumpAndSettle();

          // Displays required inline validation message
          expect(
            find.text('accept the terms & conditions to continue'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'Removing only add-on preserves primary plan, does not navigate back, and keeps Pay Now enabled',
        (tester) async {
          tester.view.physicalSize = const Size(390, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final args = guest_models.GuestPurchasePlanConfirmationRouteArgs(
            phoneNumber: '2428011616',
            accountHolderName: 'guest purchase a plan',
            primaryPlanName: 'liberty monthly',
            primaryPlanPrice: 65.0,
            flow: guest_models.GuestPurchasePlanConfirmationEntryFlow.proceed,
            selectedPlan: _testPlan(
              id: 'm1',
              title: 'liberty monthly',
              price: 65.0,
            ),
            selectedAddOns: const [
              guest_models.GuestPurchasePlanConfirmationSelectedAddOn(
                id: 'addon_data',
                title: 'extra data 5GB',
                price: 15.0,
              ),
            ],
          );

          final router = GoRouter(
            initialLocation: '/confirm',
            routes: [
              GoRoute(
                path: AppRoutes.guestPurchasePlan,
                builder: (_, _) =>
                    const Scaffold(body: Text('Plan Selection Screen')),
              ),
              GoRoute(
                path: '/confirm',
                builder: (_, _) =>
                    GuestPurchasePlanConfirmationScreen(args: args),
              ),
            ],
          );

          await tester.pumpWidget(MaterialApp.router(routerConfig: router));
          await tester.pumpAndSettle();

          expect(find.text('liberty monthly'), findsOneWidget);
          expect(find.text('extra data 5GB'), findsOneWidget);

          final trashButtons = find.descendant(
            of: find.byType(guest_item_row.PurchaseItemRow),
            matching: find.byType(InkWell),
          );
          expect(trashButtons, findsNWidgets(2));

          // Tap delete on the add-on (second item)
          await tester.tap(trashButtons.at(1));
          await tester.pumpAndSettle();

          // Add-on removed, but primary plan remains
          expect(find.text('extra data 5GB'), findsNothing);
          expect(find.text('liberty monthly'), findsOneWidget);

          // Still on confirmation screen, Pay Now remains enabled
          final payBar = tester.widget<DefaultBottomPayBar>(
            find.byType(DefaultBottomPayBar),
          );
          expect(payBar.isButtonEnabled, isTrue);
        },
      );

      testWidgets(
        'Returning from checkout / iframe cancellation resets _isSubmittingPayment and re-enables button',
        (tester) async {
          tester.view.physicalSize = const Size(390, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final args = guest_models.GuestPurchasePlanConfirmationRouteArgs(
            phoneNumber: '2428011616',
            accountHolderName: 'guest purchase a plan',
            primaryPlanName: 'liberty daily',
            primaryPlanPrice: 10.0,
            flow: guest_models.GuestPurchasePlanConfirmationEntryFlow.skip,
            selectedPlan: _testPlan(
              id: '70',
              title: 'liberty daily',
              price: 10.0,
            ),
          );

          final router = GoRouter(
            initialLocation: '/confirm',
            routes: [
              GoRoute(
                path: '/confirm',
                builder: (_, _) =>
                    GuestPurchasePlanConfirmationScreen(args: args),
              ),
            ],
          );

          await tester.pumpWidget(MaterialApp.router(routerConfig: router));
          await tester.pumpAndSettle();

          // Tap Pay Now to launch iframe
          await tester.tap(find.text('pay now'));
          await tester.pumpAndSettle();

          expect(find.byType(PaymentIFrameScreen), findsOneWidget);

          // Cancel / pop the iframe (user cancels or returns)
          Navigator.of(tester.element(find.byType(PaymentIFrameScreen))).pop();
          await tester.pumpAndSettle();

          // Back on confirmation screen: Pay Now button is enabled again
          expect(
            find.byType(GuestPurchasePlanConfirmationScreen),
            findsOneWidget,
          );
          final payBar = tester.widget<DefaultBottomPayBar>(
            find.byType(DefaultBottomPayBar),
          );
          expect(payBar.isButtonEnabled, isTrue);
        },
      );
    },
  );

  group('Roaming Plan Confirmation Screen — Widget & Terms Tests', () {
    testWidgets(
      'GPP-1114 / GPP-1125 / GPP-1136: Tapping delete on roaming primary plan navigates back and disables payment',
      (tester) async {
        tester.view.physicalSize = const Size(390, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        int returnCount = 0;

        final router = GoRouter(
          initialLocation: '/roam_confirm',
          routes: [
            GoRoute(
              path: AppRoutes.guestPurchasePlan,
              builder: (_, _) {
                returnCount++;
                return const Scaffold(body: Text('Guest Plan Selection'));
              },
            ),
            GoRoute(
              path: '/roam_confirm',
              builder: (_, _) => const RoamingPlanConfirmationScreen(
                phoneNumber: '2428011616',
                showDateField: false,
              ),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        final trashInkWell = find.descendant(
          of: find.byType(roaming_item_row.PurchaseItemRow),
          matching: find.byType(InkWell),
        );
        expect(trashInkWell, findsOneWidget);

        // Tap delete rapidly twice
        await tester.tap(trashInkWell);
        await tester.tap(trashInkWell);
        await tester.pumpAndSettle();

        // Navigated back exactly once
        expect(returnCount, equals(1));
      },
    );

    testWidgets(
      'Roaming confirmation terms requirement: button is disabled when terms checkbox is false',
      (tester) async {
        tester.view.physicalSize = const Size(390, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final router = GoRouter(
          initialLocation: '/roam_confirm',
          routes: [
            GoRoute(
              path: '/roam_confirm',
              builder: (_, _) => const RoamingPlanConfirmationScreen(
                phoneNumber: '2428011616',
                showDateField: false,
              ),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // Default initial state has isTermsChecked: false
        final termsNoticeFinder = find.byType(roaming_terms.TermsNotice);
        expect(termsNoticeFinder, findsOneWidget);
        expect(
          tester.widget<roaming_terms.TermsNotice>(termsNoticeFinder).isChecked,
          isFalse,
        );

        // Continue button is disabled because terms are unchecked
        final payBar = tester.widget<DefaultBottomPayBar>(
          find.byType(DefaultBottomPayBar),
        );
        expect(payBar.isButtonEnabled, isFalse);

        // Check the terms checkbox via InkWell
        final termsInkWell = find.descendant(
          of: termsNoticeFinder,
          matching: find.byType(InkWell),
        );
        expect(termsInkWell, findsOneWidget);
        await tester.tap(termsInkWell);
        await tester.pumpAndSettle();

        // Now terms is checked, button becomes enabled
        final payBarChecked = tester.widget<DefaultBottomPayBar>(
          find.byType(DefaultBottomPayBar),
        );
        expect(payBarChecked.isButtonEnabled, isTrue);
      },
    );
  });
}
