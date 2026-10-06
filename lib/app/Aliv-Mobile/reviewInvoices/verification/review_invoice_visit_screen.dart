import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

import '../reviewInvoice/postpaid/view/review_invoice_postpaid_screen.dart';
import 'review_invoice_route_observer.dart';
import 'review_invoice_verification_gate_screen.dart';
import 'review_invoice_verification_session.dart';

/// Gates construction of the existing invoice screen without changing it.
class ReviewInvoiceVisitScreen extends StatefulWidget {
  const ReviewInvoiceVisitScreen({super.key});

  @override
  State<ReviewInvoiceVisitScreen> createState() =>
      _ReviewInvoiceVisitScreenState();
}

class _ReviewInvoiceVisitScreenState extends State<ReviewInvoiceVisitScreen>
    with RouteAware {
  late final ReviewInvoiceVerificationSession _session;
  PageRoute<dynamic>? _route;
  bool _visitEnded = false;

  @override
  void initState() {
    super.initState();
    _session = instance<ReviewInvoiceVerificationSession>();
    _session.addListener(_onSessionChanged);
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
    if (!_visitEnded && _session.isVerified && _route?.isCurrent == true) {
      reviewInvoiceRouteObserver.watchVisit(_route!, _endVisit);
    }
  }

  void _onSessionChanged() {
    if (!_session.isVerified) {
      _visitEnded = true;
    }
    _refreshAfterNavigation();
  }

  void _endVisit() {
    _visitEnded = true;
    _session.reset();
  }

  @override
  void didPopNext() => _refreshAfterNavigation();

  void _refreshAfterNavigation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    reviewInvoiceRouteObserver.unsubscribe(this);
    final route = _route;
    if (route != null) {
      reviewInvoiceRouteObserver.endVisit(route);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_visitEnded || !_session.isVerified) {
      return const ReviewInvoiceVerificationGateScreen();
    }
    return const ReviewInvoicePostpaidScreen();
  }
}
