import 'package:myaliv_mobile_app/router/app_routes.dart';

enum HistoryDestination {
  transactions,
  callLogs;

  static HistoryDestination fromTabParameter(String? tab) {
    return tab == 'call_logs' ? callLogs : transactions;
  }

  String get location =>
      '${AppRoutes.callLogs}?tab=${this == transactions ? 'transactions' : 'call_logs'}';
}

class CallLogsOtpRouteArgs {
  const CallLogsOtpRouteArgs({
    required this.mfaToken,
    required this.apiPhoneNumber,
    this.destination = HistoryDestination.callLogs,
    this.returnInPlace = false,
  });

  final String mfaToken;
  final String apiPhoneNumber;
  final HistoryDestination destination;

  // When true, the OTP screen pops with `true` on success instead of
  // pushReplacing to [destination]. Used when the caller is already on
  // the History screen and wants to switch tabs without stacking a new
  // instance.
  final bool returnInPlace;
}
