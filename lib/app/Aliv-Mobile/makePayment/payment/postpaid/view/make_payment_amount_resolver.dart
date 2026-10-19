import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';

import '../bloc/make_payment_postpaid_event.dart';
import '../bloc/make_payment_postpaid_state.dart';

/// Resolves the actual amount to charge based on the user's choice:
/// - "other amount" + parsable positive value → custom amount
/// - otherwise → wallet balance from [BalanceCubit]
///
/// The bloc mirrors this rule server-side (see `_amountToCharge`); keeping
/// the same computation in view code lets the bottom bar preview the exact
/// figure the bloc will post, without duplicating the source of truth.
double resolveMpAmountToCharge(MakePaymentPostPaidState state) {
  if (state.amountOption == MpAmountOption.other) {
    final parsed = double.tryParse(state.customAmount.trim());
    if (parsed != null && parsed > 0) return parsed;
  }
  return instance<BalanceCubit>().state.walletBalance;
}
