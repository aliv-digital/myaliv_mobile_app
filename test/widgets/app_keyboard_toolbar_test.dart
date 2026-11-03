import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/resources/widgets/app_keyboard_toolbar.dart';

void main() {
  testWidgets(
    'AppKeyboardToolbar shows Next on intermediate field and Done on final field',
    (tester) async {
      final node1 = FocusNode(debugLabel: 'field1');
      final node2 = FocusNode(debugLabel: 'field2');
      final node3 = FocusNode(debugLabel: 'field3');
      bool doneCalled = false;

      addTearDown(() {
        tester.view.resetViewInsets();
        node1.dispose();
        node2.dispose();
        node3.dispose();
      });

      tester.view.viewInsets = const FakeViewPadding(bottom: 250);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppKeyboardToolbar(
              focusNodes: [node1, node2, node3],
              onDone: () => doneCalled = true,
              child: Column(
                children: [
                  TextField(focusNode: node1),
                  TextField(focusNode: node2),
                  TextField(focusNode: node3),
                ],
              ),
            ),
          ),
        ),
      );

      // No field has focus yet -> toolbar button should not appear
      expect(find.text('Next'), findsNothing);
      expect(find.text('Done'), findsNothing);

      // Focus field 1 -> toolbar shows 'Next'
      node1.requestFocus();
      await tester.pump();
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Done'), findsNothing);

      // Tap 'Next' -> moves focus to field 2
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(node1.hasFocus, isFalse);
      expect(node2.hasFocus, isTrue);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Done'), findsNothing);

      // Tap 'Next' again -> moves focus to field 3 (final field)
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(node2.hasFocus, isFalse);
      expect(node3.hasFocus, isTrue);
      expect(find.text('Next'), findsNothing);
      expect(find.text('Done'), findsOneWidget);

      // Tap 'Done' -> unfocuses field 3 and invokes onDone
      await tester.tap(find.text('Done'));
      await tester.pump();
      expect(node3.hasFocus, isFalse);
      expect(doneCalled, isTrue);
    },
  );

  testWidgets('AppKeyboardToolbar hides when keyboard viewInsets bottom is 0', (
    tester,
  ) async {
    final node = FocusNode(debugLabel: 'field');
    addTearDown(() {
      tester.view.resetViewInsets();
      node.dispose();
    });

    tester.view.viewInsets = const FakeViewPadding(bottom: 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppKeyboardToolbar(
            focusNodes: [node],
            child: TextField(focusNode: node),
          ),
        ),
      ),
    );

    node.requestFocus();
    await tester.pump();

    // Even though node has focus, keyboardInset is 0 so toolbar should not show
    expect(find.text('Done'), findsNothing);
  });

  testWidgets(
    'AppKeyboardToolbar does not dispose parent focus nodes on unmount',
    (tester) async {
      final node1 = FocusNode(debugLabel: 'field1');
      final node2 = FocusNode(debugLabel: 'field2');
      addTearDown(() {
        node1.dispose();
        node2.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppKeyboardToolbar(
              focusNodes: [node1, node2],
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      );

      // Unmount toolbar
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

      // Verify nodes are still valid and not disposed
      void dummyListener() {}
      expect(() => node1.addListener(dummyListener), returnsNormally);
      expect(() => node2.addListener(dummyListener), returnsNormally);
      node1.removeListener(dummyListener);
      node2.removeListener(dummyListener);
    },
  );

  testWidgets(
    'AppKeyboardToolbar appears when software keyboard opens after focus',
    (tester) async {
      tester.view.viewInsets = FakeViewPadding.zero;
      addTearDown(() => tester.view.resetViewInsets());

      final node1 = FocusNode(debugLabel: 'field1');
      final node2 = FocusNode(debugLabel: 'field2');
      addTearDown(() {
        node1.dispose();
        node2.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppKeyboardToolbar(
              focusNodes: [node1, node2],
              child: Column(
                children: [
                  TextField(focusNode: node1),
                  TextField(focusNode: node2),
                ],
              ),
            ),
          ),
        ),
      );

      // Focus field 1 before keyboard opens
      node1.requestFocus();
      await tester.pump();

      // Keyboard not yet open -> toolbar hidden
      expect(find.text('Next'), findsNothing);

      // Keyboard opens (OS metrics change)
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      await tester.pump();

      // Toolbar is now displayed with Next
      expect(find.text('Next'), findsOneWidget);
    },
  );

  testWidgets(
    'AppKeyboardToolbar hides toolbar on last field when showDoneButton is false',
    (tester) async {
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      addTearDown(() => tester.view.resetViewInsets());

      final node1 = FocusNode(debugLabel: 'field1');
      final node2 = FocusNode(debugLabel: 'field2');
      addTearDown(() {
        node1.dispose();
        node2.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppKeyboardToolbar(
              focusNodes: [node1, node2],
              showDoneButton: false,
              child: Column(
                children: [
                  TextField(focusNode: node1),
                  TextField(focusNode: node2),
                ],
              ),
            ),
          ),
        ),
      );

      // Focus field 1 -> shows Next
      node1.requestFocus();
      await tester.pumpAndSettle();
      expect(find.text('Next'), findsOneWidget);

      // Focus field 2 (last field) -> toolbar hides (no Done button)
      node2.requestFocus();
      await tester.pumpAndSettle();
      expect(find.text('Next'), findsNothing);
      expect(find.text('Done'), findsNothing);
    },
  );
}
