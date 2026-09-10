import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'payment_shimmer_widget.dart';

/// Renders a payment HTML document in a full-size WebView.
///
/// Shows [PaymentShimmerWidget] as an overlay while the page is rendering
/// (between HTML load start and `onPageFinished`). The shimmer fades out
/// once the page is ready, giving a seamless loading experience.
///
/// Intercepts any navigation whose URI scheme equals [redirectScheme] and
/// calls [onRedirect] with the parsed URI instead of following it.
class PaymentWebViewWidget extends StatefulWidget {
  const PaymentWebViewWidget({
    super.key,
    required this.htmlContent,
    required this.redirectScheme,
    required this.onRedirect,
    this.onPageFinished,
  });

  final String htmlContent;
  final String redirectScheme;
  final ValueChanged<Uri> onRedirect;
  final VoidCallback? onPageFinished;

  @override
  State<PaymentWebViewWidget> createState() => _PaymentWebViewWidgetState();
}

class _PaymentWebViewWidgetState extends State<PaymentWebViewWidget> {
  late final WebViewController _controller;
  bool _pageLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _pageLoaded = true);
            widget.onPageFinished?.call();
          },
          onNavigationRequest: _handleNavigation,
        ),
      )
      ..loadHtmlString(widget.htmlContent);
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri != null && uri.scheme == widget.redirectScheme) {
      widget.onRedirect(uri);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // WebView loads in the background immediately
        WebViewWidget(controller: _controller),

        // Shimmer fades out once onPageFinished fires
        AnimatedOpacity(
          opacity: _pageLoaded ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 400),
          // Remove from tree after fade so WebView receives touches
          child: _pageLoaded ? const SizedBox.shrink() : const PaymentShimmerWidget(),
        ),
      ],
    );
  }
}
