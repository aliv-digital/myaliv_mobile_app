import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/models/user_profile_receipt_route_args.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/models/user_profile_receipt_variant.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/repository/user_profile_receipt_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/view/user_profile_receipt_screen.dart';

void main() {
  group('UserProfileReceiptRepository phone formatting (Bug 31)', () {
    final repository = UserProfileReceiptRepository();

    test('formats 10-digit phone number as (242)-XXX-XXXX', () {
      final receipt = repository.buildReceipt(
        const UserProfileReceiptRouteArgs(
          phoneNumber: '2428999958',
          amount: 15.0,
          paymentMethod: 'wallet',
          variant: UserProfileReceiptVariant.walletTransfer,
        ),
      );

      expect(receipt.phoneNumber, '(242)-899-9958');
    });

    test('formats 11-digit phone number with leading 1 as (242)-XXX-XXXX', () {
      final receipt = repository.buildReceipt(
        const UserProfileReceiptRouteArgs(
          phoneNumber: '12428999958',
          amount: 25.0,
          paymentMethod: 'wallet',
          variant: UserProfileReceiptVariant.walletTransfer,
        ),
      );

      expect(receipt.phoneNumber, '(242)-899-9958');
    });

    test('reformats existing dashed 10-digit number to (242)-XXX-XXXX', () {
      final receipt = repository.buildReceipt(
        const UserProfileReceiptRouteArgs(
          phoneNumber: '242-899-9958',
          amount: 10.0,
          paymentMethod: 'wallet',
          variant: UserProfileReceiptVariant.walletTransfer,
        ),
      );

      expect(receipt.phoneNumber, '(242)-899-9958');
    });

    test('formats recipientPhone as (242)-XXX-XXXX when provided', () {
      final receipt = repository.buildReceipt(
        const UserProfileReceiptRouteArgs(
          phoneNumber: '2421111111',
          recipientPhone: '2428999958',
          amount: 20.0,
          paymentMethod: 'wallet',
          variant: UserProfileReceiptVariant.walletTransfer,
        ),
      );

      expect(receipt.phoneNumber, '(242)-899-9958');
    });
  });

  group('UserProfileReceiptScreen widget layout (Bug 31)', () {
    testWidgets(
      'renders transferred number formatted as (242)-899-9958 for wallet transfer receipt',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: UserProfileReceiptScreen(
              args: UserProfileReceiptRouteArgs(
                phoneNumber: '2428999958',
                amount: 15.0,
                paymentMethod: 'wallet',
                variant: UserProfileReceiptVariant.walletTransfer,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('transferred number'), findsOneWidget);
        expect(find.text('(242)-899-9958'), findsOneWidget);
        expect(find.text('242-899-9958'), findsNothing);
      },
    );

    testWidgets(
      'renders phone no. formatted as (242)-899-9958 for standard receipt',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: UserProfileReceiptScreen(
              args: UserProfileReceiptRouteArgs(
                phoneNumber: '2428999958',
                amount: 15.0,
                paymentMethod: 'credit card',
                variant: UserProfileReceiptVariant.standard,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('phone no.'), findsOneWidget);
        expect(find.text('(242)-899-9958'), findsOneWidget);
        expect(find.text('242-899-9958'), findsNothing);
      },
    );
  });
}
