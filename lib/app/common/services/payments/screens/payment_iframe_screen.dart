import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_request.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_success.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Full-screen 3DS payment WebView.
///
/// 1. POSTs [request.url] with [request.body] → extracts `PaymentUrl` from response.
/// 2. Loads that URL in an in-app WebView.
/// 3. When the bank page redirects to `<redirectScheme>://…`, parses the query
///    params and calls [onSuccess]. If the initial POST or WebView fails,
///    calls [onFailure] with a user-readable message.
class PaymentIFrameScreen extends StatefulWidget {
  const PaymentIFrameScreen({
    super.key,
    required this.request,
    required this.appBarBgColor,
    required this.onSuccess,
    required this.onFailure,
    this.onHomeTap,
  });

  final PaymentRequest request;
  final Color appBarBgColor;
  final ValueChanged<PaymentSuccess> onSuccess;
  final ValueChanged<String> onFailure;
  final VoidCallback? onHomeTap;

  @override
  State<PaymentIFrameScreen> createState() => _PaymentIFrameScreenState();
}

class _PaymentIFrameScreenState extends State<PaymentIFrameScreen> {
  WebViewController? _controller;
  bool _fetchingUrl = true;
  bool _webViewLoading = false;
  String? _error;
  // Guards onSuccess/onFailure from firing more than once — some WebView
  // implementations call onNavigationRequest twice for the same redirect.
  bool _resultHandled = false;

  @override
  void initState() {
    super.initState();
    _fetchPaymentUrl();
  }

  Future<void> _fetchPaymentUrl() async {
    setState(() {
      _fetchingUrl = true;
      _error = null;
    });

    try {
      final paymentUrl = await instance<CardPaymentService>().fetch3DSUrl(
        url: widget.request.url,
        body: widget.request.body,
      );

      if (!mounted) return;

      if (paymentUrl == null || paymentUrl.isEmpty) {
        setState(() {
          _error = 'Payment setup failed. Please try again.';
          _fetchingUrl = false;
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
            onWebResourceError: (error) {
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
        ..loadRequest(Uri.parse(paymentUrl));

      if (mounted) {
        setState(() {
          _controller = controller;
          _fetchingUrl = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _fetchingUrl = false;
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
      widget.onSuccess(
        PaymentSuccess(orderId: params['orderId'], queryParams: params),
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
              title: 'payment',
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
    if (_fetchingUrl) {
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
                onPressed: _fetchPaymentUrl,
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
