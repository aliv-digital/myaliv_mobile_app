import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

import 'protected_account_access_verification_session.dart';

/// Checks access on entry/return, not on every rebuild or elapsed-time tick.
class ProtectedAccessEntry extends StatefulWidget {
  const ProtectedAccessEntry({
    super.key,
    required this.observer,
    required this.gate,
    required this.child,
  });

  final RouteObserver<PageRoute<dynamic>> observer;
  final Widget gate;
  final Widget child;

  @override
  State<ProtectedAccessEntry> createState() => _ProtectedAccessEntryState();
}

class _ProtectedAccessEntryState extends State<ProtectedAccessEntry>
    with RouteAware {
  late final ProtectedAccountAccessVerificationSession _session;
  PageRoute<dynamic>? _route;
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    _session = instance<ProtectedAccountAccessVerificationSession>();
    _entered = _session.isVerified;
    _session.addListener(_onSessionChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic> && !identical(route, _route)) {
      widget.observer.unsubscribe(this);
      _route = route;
      widget.observer.subscribe(this, route);
    }
  }

  void _onSessionChanged() {
    // Explicit logout/account reset revokes even an active viewer. Expiry
    // itself sends no notification and never unexpectedly ejects a viewer.
    if (!_session.isVerified) {
      _entered = false;
      _refresh();
    }
  }

  @override
  void didPopNext() {
    _entered = _session.isVerified;
    _refresh();
  }

  void _refresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    widget.observer.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _entered ? widget.child : widget.gate;
}
