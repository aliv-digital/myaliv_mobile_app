import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import 'review_invoice_challenge_cubit.dart';
import 'review_invoice_otp_route_args.dart';
import 'review_invoice_route_observer.dart';
import 'review_invoice_verification_session.dart';

class ReviewInvoiceVerificationGateScreen extends StatefulWidget {
  const ReviewInvoiceVerificationGateScreen({super.key});

  @override
  State<ReviewInvoiceVerificationGateScreen> createState() =>
      _ReviewInvoiceVerificationGateScreenState();
}

class _ReviewInvoiceVerificationGateScreenState
    extends State<ReviewInvoiceVerificationGateScreen>
    with RouteAware {
  late final ReviewInvoiceVerificationSession _session;
  late final int _generation;
  late final ReviewInvoiceChallengeCubit _cubit;
  PageRoute<dynamic>? _route;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _session = instance<ReviewInvoiceVerificationSession>();
    _generation = _session.generation;
    _cubit = instance<ReviewInvoiceChallengeCubit>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic> && !identical(route, _route)) {
      reviewInvoiceRouteObserver.unsubscribe(this);
      _route = route;
      reviewInvoiceRouteObserver.subscribe(this, route);
    }
    _scheduleBegin();
  }

  @override
  void didPopNext() => _scheduleBegin();

  void _scheduleBegin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _route?.isCurrent != true ||
          _session.generation != _generation) {
        return;
      }
      // BlocListener is attached before this post-frame request. A result
      // received under an outside page is consumed only on return.
      if (_cubit.state.status == ReviewInvoiceChallengeStatus.initial) {
        _cubit.requestChallenge();
      } else {
        _handleState(_cubit.state);
      }
    });
  }

  void _handleState(ReviewInvoiceChallengeState state) {
    if (!mounted ||
        _navigating ||
        _route?.isCurrent != true ||
        _session.generation != _generation) {
      return;
    }
    final challenge = state.challenge;
    if (state.status == ReviewInvoiceChallengeStatus.success &&
        challenge != null) {
      _navigating = true;
      context.pushReplacement(
        AppRoutes.reviewInvoiceOtp,
        extra: ReviewInvoiceOtpRouteArgs(
          mfaToken: challenge.mfaToken,
          apiPhoneNumber: challenge.apiPhoneNumber,
        ),
      );
    } else if (state.status == ReviewInvoiceChallengeStatus.failure) {
      _navigating = true;
      AppToast.show(
        message:
            state.errorMessage ??
            'Unable to send a verification code. Please try again.',
        type: ToastType.error,
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  void dispose() {
    reviewInvoiceRouteObserver.unsubscribe(this);
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const loader = StripedScaffold(
      body: SafeArea(child: Center(child: CircularProgressIndicator())),
    );
    return BlocListener<
      ReviewInvoiceChallengeCubit,
      ReviewInvoiceChallengeState
    >(bloc: _cubit, listener: (_, state) => _handleState(state), child: loader);
  }
}
