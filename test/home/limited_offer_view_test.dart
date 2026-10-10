import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/cubit/limited_offer_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/cubit/limited_offer_state.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/models/limited_offer_model.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/repository/limited_offer_repository.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/view/limited_offer_view.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/widgets/animated_timer_box.dart';

class MockLimitedOfferRepository extends Mock
    implements LimitedOfferRepository {}

class MockLimitedOfferModel extends Mock implements LimitedOfferModel {}

LimitedOfferModel _offer({
  String type = 'prepaid',
  String status = 'active',
  bool expired = false,
}) {
  final now = DateTime.now();
  return LimitedOfferModel(
    id: 1,
    title: 'Limited Offer',
    subHeading: 'Offer details',
    link: 'https://example.com/expired-offer',
    type: type,
    addedOn: now.subtract(const Duration(days: 2)),
    expireOn: expired
        ? now.subtract(const Duration(seconds: 1))
        : now.add(const Duration(days: 2)),
    status: status,
  );
}

Future<void> _pumpCard(
  WidgetTester tester,
  LimitedOfferCubit cubit, {
  VoidCallback? onSeeCurrentOffers,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(
          value: cubit,
          child: LimitedOfferView(onSeeCurrentOffers: onSeeCurrentOffers),
        ),
      ),
    ),
  );
}

