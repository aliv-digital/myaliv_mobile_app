import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revLanding/prepaid/view/rev_landing_prepaid_screen.dart';

const _channel = MethodChannel('plugins.flutter.io/url_launcher');
const _question = "you're leaving myALIV to pay on rev.bs";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final launched = <String>[];

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    launched.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          if (call.method == 'launch') {
            launched.add((call.arguments as Map)['url'] as String);
            return true;
          }
          if (call.method == 'canLaunch') return true;
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  Future<void> pumpLanding(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: RevLandingPrepaidScreen()));
    await tester.pumpAndSettle();
  }

  for (final (label, url) in [
    ('Pay as a Guest', 'https://my.rev.bs/guest/payment'),
    ('Log in to Pay', 'https://my.rev.bs/'),
  ]) {
    testWidgets('REV-003 "$label" asks before leaving myALIV', (tester) async {
      await pumpLanding(tester);
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.text(_question), findsOneWidget);
      expect(find.text('continue'), findsOneWidget);
      expect(find.text('cancel'), findsOneWidget);
      expect(launched, isEmpty);
    });

    testWidgets('REV-003 "$label" continue opens the existing REV URL', (
      tester,
    ) async {
      await pumpLanding(tester);
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      await tester.tap(find.text('continue'));
      await tester.pumpAndSettle();
      expect(find.text(_question), findsNothing);
      expect(launched, [url]);
    });

    testWidgets('REV-003 "$label" cancel opens nothing', (tester) async {
      await pumpLanding(tester);
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      await tester.tap(find.text('cancel'));
      await tester.pumpAndSettle();
      expect(find.text(_question), findsNothing);
      expect(find.text(label), findsOneWidget);
      expect(launched, isEmpty);
    });
  }
}
