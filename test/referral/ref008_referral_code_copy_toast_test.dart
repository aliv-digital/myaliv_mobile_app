import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/referAFriend/referFriend/prepaid/view/success_screen.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

const _copied = 'referral code copied';

void main() {
  late List<String?> clipboardWrites;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    clipboardWrites = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardWrites.add((call.arguments as Map)['text'] as String?);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> pumpScreen(WidgetTester tester, String code) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: rootNavigatorKey,
        home: InvitingSuccessScreen(referralCode: code),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> settleToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  testWidgets('no toast is shown before the code is copied', (tester) async {
    await pumpScreen(tester, 'REF0304EB30E38');

    expect(find.text('REF0304EB30E38'), findsOneWidget);
    expect(find.text(_copied), findsNothing);
    expect(clipboardWrites, isEmpty);
  });

  testWidgets('copy writes the referral code then shows the exact toast', (
    tester,
  ) async {
    await pumpScreen(tester, 'REF0304EB30E38');

    await tester.tap(find.text('copy'));
    await tester.pump();

    expect(clipboardWrites, ['REF0304EB30E38']);
    expect(find.text(_copied), findsOneWidget);
    expect(find.text('Copied'), findsNothing);
    await settleToast(tester);
  });

  testWidgets('missing referral code neither copies nor toasts', (
    tester,
  ) async {
    await pumpScreen(tester, '');

    await tester.tap(find.text('copy'));
    await tester.pump();

    expect(clipboardWrites, isEmpty);
    expect(find.text(_copied), findsNothing);
  });
}
