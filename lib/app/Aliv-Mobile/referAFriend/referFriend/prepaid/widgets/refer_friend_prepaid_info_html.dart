import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferFriendPrepaidInfoHtml extends StatelessWidget {
  static const String termsUrl = 'https://www.bealiv.com/terms-of-use/';
  static const Color _textColor = Color(0xFF58677D);
  static const String _fontFamily = 'CircularPro';

  final String htmlContent;
  final bool linkTermsText;
  final EdgeInsetsGeometry padding;

  const ReferFriendPrepaidInfoHtml({
    super.key,
    required this.htmlContent,
    this.linkTermsText = false,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Html(
        data: _prepareHtml(htmlContent),
        onLinkTap: (url, attributes, element) => _openLink(url),
        style: {
          'body': _bodyStyle(margin: Margins.zero),
          'p': _bodyStyle(margin: Margins.only(bottom: 24)),
          'span': _bodyStyle(margin: Margins.zero),
          'strong': Style(fontWeight: FontWeight.w700, color: _textColor),
          'a': Style(
            fontFamily: _fontFamily,
            fontSize: FontSize(14),
            fontWeight: FontWeight.w700,
            color: _textColor,
            textDecoration: TextDecoration.none,
          ),
        },
      ),
    );
  }

  Style _bodyStyle({required Margins margin}) {
    return Style(
      margin: margin,
      padding: HtmlPaddings.zero,
      fontFamily: _fontFamily,
      fontSize: FontSize(14),
      fontWeight: FontWeight.w500,
      color: _textColor,
      textAlign: TextAlign.center,
      lineHeight: const LineHeight(1.35),
    );
  }

  String _prepareHtml(String rawHtml) {
    var html = rawHtml
        .replaceAll('<p></p>', '')
        .replaceAll('<p> </p>', '')
        .replaceAll('<p>&nbsp;</p>', '')
        .trim();

    if (linkTermsText && !html.toLowerCase().contains('<a ')) {
      html = _linkTermsText(html);
    }

    return html;
  }

  String _linkTermsText(String html) {
    const linkedTerms = '<a href="$termsUrl">Terms &amp; Conditions</a>';

    if (html.contains('Terms &amp; Conditions')) {
      return html.replaceFirst('Terms &amp; Conditions', linkedTerms);
    }

    return html.replaceFirst('Terms & Conditions', linkedTerms);
  }

  void _openLink(String? url) {
    final uri = Uri.tryParse(url ?? '');

    if (uri == null) {
      return;
    }

    unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
  }
}
