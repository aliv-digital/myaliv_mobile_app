import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/models/transaction_model.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/repository/services/transactions_api_client.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/repository/transactions_repository.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/widgets/transaction_tile_new.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class _MockNetworkService extends Mock implements NetworkService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  test(
    'API and repository preserve timestamps and sort newest first',
    () async {
      final network = _MockNetworkService();
      when(
        () => network.request<String>(any(), method: HttpMethod.get),
      ).thenAnswer(
        (_) async => Response<String>(
          requestOptions: RequestOptions(path: Api.transactions),
          statusCode: 200,
          data: jsonEncode([
            {'Date': '2026-10-21T05:57:36Z'},
            {'Date': '2026-10-21T17:57:42Z'},
          ]),
        ),
      );
      final repository = TransactionsRepository(
        apiClient: TransactionsApiClient(networkService: network),
      );
      final start = DateTime.utc(2026, 10);
      final end = DateTime.utc(2026, 10, 31, 23, 59, 59);

      final transactions = await repository.fetchTransactions(
        startDate: start,
        endDate: end,
        accountId: 123,
      );

      expect(transactions.map((transaction) => transaction.date), [
        DateTime.utc(2026, 10, 21, 17, 57, 42),
        DateTime.utc(2026, 10, 21, 5, 57, 36),
      ]);
      final url =
          verify(
                () => network.request<String>(
                  captureAny(),
                  method: HttpMethod.get,
                ),
              ).captured.single
              as String;
      expect(Uri.parse(url).path, Uri.parse(Api.transactions).path);
      expect(Uri.parse(url).queryParameters, {
        'startDate': start.toIso8601String(),
        'endDate': end.toIso8601String(),
        'AccountId': '123',
      });
    },
  );

  for (final (hour, expectedTime) in [
    (0, '12:57 AM'),
    (5, '05:57 AM'),
    (12, '12:57 PM'),
    (17, '05:57 PM'),
  ]) {
    testWidgets('shows the API timestamp in device time as $expectedTime', (
      tester,
    ) async {
      final transaction = TransactionModel.fromJson({
        'Date': DateTime(2024, 9, 2, hour, 57).toUtc().toIso8601String(),
        'Type': 'Top-Up',
        'Channel': 'Website',
        'Amount': 30,
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [TransactionTileNew(transaction: transaction)],
            ),
          ),
        ),
      );

      expect(find.text('02 Sep 2024, $expectedTime'), findsOneWidget);
      expect(find.text('Channel: Website'), findsOneWidget);
      expect(find.text(r'+$30.00'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [320.0, 390.0, 430.0, 600.0]) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets('fits width $width with text scale $textScale', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(Size(width, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final transaction = TransactionModel(
          date: DateTime(2024, 9, 2, 17, 57),
          type: 'travel30 7-day',
          plan: '',
          amount: -30,
          channel: 'SelfCare',
          subId: 1,
        );

        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
            home: Scaffold(
              body: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [TransactionTileNew(transaction: transaction)],
              ),
            ),
          ),
        );

        expect(find.text('02 Sep 2024, 05:57 PM'), findsOneWidget);
        expect(find.text('Channel: SelfCare'), findsOneWidget);
        expect(find.text('-\$30.00'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final width in [390.0, 430.0]) {
    testWidgets('matches Figma text rows at width $width', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final transactions = [
        for (final (title, channel) in [
          ('travel30 7-day', 'Website'),
          ('payment', 'SelfCare'),
        ])
          TransactionModel(
            date: DateTime(2026, 10, 21, 15, 42),
            type: title,
            plan: '',
            amount: -30,
            channel: channel,
            subId: 1,
          ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                for (final transaction in transactions)
                  TransactionTileNew(transaction: transaction),
              ],
            ),
          ),
        ),
      );

      for (final transaction in transactions) {
        final tile = find.ancestor(
          of: find.text(transaction.displayTitle),
          matching: find.byType(TransactionTileNew),
        );
        Finder text(String value) =>
            find.descendant(of: tile, matching: find.text(value));
        final title = text(transaction.displayTitle);
        final amount = text('-\$30.00');
        final channel = text('Channel: ${transaction.channel}');
        final date = text('21 Oct 2026, 03:42 PM');

        expect(tester.getRect(title).left, 100);
        expect(tester.getRect(channel).left, 100);
        expect(tester.getRect(amount).right, width - 40);
        expect(tester.getRect(date).right, width - 40);
        expect(tester.getRect(title).top, tester.getRect(amount).top);
        expect(tester.getRect(channel).top, tester.getRect(date).top);
        expect(tester.getRect(channel).top - tester.getRect(title).bottom, 4);
        expect(tester.getSize(tile).height, 80);

        for (final finder in [title, amount, channel, date]) {
          final paragraph = tester.renderObject<RenderParagraph>(
            find.descendant(of: finder, matching: find.byType(RichText)),
          );
          final boxes = paragraph.getBoxesForSelection(
            TextSelection(
              baseOffset: 0,
              extentOffset: paragraph.text.toPlainText().length,
            ),
          );
          expect(boxes.map((box) => box.top).toSet(), hasLength(1));
          expect(paragraph.didExceedMaxLines, isFalse);
        }
        final channelSpan = tester.widget<Text>(channel).textSpan! as TextSpan;
        expect(channelSpan.style?.fontSize, 12);
        expect(channelSpan.style?.letterSpacing, -0.3);
        expect(channelSpan.style?.color, const Color(0xFF707070));
        expect(
          (channelSpan.children!.single as TextSpan).style?.color,
          Colors.black,
        );
        expect(tester.widget<Text>(amount).style?.fontSize, 14);
        expect(tester.widget<Text>(date).style?.fontSize, 12);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
