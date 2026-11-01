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
    for (final size in [const Size(320, 700), const Size(430, 932)]) {
      testWidgets('$label opens $url directly at $size', (tester) async {
        await pumpLanding(tester);
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(launched, isEmpty);

        await tester.tap(find.text(label));
        await tester.pumpAndSettle();

        expect(launched, [url]);
        expect(find.byType(BottomSheet), findsNothing);
        expect(find.text(_question), findsNothing);
        expect(find.text('continue'), findsNothing);
        expect(find.text('cancel'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
