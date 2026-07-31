import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class AutoRenewAuthPrepaidTheme {
  // ==================== Typography Family ====================
  // Used across auth screen texts and input/button labels.
  static const String fontFamily = AppConstants.defaultFontFamily;

  // ==================== Core Colors ====================
  // Used for scaffold/surfaces and primary actions.
  static const Color primary = Color(0xFF655C9A);
  static const Color scaffoldBackground = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;

  // ==================== Text Colors ====================
  // Used by paragraphs, labels, signatures, hints and field values.
  static const Color textPrimary = Color(0xFF111827);
  static const Color textNeutral = Color(0xFF707070);
  static const Color fieldLabelColor = Color(0xFF1C1C1C);
  static const Color fieldValueColor = Colors.black;
  static const Color buttonTextColor = Color(0xFFF1F1F8);

  // ==================== Input Colors ====================
  // Used by authorization name input background.
  static final Color nameInputFillColor = HexColor.fromHex('#F2F1F9');
  static const Color nameInputBorderColor = Color(0xFFE0E0E0);

  // Used by focused name input gradient border, matching login OTP focus border.
  static const Color focusedInputBorderYellow = Color(0xFFFFC627);
  static const Color focusedInputBorderBlue = Color(0xFF00B3E3);
  static const Color focusedInputBorderPurple = Color(0xFF4B298C);
  static const Color focusedInputBorderPink = Color(0xFFFF9BB1);
  static const Color focusedInputBorderOrange = Color(0xFFFF6C36);

  // ==================== Layout Sizing ====================
  // Used by screen-level spacings and control sizing.
  static const double appBarHeight = 63.0;
  static const double submitButtonHeight = 50.0;
  static const double submitButtonRadius = 100.0;
  static const double submitLoaderSize = 22.0;
  static const double submitLoaderStrokeWidth = 2.0;
  static const double nameInputBorderRadius = 8.0;
  static const double nameInputBorderWidth = 1.0;

  // ==================== Vertical Gaps ====================
  // Used in the body content section order.
  static const double paragraphToConsentHeaderGap = 18.0;
  static const double consentHeaderToParagraphGap = 10.0;
  static const double paragraphToSignatureGap = 18.0;
  static const double signatureToNameLabelGap = 26.0;
  static const double nameLabelToInputGap = 10.0;
  static const double inputToSubmitButtonGap = 24.0;
  static const double submitButtonToBottomGap = 10.0;

  // ==================== Screen Padding ====================
  // Used in the sliver body wrapper.
  static const EdgeInsets bodyPadding = EdgeInsets.fromLTRB(24, 24, 24, 24);
  static const EdgeInsets authBodyCardPadding = EdgeInsets.all(16);

  // ==================== Input Padding ====================
  // Used by the name input content area. Right padding reduced from 14→4.2
  // (−70%) so the long hint "type your name exactly as it appears on your
  // account" isn't clipped early.
  static const EdgeInsets nameInputContentPadding =
      EdgeInsets.fromLTRB(14, 14, 0, 14);

  // ==================== Button Behaviour ====================
  // Used to preserve the intended 0.45 disabled opacity with DefaultButton.
  static const double defaultButtonDisabledOpacity = 0.70;
  static const double desiredDisabledVisualOpacity = 0.45;

  // ==================== Border Radius ====================
  // Used by default submit button shape and auth body card.
  static const BorderRadius submitButtonBorderRadius =
      BorderRadius.all(Radius.circular(submitButtonRadius));
  static const BorderRadius nameInputBorderRadiusShape =
      BorderRadius.all(Radius.circular(nameInputBorderRadius));
  static const BorderRadius authBodyCardRadius =
      BorderRadius.all(Radius.circular(14));

  // ==================== Text Style: App/Section Title ====================
  // Used for title emphasis if needed in auth section headers.
  static TextStyle titleTextStyle() => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  // ==================== Text Style: Paragraph ====================
  // Used for paragraph1, paragraph2 and failure fallback message in auth screen.
  static TextStyle paragraphTextStyle() => const TextStyle(
        color: textNeutral,
        fontSize: 14,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        height: 1.43,
      );

  // ==================== Text Style: Consent Header ====================
  // Used for consent title text in auth screen.
  static TextStyle sectionHeaderTextStyle() => const TextStyle(
        color: textNeutral,
        fontSize: 16,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  // ==================== Text Style: Signature ====================
  // Used for signer name text in auth screen.
  static TextStyle signatureTextStyle() => const TextStyle(
        color: textNeutral,
        fontSize: 14,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        height: 1.43,
      );

  // ==================== Text Style: Field Label ====================
  // Used for "name" label above name input.
  static TextStyle fieldLabelTextStyle() => const TextStyle(
        color: fieldLabelColor,
        fontSize: 14,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        height: 1.43,
      );

  // ==================== Text Style: Input Value ====================
  // Used for typed text inside the authorization name input field.
  static TextStyle nameInputValueTextStyle() => const TextStyle(
        color: fieldValueColor,
        fontSize: 14,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        height: 1.43,
      );

  // ==================== Text Style: Input Hint ====================
  // Used for placeholder text inside the authorization name input field.
  // Hint size trimmed 14→13.0 to fit the long placeholder without ellipsis.
  static TextStyle nameInputHintTextStyle() => const TextStyle(
        color: textNeutral,
        fontSize: 13.0,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        height: 1.43,
      );

  // ==================== Text Style: Submit Button ====================
  // Used for submit button label in auth screen.
  static TextStyle submitButtonTextStyle() => const TextStyle(
        color: buttonTextColor,
        fontSize: 15,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
      );

  // ==================== Input Gradient ====================
  // Used by focused name input border wrapper in auth_name_input.dart.
  static const LinearGradient focusedNameInputBorderGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      focusedInputBorderYellow,
      focusedInputBorderBlue,
      focusedInputBorderPurple,
      focusedInputBorderPink,
      focusedInputBorderOrange,
    ],
  );

  // ==================== Input Decoration ====================
  // Used by AuthNameInput decoration to avoid inline styling.
  static InputDecoration nameInputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: nameInputHintTextStyle(),
      filled: true,
      fillColor: nameInputFillColor,
      contentPadding: nameInputContentPadding,
      border: const OutlineInputBorder(
        borderRadius: nameInputBorderRadiusShape,
        borderSide: BorderSide.none,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: nameInputBorderRadiusShape,
        borderSide: BorderSide.none,
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: nameInputBorderRadiusShape,
        borderSide: BorderSide.none,
      ),
    );
  }

  // ==================== Submit Button Color ====================
  // Used to keep enabled/disabled button visuals aligned with previous UI.
  static Color submitButtonBackgroundColor({required bool isEnabled}) {
    if (isEnabled) {
      return primary;
    }

    return primary.withValues(
      alpha: desiredDisabledVisualOpacity / defaultButtonDisabledOpacity,
    );
  }
}