void main() {
  late MockLimitedOfferRepository repository;
  late LimitedOfferCubit cubit;

  setUp(() {
    repository = MockLimitedOfferRepository();
    cubit = LimitedOfferCubit(repository);
  });

  tearDown(() async {
    if (!cubit.isClosed) {
      await cubit.close();
    }
  });

  for (final width in [320.0, 430.0]) {
    testWidgets('HOME-005 expired card and CTA at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await (FontLoader('CircularPro')
            ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
            ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
          .load();
      when(
        () => repository.fetchActiveOffers(userType: 'prepaid'),
      ).thenAnswer((_) async => [_offer(expired: true)]);
      await cubit.loadOffers();
      var taps = 0;
      await _pumpCard(tester, cubit, onSeeCurrentOffers: () => taps++);

      expect(find.text('this offer has ended'), findsOneWidget);
      expect(find.text('see current offers'), findsOneWidget);
      expect(find.byType(AnimatedTimerBox), findsNothing);
      expect(find.text('Limited Offer'), findsNothing);
      // Tapping the old card must not launch the expired offer link.
      expect(
        tester
            .widget<GestureDetector>(
              find
                  .ancestor(
                    of: find.text('this offer has ended'),
                    matching: find.byType(GestureDetector),
                  )
                  .first,
            )
            .onTap,
        isNull,
      );
      await tester.tap(find.text('see current offers'));
      expect(taps, 1);
      expect(tester.takeException(), isNull);
      await cubit.close();
    });
  }

  testWidgets(
    'active countdown ticks, ends, and survives the existing refresh',
    (tester) async {
      final offer = MockLimitedOfferModel();
      var remaining = const Duration(days: 1, hours: 2, minutes: 3, seconds: 4);
      var expired = false;
      when(() => offer.timeRemaining).thenAnswer((_) => remaining);
      when(() => offer.isExpired).thenAnswer((_) => expired);
      when(() => offer.isActive).thenAnswer((_) => !expired);
      when(() => offer.isPrepaid).thenReturn(true);
      when(() => offer.status).thenReturn('active');
      when(() => offer.title).thenReturn('Limited Offer');
      when(() => offer.subHeading).thenReturn('Offer details');
      when(() => offer.link).thenReturn(null);
      when(
        () => repository.fetchActiveOffers(userType: 'prepaid'),
      ).thenAnswer((_) async => [offer]);
      await cubit.loadOffers();
      await _pumpCard(tester, cubit, onSeeCurrentOffers: () {});

      List<String> values() => tester
          .widgetList<AnimatedTimerBox>(find.byType(AnimatedTimerBox))
          .map((box) => box.value)
          .toList();
      expect(values(), ['01', '02', '03', '04']);
      expect(find.text('this offer has ended'), findsNothing);
      expect(find.text('see current offers'), findsNothing);

      remaining -= const Duration(seconds: 1);
      await tester.pump(const Duration(seconds: 1));
      expect(values(), ['01', '02', '03', '03']);

      remaining = Duration.zero;
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(AnimatedTimerBox), findsNothing);
      expect(find.text('this offer has ended'), findsOneWidget);
      verify(() => repository.fetchActiveOffers(userType: 'prepaid')).called(1);

      // The model's existing date-only expiry still initiates the usual refresh.
      expired = true;
      when(
        () => repository.fetchActiveOffers(userType: 'prepaid'),
      ).thenAnswer((_) async => []);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(cubit.state.status, LimitedOfferStatus.empty);
      expect(find.text('this offer has ended'), findsOneWidget);
      expect(find.text('see current offers'), findsOneWidget);
      expect(find.byType(AnimatedTimerBox), findsNothing);
      verify(() => repository.fetchActiveOffers(userType: 'prepaid')).called(1);

      when(
        () => repository.fetchActiveOffers(userType: 'prepaid'),
      ).thenAnswer((_) async => [_offer()]);
      await cubit.loadOffers(forceRefresh: true);
      await tester.pump();
      expect(find.byType(AnimatedTimerBox), findsNWidgets(4));
      expect(find.text('this offer has ended'), findsNothing);

      cubit.reset();
      await tester.pump();
      await tester.pump();
      expect(find.byType(AnimatedTimerBox), findsNothing);
      expect(find.text('this offer has ended'), findsNothing);
      expect(tester.takeException(), isNull);
      await cubit.close();
    },
  );

  testWidgets('ended card survives API failure and clears on session reset', (
    tester,
  ) async {
    when(
      () => repository.fetchActiveOffers(userType: 'prepaid'),
    ).thenAnswer((_) async => [_offer(expired: true)]);
    await cubit.loadOffers();
    await _pumpCard(tester, cubit, onSeeCurrentOffers: () {});

    when(
      () => repository.fetchActiveOffers(userType: 'prepaid'),
    ).thenThrow(Exception('Offline'));
    await cubit.loadOffers(forceRefresh: true);
    await tester.pump();
    expect(cubit.state.status, LimitedOfferStatus.failure);
    expect(cubit.state.errorMessage, 'Failed to load offers');
    expect(find.text('this offer has ended'), findsOneWidget);
    expect(find.text('see current offers'), findsOneWidget);

    cubit.reset();
    await tester.pump();
    await tester.pump();
    expect(find.text('this offer has ended'), findsNothing);
    expect(find.text('see current offers'), findsNothing);
    await cubit.close();
  });

  for (final type in ['prepaid', 'postpaid']) {
    testWidgets('$type without prepaid Home callback preserves existing UI', (
      tester,
    ) async {
      // Midnight today keeps the model active under its date-only rule.
      final now = DateTime.now();
      final offer = _offer(
        type: type,
      ).copyWith(expireOn: DateTime(now.year, now.month, now.day));
      when(
        () => repository.fetchActiveOffers(userType: type),
      ).thenAnswer((_) async => [offer]);
      await cubit.loadOffers(userType: type);
      await _pumpCard(tester, cubit);
      expect(find.byType(AnimatedTimerBox), findsNWidgets(4));
      expect(find.text('this offer has ended'), findsNothing);
      expect(find.text('see current offers'), findsNothing);
      await cubit.close();
    });
  }

  testWidgets('no offer does not introduce an ended card', (tester) async {
    when(
      () => repository.fetchActiveOffers(userType: 'prepaid'),
    ).thenAnswer((_) async => []);
    await cubit.loadOffers();
    await _pumpCard(tester, cubit, onSeeCurrentOffers: () {});
    expect(find.byType(AnimatedTimerBox), findsNothing);
    expect(find.text('this offer has ended'), findsNothing);
    expect(find.text('see current offers'), findsNothing);
    await cubit.close();
  });

  testWidgets('inactive offer does not introduce an ended card', (
    tester,
  ) async {
    when(
      () => repository.fetchActiveOffers(userType: 'prepaid'),
    ).thenAnswer((_) async => [_offer(status: 'inactive', expired: true)]);
    await cubit.loadOffers();
    await _pumpCard(tester, cubit, onSeeCurrentOffers: () {});
    expect(find.text('this offer has ended'), findsNothing);
    expect(find.text('see current offers'), findsNothing);
    await cubit.close();
  });
}
