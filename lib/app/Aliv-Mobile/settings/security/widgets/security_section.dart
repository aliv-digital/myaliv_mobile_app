import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../theme/security_theme.dart';

class SecuritySection extends StatelessWidget {
  final String htmlContent;

  const SecuritySection({
    super.key,
    required this.htmlContent,
  });

  @override
  Widget build(BuildContext context) {
    return Html(
      data: htmlContent,
      style: {
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontFamily: SecurityTheme.fontFamily,
          fontSize: FontSize(SecurityTheme.body.fontSize ?? 14),
          fontWeight: SecurityTheme.body.fontWeight,
          color: SecurityTheme.textSecondary,
          lineHeight: LineHeight(
            (SecurityTheme.body.height ?? 1.43).toDouble(),
          ),
        ),
        'h1': Style(
          margin: Margins.only(bottom: 12),
          padding: HtmlPaddings.zero,
          fontFamily: SecurityTheme.fontFamily,
          fontSize: FontSize(22),
          fontWeight: FontWeight.w700,
          color: SecurityTheme.textPrimary,
          lineHeight: const LineHeight(1.25),
        ),
        'h2': Style(
          margin: Margins.only(bottom: 12),
          padding: HtmlPaddings.zero,
          fontFamily: SecurityTheme.fontFamily,
          fontSize: FontSize(20),
          fontWeight: FontWeight.w700,
          color: SecurityTheme.textPrimary,
          lineHeight: const LineHeight(1.25),
        ),
        'h3': Style(
          margin: Margins.only(bottom: 10, top: 8),
          padding: HtmlPaddings.zero,
          fontFamily: SecurityTheme.fontFamily,
          fontSize: FontSize(SecurityTheme.title.fontSize ?? 18),
          fontWeight: FontWeight.w700,
          color: SecurityTheme.textPrimary,
          lineHeight: LineHeight(
            (SecurityTheme.title.height ?? 1.25).toDouble(),
          ),
        ),
        'p': Style(
          margin: Margins.only(bottom: 14),
          padding: HtmlPaddings.zero,
          fontFamily: SecurityTheme.fontFamily,
          fontSize: FontSize(SecurityTheme.body.fontSize ?? 14),
          fontWeight: SecurityTheme.body.fontWeight,
          color: SecurityTheme.textSecondary,
          lineHeight: LineHeight(
            (SecurityTheme.body.height ?? 1.43).toDouble(),
          ),
        ),
        'span': Style(
          fontFamily: SecurityTheme.fontFamily,
          fontSize: FontSize(SecurityTheme.body.fontSize ?? 14),
          fontWeight: SecurityTheme.body.fontWeight,
          color: SecurityTheme.textSecondary,
          lineHeight: LineHeight(
            (SecurityTheme.body.height ?? 1.43).toDouble(),
          ),
        ),
        'strong': Style(
          fontWeight: FontWeight.w700,
          color: SecurityTheme.textPrimary,
        ),
      },
    );
  }
}