import 'package:equatable/equatable.dart';

enum HomePlansCardBrand { visa, mastercard, unknown }

/// Defines which plan type the current user belongs to.
///
/// `prepaid` users can see the "pay from wallet" row.
/// `postpaid` users keep the current "charge to my account" option.
enum HomePlansSubscriberType { prepaid, postpaid }

class HomePlansSavedPaymentMethod extends Equatable {
  final String id;
  final HomePlansCardBrand brand;
  final String ending; // "1234"
  final String expiry; // "06/2024"
  final bool isChargeToMyAccount;

  /// SVG logo asset path for the card brand icon.
  final String logoSvgAsset;

  const HomePlansSavedPaymentMethod({
    required this.id,
    required this.brand,
    required this.ending,
    required this.expiry,
    required this.logoSvgAsset,
    this.isChargeToMyAccount = false,
  });

  @override
  List<Object?> get props => [
        id,
        brand,
        ending,
        expiry,
        logoSvgAsset,
        isChargeToMyAccount,
      ];
}

/// Route arguments for Home Plans payment method screen.
///
/// Keep this class simple and explicit so it is easy to debug and extend.
class HomePlansPaymentMethodRouteArgs extends Equatable {
  final HomePlansSubscriberType subscriberType;
  final double walletBalance;

  /// Optional override for the amount the user is paying.
  /// `null` keeps the screen's existing default for legacy callers.
  final double? amount;

  /// Optional override for the VAT note — `'no vat applied'` or `'vat included'`.
  /// `null` keeps the screen's existing default.
  final String? vatNote;

  const HomePlansPaymentMethodRouteArgs({
    this.subscriberType = HomePlansSubscriberType.prepaid,
    this.walletBalance = 129.00,
    this.amount,
    this.vatNote,
  });

  @override
  List<Object?> get props => [subscriberType, walletBalance, amount, vatNote];
}
