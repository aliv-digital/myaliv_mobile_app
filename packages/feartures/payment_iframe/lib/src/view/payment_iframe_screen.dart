import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/payment_iframe_cubit.dart';
import '../cubit/payment_iframe_state.dart';
import '../models/payment_request.dart';
import '../models/payment_result.dart';
import '../widgets/payment_shimmer_widget.dart';
import '../widgets/payment_webview_widget.dart';

/// Drop-in screen for the iframe payment flow.
///
/// Usage:
/// ```dart
/// PaymentIFrameScreen(
///   title: 'Complete Top-up',
///   request: PaymentRequest(
///     endpoint: Api.guestTopupUrl,
///     body: {'Amount': 25.0, 'PhoneNumber': '2428999726', ...},
///     redirectScheme: 'myaliv',
///   ),
///   onSuccess: (result) => context.go(AppRoutes.guestTopUpReceipt),
///   onFailure: (error) => showErrorSnack(context, error),
/// )
/// ```
class PaymentIFrameScreen extends StatelessWidget {
  const PaymentIFrameScreen({
    super.key,
    required this.request,
    required this.onSuccess,
    required this.onFailure,
    this.appBar,
    this.title = 'Payment',
    this.loadingIndicator,
  });

  final PaymentRequest request;
  final ValueChanged<PaymentSuccess> onSuccess;
  final ValueChanged<String> onFailure;

  /// Provide the host app's branded AppBar so the payment screen stays
  /// visually consistent with the rest of the navigation stack.
  /// Falls back to a plain [AppBar(title: Text(title))] when omitted.
  final PreferredSizeWidget? appBar;

  /// Used only when [appBar] is null.
  final String title;

  /// Override the default [PaymentShimmerWidget] shown during the API call
  /// and while the WebView page is rendering.
  final Widget? loadingIndicator;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Factory registration — fresh Cubit per screen instance.
      create: (_) => instance<PaymentIFrameCubit>()..initiate(request),
      child: _PaymentIFrameView(
        appBar: appBar,
        title: title,
        loadingIndicator: loadingIndicator,
        redirectScheme: request.redirectScheme,
        onSuccess: onSuccess,
        onFailure: onFailure,
      ),
    );
  }
}

class _PaymentIFrameView extends StatelessWidget {
  const _PaymentIFrameView({
    required this.title,
    required this.redirectScheme,
    required this.onSuccess,
    required this.onFailure,
    this.appBar,
    this.loadingIndicator,
  });

  final PreferredSizeWidget? appBar;
  final String title;
  final String redirectScheme;
  final ValueChanged<PaymentSuccess> onSuccess;
  final ValueChanged<String> onFailure;
  final Widget? loadingIndicator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? AppBar(title: Text(title)),
      body: BlocListener<PaymentIFrameCubit, PaymentIFrameState>(
        listener: (context, state) {
          if (state.isSuccess && state.result is PaymentSuccess) {
            onSuccess(state.result as PaymentSuccess);
          } else if (state.isFailure) {
            onFailure(state.errorMessage ?? 'Payment failed.');
          }
        },
        child: BlocBuilder<PaymentIFrameCubit, PaymentIFrameState>(
          builder: (context, state) {
            if (state.isLoading || state.isVerifying) {
              return loadingIndicator ?? const PaymentShimmerWidget();
            }

            if (state.isReady && state.htmlContent != null) {
              return PaymentWebViewWidget(
                htmlContent: state.htmlContent!,
                redirectScheme: redirectScheme,
                onRedirect: (uri) {
                  context.read<PaymentIFrameCubit>().onRedirectReceived(uri);
                },
              );
            }

            if (state.isFailure) {
              return _ErrorView(
                message: state.errorMessage ?? 'Something went wrong.',
                onRetry: () => context.read<PaymentIFrameCubit>().reset(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
