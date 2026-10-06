import 'package:flutter/widgets.dart';

final reviewInvoiceRouteObserver = ReviewInvoiceRouteObserver();

/// Tracks the owner of a Review Invoices visit, excluding dialogs and popup routes.
/// The owner supplies cleanup; this observer has no authentication logic.
class ReviewInvoiceRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  PageRoute<dynamic>? _visitRoute;
  VoidCallback? _onVisitEnded;

  void watchVisit(PageRoute<dynamic> route, VoidCallback onVisitEnded) {
    if (identical(_visitRoute, route)) {
      return;
    }
    _endVisit();
    _visitRoute = route;
    _onVisitEnded = onVisitEnded;
  }

  void endVisit(PageRoute<dynamic> route) {
    if (identical(_visitRoute, route)) {
      _endVisit();
    }
  }

  void _endVisit() {
    final onVisitEnded = _onVisitEnded;
    // Release ownership first: delayed cleanup of this route cannot end a
    // newer visit, including one opened above a retained Review Invoices page.
    _visitRoute = null;
    _onVisitEnded = null;
    onVisitEnded?.call();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute<dynamic> && !identical(route, _visitRoute)) {
      _endVisit();
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute<dynamic>) {
      endVisit(route);
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute<dynamic>) {
      endVisit(route);
    }
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute is PageRoute<dynamic>) {
      endVisit(oldRoute);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
