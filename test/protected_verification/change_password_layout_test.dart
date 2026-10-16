import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/theme/login_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/focused_input_border_wrapper.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/widgets/change_password_prepaid_header_text.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/widgets/change_password_prepaid_password_field.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';

import 'support/change_password_flow_harness.dart';

const instruction =
    'your password should contain letters and/or numbers and be between 8 to 64 characters long.';

void configureAccount(ChangePasswordFlowHarness h, UserType type) {
  h.config.setUserType(type);
  h.accountState = AccountInfoState(
    accountInfo: AccountInfoModel(
      idAcc: 1,
      username: 'subscriber',
      paymentOption: type == UserType.prepaid ? 'PrePay' : 'PostPay',
    ),
  );
}

Finder fieldChild(Finder field, Type type) =>
    find.descendant(of: field, matching: find.byType(type));

void main() {
  setUpAll(loadChangePasswordTestFonts);

  for (final type in UserType.values) {
    for (final width in [320.0, 390.0, 430.0, 800.0]) {
      testWidgets('$type layout follows the reference at $width',
          (tester) async {
        await withChangePasswordFlow(tester, (h) async {
          configureAccount(h, type);
          await h.start(tester, width: width);
          await h.select(tester);
          h.expectLocked();
          await h.verify(tester);

          final fields = find.byType(ChangePasswordPrepaidPasswordField);
          final helper = find.byType(ChangePasswordPrepaidHeaderText);
          final helperRect = tester.getRect(helper);
          final firstRect = tester.getRect(fields.first);
          final secondRect = tester.getRect(fields.last);
          final buttonRect = tester.getRect(find.byType(ElevatedButton));
          final headerRect = tester.getRect(find.byType(DefaultAppBar));

          expect(tester.widget<Text>(find.text(instruction)).textAlign,
              TextAlign.left);
          expect(helperRect.top - headerRect.bottom, 32);
          expect(helperRect.left, firstRect.left);
          expect(helperRect.width, firstRect.width);
          expect(firstRect.top - helperRect.bottom, 20);
          expect(firstRect.height, 54);
          expect(secondRect.height, firstRect.height);
          expect(secondRect.top - firstRect.bottom, 16);
          expect(buttonRect.top - secondRect.bottom, 40);
          expect(buttonRect.left - firstRect.left, 16);
          expect(firstRect.right - buttonRect.right, 16);
          expect(buttonRect.height, 40);
          expect(firstRect.width, width < 476 ? width - 56 : 420);
          expect(firstRect.left, (width - firstRect.width) / 2);
          expect(
            tester
                .widget<StripedScaffold>(find.byType(StripedScaffold))
                .backgroundColor,
            const Color(0xFFF3F4FB),
          );
          for (final field in [fields.first, fields.last]) {
            final fill = tester
                .widgetList<Container>(fieldChild(field, Container))
                .map((container) => container.decoration)
                .whereType<BoxDecoration>()
                .where((decoration) => decoration.color == Colors.white);
            expect(fill, hasLength(1));
            expect(fill.single.borderRadius, BorderRadius.circular(10));
          }
          expect(h.challenges, 1);
          expect(h.verifications, 1);
          expect(h.updates, 0);
          expect(tester.takeException(), isNull);
        });
      });
    }

    testWidgets(
        '$type keeps gradient, focus, visibility and keyboard scrolling',
        (tester) async {
      await withChangePasswordFlow(tester, (h) async {
        configureAccount(h, type);
        await h.start(tester, width: 320);
        await h.select(tester);
        await h.verify(tester);
        await tester.binding.setSurfaceSize(const Size(320, 640));
        tester.view.viewInsets =
            FakeViewPadding(bottom: 260 * tester.view.devicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();

        final first = find.byType(ChangePasswordPrepaidPasswordField).first;
        final input = fieldChild(first, TextField);
        await tester.enterText(input, 'Synthetic123!');
        await tester.pumpAndSettle();
        final focus = tester.widget<TextField>(input).focusNode!;
        final editing =
            tester.widget<EditableText>(fieldChild(first, EditableText));
        final beforeToggle = editing.controller.value;
        final borderFinder = fieldChild(first, FocusedInputBorderWrapper);
        var border = tester.widget<FocusedInputBorderWrapper>(borderFinder);
        expect(border.isFocused, isTrue);
        expect(border.radius, 10);
        expect(border.borderWidth, 1);
        final decoration = tester
            .widget<Container>(
              find
                  .descendant(
                      of: borderFinder, matching: find.byType(Container))
                  .first,
            )
            .decoration! as BoxDecoration;
        expect(decoration.gradient, AuthModuleGradients.focusedInputBorder);
        expect(tester.widget<TextField>(input).obscureText, isTrue);

        await tester.tap(fieldChild(first, InkWell));
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(input).obscureText, isFalse);
        expect(tester.widget<TextField>(input).focusNode, same(focus));
        expect(focus.hasFocus, isTrue);
        expect(editing.controller.value, beforeToggle);
        expect(tester.widget<FocusedInputBorderWrapper>(borderFinder).isFocused,
            isTrue);
        await tester.tap(fieldChild(first, InkWell));
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(input).obscureText, isTrue);

        await tester.enterText(input, 'abc');
        await tester.pumpAndSettle();
        expect(find.text('password does not meet the requirement'),
            findsOneWidget);
        border = tester.widget<FocusedInputBorderWrapper>(borderFinder);
        expect(border.isFocused, isFalse);
        expect(focus.hasFocus, isTrue);
        await tester.ensureVisible(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(tester.getRect(find.byType(ElevatedButton)).bottom,
            lessThanOrEqualTo(640 - 260));
        expect(
            tester
                .widget<ElevatedButton>(find.byType(ElevatedButton))
                .onPressed,
            isNotNull);
        expect(tester.takeException(), isNull);
      });
    });
  }

  testWidgets(
      'button keeps its enabled, loading and single-OTP submit behavior',
      (tester) async {
    await withChangePasswordFlow(tester, (h) async {
      await h.start(tester);
      await h.select(tester);
      await h.verify(tester);
      final button = find.byType(ElevatedButton);
      expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
      final style = tester.widget<ElevatedButton>(button).style!;
      expect(style.backgroundColor!.resolve({}), const Color(0xFF5D5A8B));
      expect(style.backgroundColor!.resolve({WidgetState.disabled}),
          const Color(0xFF5D5A8B).withValues(alpha: 0.35));
      await h.enterPasswords(tester);
      h.pendingUpdate = Completer();
      await h.submit(tester);
      await tester.pump();
      expect(tester.widget<ElevatedButton>(button).onPressed, isNull);
      expect(
          find.descendant(
              of: button, matching: find.byType(CircularProgressIndicator)),
          findsOneWidget);
      expect(h.challenges, 1);
      expect(h.verifications, 1);
      expect(h.updates, 1);
      expect(h.updatePayloads.single, {'NewPassword': 'Synthetic123!'});
      h.pendingUpdate!
          .complete(h.response(Api.updatePasswordUrl, {'Success': true}));
      await tester.pumpAndSettle();
      expect(find.text('Your password has been changed successfully.'),
          findsOneWidget);
      expect(find.text('home destination'), findsOneWidget);
    });
  });
}
