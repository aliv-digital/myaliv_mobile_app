import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/models/transaction_model.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/widgets/transaction_tile_new.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/call_logs_screen.dart';

void main() {
  group('Bug 35 - History / Call Logs Design Tests', () {
    testWidgets('TabBar has purple selected color and grey unselected color', (
      tester,
    ) async {
      final controller = TabController(length: 2, vsync: const TestVSync());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: CallLogsScreen.buildTabBarForTesting(controller),
              ),
            ),
            body: TabBarView(
              controller: controller,
              children: const [
                Text('Transactions View'),
                Text('Call Logs View'),
              ],
            ),
          ),
        ),
      );

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.labelColor, const Color(0xFF645D9C));
      expect(tabBar.unselectedLabelColor, const Color(0xFF707070));
    });

    testWidgets(
      r'TransactionTileNew formats credit amount with teal color and +$ prefix',
      (tester) async {
        final creditTransaction = TransactionModel(
          date: DateTime(2024, 9, 2),
          type: 'topup',
          plan: '',
          amount: 15.00,
          channel: 'SelfCare',
          subId: 1,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TransactionTileNew(transaction: creditTransaction),
            ),
          ),
        );

        final amountText = tester.widget<Text>(find.text(r'+$15.00'));
        expect(amountText.style?.color, const Color(0xFF00C4B3));
      },
    );

    testWidgets(
      r'TransactionTileNew formats debit amount with orange color and -$ prefix',
      (tester) async {
        final debitTransaction = TransactionModel(
          date: DateTime(2024, 9, 2),
          type: 'send money',
          plan: '',
          amount: -15.00,
          channel: 'SelfCare',
          subId: 1,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TransactionTileNew(transaction: debitTransaction),
            ),
          ),
        );

        final amountText = tester.widget<Text>(find.text('-\$15.00'));
        expect(amountText.style?.color, const Color(0xFFE94408));
      },
    );
  });
}
