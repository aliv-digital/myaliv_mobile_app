import 'package:flutter/widgets.dart';

/// Route notifications only: authorization is no longer visit-owned.
final reviewInvoiceRouteObserver = ReviewInvoiceRouteObserver();

class ReviewInvoiceRouteObserver extends RouteObserver<PageRoute<dynamic>> {}
