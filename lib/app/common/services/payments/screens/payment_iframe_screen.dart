import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_request.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_success.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Full-screen 3DS payment WebView.
///
/// 1. POSTs [request.url] with [request.body] → server returns `{"html": "..."}`.
/// 2. Loads that HTML directly into the WebView (`loadHtmlString`). The HTML
///    contains a self-submitting form that POSTs to the payment gateway.
/// 3. When the gateway redirects back to `<redirectScheme>://…`, the
///    callback URL is intercepted, params parsed, and [onSuccess] is called.
class PaymentIFrameScreen extends StatefulWidget {
  const PaymentIFrameScreen({
    super.key,
    required this.request,
    required this.appBarBgColor,
    required this.onSuccess,
    required this.onFailure,
    this.title = 'payment',
    this.onHomeTap,
  });

  final PaymentRequest request;
  final Color appBarBgColor;
  final ValueChanged<PaymentSuccess> onSuccess;
  final ValueChanged<String> onFailure;
  final String title;
  final VoidCallback? onHomeTap;

  @override
  State<PaymentIFrameScreen> createState() => _PaymentIFrameScreenState();
}

class _PaymentIFrameScreenState extends State<PaymentIFrameScreen> {
  WebViewController? _controller;
  bool _fetchingHtml = true;
  bool _webViewLoading = false;
  String? _error;
  // Prevents onSuccess/onFailure from firing more than once — some WebView
  // implementations call onNavigationRequest twice for the same redirect URL.
  bool _resultHandled = false;

  @override
  void initState() {
    super.initState();
    _fetchAndLoad();
  }

  Future<void> _fetchAndLoad() async {
    setState(() {
      _fetchingHtml = true;
      _error = null;
      _resultHandled = false;
    });

    try {
      final html = await instance<CardPaymentService>().fetch3DSHtml(
        url: widget.request.url,
        body: widget.request.body,
      );

      if (!mounted) return;

      if (html == null || html.isEmpty) {
        setState(() {
          _error = 'Payment setup failed. Please try again.';
          _fetchingHtml = false;
        });
        return;
      }

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: _onNavigationRequest,
            onPageStarted: (_) {
              if (mounted) setState(() => _webViewLoading = true);
            },
            onPageFinished: (_) {
              if (mounted) setState(() => _webViewLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              // Only surface errors for the main frame — sub-resource failures
              // (tracking scripts, etc.) should not abort the payment flow.
              if (mounted && error.isForMainFrame == true) {
                setState(() {
                  _webViewLoading = false;
                  _error = 'Page failed to load. Please try again.';
                  _controller = null;
                });
              }
            },
          ),
        )
        ..loadHtmlString(html);

      if (mounted) {
        setState(() {
          _controller = controller;
          _fetchingHtml = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _fetchingHtml = false;
      });
    }
  }

  NavigationDecision _onNavigationRequest(NavigationRequest req) {
    final scheme = widget.request.redirectScheme;
    if (req.url.startsWith('$scheme://')) {
      if (_resultHandled) return NavigationDecision.prevent;
      _resultHandled = true;
      final uri = Uri.tryParse(req.url);
      final params = uri?.queryParameters ?? const <String, String>{};
      // The redirect URL may use 'orderId', 'OrderID', or 'orderid' depending
      // on the backend endpoint — check all variants case-insensitively.
      final orderIdRaw = params.entries
          .firstWhere(
            (e) => e.key.toLowerCase() == 'orderid',
            orElse: () => const MapEntry('', ''),
          )
          .value;
      widget.onSuccess(
        PaymentSuccess(
          orderId: orderIdRaw.isEmpty ? null : orderIdRaw,
          queryParams: params,
        ),
      );
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            DefaultAppBar(
              title: widget.title,
              backgroundColor: widget.appBarBgColor,
              showHome: widget.onHomeTap != null,
              onBack: () => Navigator.of(context).maybePop(),
              onHomeTap: widget.onHomeTap ?? () {},
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_fetchingHtml) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchAndLoad,
                child: const Text('retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null) return const SizedBox.shrink();

    return Stack(
      children: <Widget>[
        WebViewWidget(controller: _controller!),
        if (_webViewLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.white70,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
