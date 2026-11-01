import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_bottom_stripes.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/base_login_otp_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/view/login_otp_screen.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

class _Repository extends Mock implements BaseLoginOtpRepository {}

class _Analytics extends Fake implements AnalyticsService {
  @override
  Future<void> logLogin({
    required String userId,
    String method = AnalyticsLoginMethod.otp,
  }) async {}

  @override
  Future<void> logLoginFailure({
    required String method,
    required String failureReason,
  }) async {}

  @override
  Future<void> logOtpRequested({String otpChannel = AnalyticsOtpChannel.sms}) async {}

  @override
  Future<void> logOtpVerified({String otpChannel = AnalyticsOtpChannel.sms}) async {}

  @override
  Future<void> logOtpFailed({
    required String failureReason,
    String otpChannel = AnalyticsOtpChannel.sms,
  }) async {}

  @override
  Future<void> logPasswordResetStarted() async {}

  @override
  Future<void> logPasswordResetCompleted() async {}

  @override
  Future<void> logPasswordResetFailed({required String failureReason}) async {}

  @override
  Future<void> setLoggedIn() async {}
}

class _Connection extends Fake implements InternetConnection {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppUiConfigCubit config;
  late LoginOtpBloc bloc;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    config = AppUiConfigCubit();
    bloc = LoginOtpBloc(
      repository: _Repository(),
      appUiConfigCubit: config,
      internetConnection: _Connection(),
      analyticsService: _Analytics(),
    );
  });

  tearDown(() async {
    await bloc.close();
    await config.close();
  });

  Widget screen() => Builder(
    builder: (context) {
      final provider =
          const LoginOtpScreen().build(context) as BlocProvider<LoginOtpBloc>;
      return BlocProvider.value(value: bloc, child: provider.child!);
    },
  );

  Future<void> open(
    WidgetTester tester, {
    required Size size,
    double topInset = 24,
    double bottomInset = 0,
    double textScale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    tester.view.padding = FakeViewPadding(top: topInset, bottom: bottomInset);
    tester.view.viewPadding = FakeViewPadding(
      top: topInset,
      bottom: bottomInset,
    );
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: screen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectFooterAboveStripes(WidgetTester tester) {
    final footer = find.text('change phone number');
    final footerRect = tester.getRect(footer);
    final stripeRect = tester.getRect(find.byType(BottomStripes));
    expect(footer.hitTestable(), findsOneWidget);
    expect(footerRect.top, greaterThanOrEqualTo(0));
    expect(footerRect.bottom, lessThan(stripeRect.top));
    expect(footerRect.left, greaterThanOrEqualTo(0));
    expect(footerRect.right, lessThanOrEqualTo(stripeRect.right));
    expect(tester.takeException(), isNull);
  }

  const sizes = <String, Size>{
    'small phone': Size(320, 568),
    'short Android': Size(360, 640),
    'iPhone reference': Size(366, 792),
    'Android reference': Size(360, 800),
    'large phone': Size(430, 932),
    'landscape': Size(640, 320),
  };

  for (final entry in sizes.entries) {
    testWidgets('footer stays above stripes on ${entry.key}', (tester) async {
      await open(
        tester,
        size: entry.value,
        topInset: entry.key == 'iPhone reference' ? 59 : 24,
        bottomInset: entry.key == 'iPhone reference' ? 34 : 16,
      );
      expectFooterAboveStripes(tester);
      final initialRect = tester.getRect(find.text('change phone number'));
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -1200));
      await tester.pumpAndSettle();
      expectFooterAboveStripes(tester);
      expect(tester.getRect(find.text('change phone number')), initialRect);
      expect(find.text('resend code').hitTestable(), findsOneWidget);
    });
  }

  for (final scale in [1.3, 2.0]) {
    testWidgets('footer stays visible with text scale $scale', (tester) async {
      await open(
        tester,
        size: Size(scale == 2 ? 600 : 390, 700),
        bottomInset: 34,
        textScale: scale,
      );
      expectFooterAboveStripes(tester);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -1200));
      await tester.pumpAndSettle();
      expectFooterAboveStripes(tester);
      expect(find.text('resend code').hitTestable(), findsOneWidget);
    });
  }

  testWidgets('keyboard keeps footer visible and form scrollable', (
    tester,
  ) async {
    await open(tester, size: const Size(320, 568), bottomInset: 16);
    final firstCodeField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.autofillHints?.contains(AutofillHints.oneTimeCode) == true,
    );
    await tester.scrollUntilVisible(
      firstCodeField,
      150,
      scrollable: find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(firstCodeField);
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    tester.view.padding = const FakeViewPadding(top: 24);
    await tester.pumpAndSettle();
    final footer = find.text('change phone number');
    expect(find.byType(BottomStripes), findsNothing);
    expect(footer.hitTestable(), findsOneWidget);
    expect(tester.getRect(footer).bottom, lessThan(568 - 250));
    await tester.ensureVisible(find.text('resend code'));
    await tester.pumpAndSettle();
    expect(find.text('resend code').hitTestable(), findsOneWidget);
    expect(footer.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.testTextInput.hide();
    tester.view.viewInsets = const FakeViewPadding();
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 16);
    await tester.pumpAndSettle();
    expectFooterAboveStripes(tester);
  });

  testWidgets(
    'visible footer returns to the previous screen on a small phone',
    (tester) async {
      await open(tester, size: const Size(320, 568));
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(MaterialPageRoute<void>(builder: (_) => screen()));
      await tester.pumpAndSettle();
      expect(navigator.canPop(), isTrue);
      expectFooterAboveStripes(tester);
      await tester.tap(find.text('change phone number'));
      await tester.pumpAndSettle();
      expect(navigator.canPop(), isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
