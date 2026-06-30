import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanPurchaseReceipt/bloc/home_plan_purchase_receipt_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';

/// Builds the `extra` payload pushed to the purchase-receipt route. Pure
/// logic; no UI. Centralises the receipt's wording so screens don't drift.
class PaymentReceiptBuilder {
  PaymentReceiptBuilder._();

  static Map<String, dynamic> build(
    BuildContext context,
    HomePlansPaymentMethodState state, {
    required bool hideSaveCreditCard,
  }) {
    final now = DateTime.now();
    final date = DateFormat('MMM d, yyyy').format(now);
    final time = DateFormat('h:mm a').format(now).toLowerCase();
    final account = context.read<AccountInfoCubit>().state.accountInfo;
    final phone = _phoneNumber(state, account);
    final email = _firstNonEmpty([account?.email]);
    final method = _paymentMethodLabel(state);

    return <String, dynamic>{
      'hideSaveCreditCard': hideSaveCreditCard,
      'phoneNumber': phone,
      'amount': state.amount,
      'dateText': date,
      'timeText': time,
      'paymentMethod': method,
      'statusMessage':
          'It will take a few moments for the plan to appear on the account.',
      'leftType': 'service',
      'rightType': state.isPrepaidUser ? 'prepaid' : 'postpaid',
      'details': _details(state, date, time, phone, email, method),
      'subscriberType': state.subscriberType,
      'selectedItems': state.selectedItems,
      'selectedMethodId': state.selectedMethodId,
      'paymentMethods': state.methods,
    };
  }

  static List<HomePlanPurchaseReceiptDetailItem> _details(
    HomePlansPaymentMethodState state,
    String date,
    String time,
    String phone,
    String email,
    String method,
  ) {
    final items = <HomePlanPurchaseReceiptDetailItem>[
      for (final item in state.selectedItems)
        HomePlanPurchaseReceiptDetailItem(
          label: item.label.trim().isEmpty
              ? _planTypeLabel(item.planType)
              : item.label,
          value: item.title,
        ),
      HomePlanPurchaseReceiptDetailItem(label: 'date', value: date),
      HomePlanPurchaseReceiptDetailItem(label: 'time', value: time),
    ];
    if (phone.isNotEmpty) {
      items.add(HomePlanPurchaseReceiptDetailItem(
        label: 'phone no.',
        value: phone,
      ));
    }
    if (email.isNotEmpty) {
      items.add(HomePlanPurchaseReceiptDetailItem(
        label: 'email address',
        value: email,
      ));
    }
    items.add(HomePlanPurchaseReceiptDetailItem(
      label: 'payment method',
      value: method,
    ));
    return items;
  }

  /// Wallet-funded paths render as 'wallet'; saved-card shows brand+ending;
  /// new-card (`payWithCard`) is always Visa per the current factory.
  static String _paymentMethodLabel(HomePlansPaymentMethodState state) {
    switch (state.paymentMode) {
      case HomePlansPaymentMode.payFromWallet:
      case HomePlansPaymentMode.chargeToMyAccount:
        return 'wallet';
      case HomePlansPaymentMode.card:
        return _selectedMethodLabel(state);
      case HomePlansPaymentMode.payWithCard:
        return 'visa';
    }
  }

  static String _selectedMethodLabel(HomePlansPaymentMethodState state) {
    final id = state.selectedMethodId;
    HomePlansSavedPaymentMethod? m;
    for (final item in state.methods) {
      if (item.id == id) {
        m = item;
        break;
      }
    }
    if (m == null) return 'credit card';
    if (m.isChargeToMyAccount) return 'my account';
    return switch (m.brand) {
      HomePlansCardBrand.visa => 'visa ending ${m.ending}',
      HomePlansCardBrand.mastercard => 'mastercard ending ${m.ending}',
      HomePlansCardBrand.unknown => 'card ending ${m.ending}',
    };
  }

  static String _planTypeLabel(HomePlansPaymentPlanType type) => switch (type) {
    HomePlansPaymentPlanType.primary => 'primary plan',
    HomePlansPaymentPlanType.secondary => 'secondary plan',
    HomePlansPaymentPlanType.standalone => 'plan',
  };

  static String _phoneNumber(
    HomePlansPaymentMethodState state,
    AccountInfoModel? account,
  ) {
    final raw = _firstNonEmpty([
      state.phoneNumber,
      account?.phoneNumber,
      account?.primaryPhoneNumber,
      account?.username,
    ]);
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '${digits.substring(0, 3)}-'
          '${digits.substring(3, 6)}-'
          '${digits.substring(6)}';
    }
    return raw;
  }

  static String _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      final t = v?.trim() ?? '';
      if (t.isNotEmpty) return t;
    }
    return '';
  }
}
