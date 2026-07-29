import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/models/user_profile_receipt_route_args.dart';

void main() {
  group('UserProfileReceiptRouteArgs receipt copy', () {
    test('uses payment copy and service label for postpaid payments', () {
      const args = UserProfileReceiptRouteArgs(
        amount: 10,
        topUpType: 'postpaid',
      );

      expect(
        args.receiptMessage,
        'It will take a few moments for the payment to appear on the account.',
      );
      expect(args.receiptTypeLabel, 'service');
    });

    test('keeps top-up copy and label for prepaid top-ups', () {
      const args = UserProfileReceiptRouteArgs(amount: 10);

      expect(
        args.receiptMessage,
        'It will take a few moments for the top-up to appear on the account.',
      );
      expect(args.receiptTypeLabel, 'top-up');
    });

    test('preserves an explicitly supplied receipt message', () {
      const args = UserProfileReceiptRouteArgs(
        amount: 10,
        topUpType: 'postpaid',
        message: 'Custom receipt message.',
      );

      expect(args.receiptMessage, 'Custom receipt message.');
      expect(args.receiptTypeLabel, 'service');
    });
  });
}
