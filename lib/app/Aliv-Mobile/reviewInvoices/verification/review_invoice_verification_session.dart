import 'package:flutter/foundation.dart';

/// Memory-only authorization for one Review Invoices visit, never History.
class ReviewInvoiceVerificationSession extends ChangeNotifier {
  bool _isVerified = false;
  int _generation = 0;

  bool get isVerified => _isVerified;

  /// Invalidates a pending verification when logout or visit cleanup occurs.
  int get generation => _generation;

  void markVerified() {
    _isVerified = true;
    notifyListeners();
  }

  void reset() {
    _isVerified = false;
    _generation++;
    notifyListeners();
  }
}
