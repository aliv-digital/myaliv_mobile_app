import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/editEmail/prepaid/view/edit_email_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/editEmail/prepaid/widgets/edit_email_prepaid_info_field.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';

class _Network extends Mock implements NetworkService {}

class _Account extends Mock implements AccountInfoCubit {}

class _Devices extends Mock implements DeviceLimitsCubit {}

void main() {
  group('EditEmailPrepaidScreen.formatDisplayPhone', () {
    test('formats standard 10-digit raw Bahamian number', () {
      expect(
        EditEmailPrepaidScreen.formatDisplayPhone('2428998866'),
        '(242)-899-8866',
      );
    });

    test('formats 10-digit hyphenated number (current repository output)', () {
      expect(
        EditEmailPrepaidScreen.formatDisplayPhone('242-899-8866'),
        '(242)-899-8866',
      );
    });

    test('preserves already formatted (242)-899-8866 without duplication', () {
      expect(
        EditEmailPrepaidScreen.formatDisplayPhone('(242)-899-8866'),
        '(242)-899-8866',
      );
    });

    test('formats (242) 899-8866 with space to (242)-899-8866', () {
      expect(
        EditEmailPrepaidScreen.formatDisplayPhone('(242) 899-8866'),
        '(242)-899-8866',
      );
    });

    test('formats +1 leading country code without duplication', () {
      expect(
        EditEmailPrepaidScreen.formatDisplayPhone('+12428998866'),
        '(242)-899-8866',
      );
      expect(
        EditEmailPrepaidScreen.formatDisplayPhone('+1 (242) 899-8866'),
        '(242)-899-8866',
      );
      expect(
        EditEmailPrepaidScreen.formatDisplayPhone('+1-242-899-8866'),
        '(242)-899-8866',
      );
      expect(
        EditEmailPrepaidScreen.formatDisplayPhone('12428998866'),
        '(242)-899-8866',
      );
    });

    test('formats +242 leading plus without duplication', () {
      expect(
        EditEmailPrepaidScreen.formatDisplayPhone('+242-899-8866'),
        '(242)-899-8866',
      );
      expect(
        EditEmailPrepaidScreen.formatDisplayPhone('+242 899 8866'),
        '(242)-899-8866',
      );
    });

    test('handles whitespace and empty gracefully', () {
      expect(EditEmailPrepaidScreen.formatDisplayPhone(''), '');
      expect(EditEmailPrepaidScreen.formatDisplayPhone('   '), '');
      expect(
        EditEmailPrepaidScreen.formatDisplayPhone('  242-899-8866  '),
        '(242)-899-8866',
      );
    });

    test('falls back to trimmed string for non-10/11 digit input', () {
      expect(EditEmailPrepaidScreen.formatDisplayPhone('123'), '123');
      expect(EditEmailPrepaidScreen.formatDisplayPhone('  N/A  '), 'N/A');
    });
  });

  group('EditEmailPrepaidScreen Widget Tests', () {
    late _Network network;
    late _Account account;
    late _Devices devices;

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
      account = _Account();
      devices = _Devices();

      when(() => account.state).thenReturn(const AccountInfoState());
      when(() => devices.state).thenReturn(
        DeviceLimitsState(
          status: DeviceLimitsStatus.loaded,
          allDeviceLimits: [
            DeviceLimitsModel.fromJson({'TN': '2428998866', 'DeviceID': 123}),
          ],
        ),
      );

      instance.registerSingleton<NetworkService>(network);
      instance.registerSingleton<AccountInfoCubit>(account);
      instance.registerSingleton<DeviceLimitsCubit>(devices);
    });

    tearDown(() async {
      await instance.reset();
    });

    testWidgets(
      'renders phone number as (242)-899-8866 in read-only info field',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: EditEmailPrepaidScreen()),
        );
        await tester.pumpAndSettle();

        // Find the phone number info field
        final phoneFieldFinder = find.ancestor(
          of: find.text('phone number'),
          matching: find.byType(EditEmailPrepaidInfoField),
        );
        expect(phoneFieldFinder, findsOneWidget);

        // Verify the formatted phone number is displayed
        expect(find.text('(242)-899-8866'), findsOneWidget);
        // Verify raw/old format is not displayed
        expect(find.text('242-899-8866'), findsNothing);
        expect(find.text('2428998866'), findsNothing);

        // Verify it is read-only (in an EditEmailPrepaidInfoField, not an editable TextField)
        final phoneFieldWidget = tester.widget<EditEmailPrepaidInfoField>(
          phoneFieldFinder,
        );
        expect(phoneFieldWidget.value, '(242)-899-8866');
        expect(phoneFieldWidget.label, 'phone number');
      },
    );
  });
}
