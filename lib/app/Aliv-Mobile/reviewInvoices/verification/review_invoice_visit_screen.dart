import 'package:flutter/widgets.dart';
import 'package:myaliv_mobile_app/app/common/verification/protected_access_entry.dart';

import '../reviewInvoice/postpaid/view/review_invoice_postpaid_screen.dart';
import 'review_invoice_route_observer.dart';
import 'review_invoice_verification_gate_screen.dart';

/// Gates the existing invoice screen; never resets shared access on leaving.
class ReviewInvoiceVisitScreen extends StatelessWidget {
  const ReviewInvoiceVisitScreen({super.key});

  @override
  Widget build(BuildContext context) => ProtectedAccessEntry(
    observer: reviewInvoiceRouteObserver,
    gate: const ReviewInvoiceVerificationGateScreen(),
    child: const ReviewInvoicePostpaidScreen(),
  );
}
