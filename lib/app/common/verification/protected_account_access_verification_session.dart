import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';

/// Process-memory access grant for History and Review Invoices only.
/// A same-account token refresh is not a new identity or a new window.
class ProtectedAccountAccessVerificationSession extends ChangeNotifier {
  ProtectedAccountAccessVerificationSession({
    DateTime Function()? now,
    Object? Function()? accountContext,
    Stream<Object?>? accountChanges,
  }) : _now = now ?? DateTime.now,
       _accountContext = accountContext ?? currentAccountContext {
    _identity = _accountContext();
    _subscription = accountChanges?.listen((identity) {
      // Observe each emitted identity, not only the latest Cubit snapshot:
      // an away-and-back switch must revoke the old grant too.
      if (identity != _identity) {
        _identity = identity;
        _expiresAt = null;
        _generation++;
        notifyListeners();
      }
    });
  }

  static const validity = Duration(minutes: 20);
  final DateTime Function() _now;
  final Object? Function() _accountContext;
  StreamSubscription<Object?>? _subscription;
  Object? _identity;
  DateTime? _expiresAt;
  int _generation = 0;

  static Object? currentAccountContext() {
    if (!instance.isRegistered<AuthManager>() ||
        instance<AuthManager>().currentSession == null ||
        !instance.isRegistered<AccountInfoCubit>()) {
      return null;
    }
    final account = instance<AccountInfoCubit>().state.accountInfo;
    return account == null ? null : (account.idAcc, account.username);
  }

  bool _synchronizeIdentity() {
    final identity = _accountContext();
    if (identity == _identity) {
      return false;
    }
    _identity = identity;
    _expiresAt = null;
    _generation++;
    return true;
  }

  int get generation {
    _synchronizeIdentity();
    return _generation;
  }

  DateTime? get expiresAt {
    _synchronizeIdentity();
    return _expiresAt;
  }

  bool get isVerified {
    _synchronizeIdentity();
    final expiry = _expiresAt;
    return _identity != null && expiry != null && _now().isBefore(expiry);
  }

  /// Call only after real OTP verification and successful session persistence.
  bool markVerified({int? expectedGeneration}) {
    _synchronizeIdentity();
    if (_identity == null ||
        (expectedGeneration != null && expectedGeneration != _generation)) {
      return false;
    }
    _expiresAt = _now().add(validity);
    notifyListeners();
    return true;
  }

  void reset() {
    _identity = _accountContext();
    _expiresAt = null;
    _generation++;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
