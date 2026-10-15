import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

/// Uses Home's actual account/device names, without its email/"User" fallback.
String resolveWalletPaymentUserName({String? accountName, String? deviceName}) {
  const placeholders = {
    'user',
    'user name',
    'username',
    '[user name]',
    '[username]',
    'null',
    'unknown',
    'n/a',
    'none',
    'guest',
  };
  for (final candidate in [accountName, deviceName]) {
    final name = candidate?.trim() ?? '';
    final normalized = name.toLowerCase();
    final words = normalized.split(RegExp(r'\s+'));
    if (name.isNotEmpty &&
        !placeholders.contains(normalized) &&
        !words.contains('null') &&
        !words.every(placeholders.contains)) {
      return name;
    }
  }
  return 'user';
}

/// Transient presentation context for one confirmed wallet transaction.
/// Its consumption stays with the route extra, including receipt rebuilds.
class WalletPaymentSuccess {
  WalletPaymentSuccess({String? accountName, String? deviceName})
    : userName = resolveWalletPaymentUserName(
        accountName: accountName,
        deviceName: deviceName,
      );

  factory WalletPaymentSuccess.fromCurrentUser({AccountInfoState? account}) {
    final accountState =
        account ??
        (instance.isRegistered<AccountInfoCubit>()
            ? instance<AccountInfoCubit>().state
            : null);
    final devices = instance.isRegistered<DeviceLimitsCubit>()
        ? instance<DeviceLimitsCubit>().state
        : null;
    return WalletPaymentSuccess(
      accountName: accountState?.fullName,
      deviceName: devices?.fullName,
    );
  }

  final String userName;
  bool _shown = false;

  String get message =>
      'Thank you, $userName! Your payment was successfully processed from your wallet.';

  void showOnce() {
    if (_shown || rootNavigatorKey.currentState?.overlay == null) {
      return;
    }
    _shown = true;
    AppToast.show(message: message, type: ToastType.success);
  }
}

/// Presents the wallet toast from the destination's first visible frame.
class WalletPaymentSuccessReceipt extends StatefulWidget {
  const WalletPaymentSuccessReceipt({
    super.key,
    required this.success,
    required this.child,
  });

  final WalletPaymentSuccess? success;
  final Widget child;

  @override
  State<WalletPaymentSuccessReceipt> createState() =>
      _WalletPaymentSuccessReceiptState();
}

class _WalletPaymentSuccessReceiptState
    extends State<WalletPaymentSuccessReceipt> {
  @override
  void initState() {
    super.initState();
    _presentAfterFrame();
  }

  @override
  void didUpdateWidget(covariant WalletPaymentSuccessReceipt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.success != widget.success) {
      _presentAfterFrame();
    }
  }

  void _presentAfterFrame() {
    final success = widget.success;
    if (success == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        success.showOnce();
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
