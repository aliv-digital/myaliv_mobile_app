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
  });

  final String mfaToken;
  final String apiPhoneNumber;
  final HistoryDestination destination;
}
