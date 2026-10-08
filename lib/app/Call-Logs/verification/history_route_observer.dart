import 'package:flutter/widgets.dart';

/// Route notifications only: authorization is no longer visit-owned.
final historyRouteObserver = HistoryRouteObserver();

class HistoryRouteObserver extends RouteObserver<PageRoute<dynamic>> {}
