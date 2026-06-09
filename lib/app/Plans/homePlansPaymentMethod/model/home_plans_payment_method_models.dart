import 'package:equatable/equatable.dart';

enum HomePlansCardBrand { visa, mastercard, unknown }

enum HomePlansPaymentPlanType {
  primary,
  secondary,
  standalone;

  static HomePlansPaymentPlanType fromCode(String code) {
    switch (code.trim().toUpperCase()) {
      case 'P':
        return HomePlansPaymentPlanType.primary;
      case 'S':
        return HomePlansPaymentPlanType.secondary;
      case 'A':
        return HomePlansPaymentPlanType.standalone;
      default:
        return HomePlansPaymentPlanType.standalone;
    }
  }
}

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

class HomePlansPaymentSelectedItem extends Equatable {
  final String id;
  final String label;
  final String title;
  final String subtitle;
  final double price;
  final HomePlansPaymentPlanType planType;

  const HomePlansPaymentSelectedItem({
    required this.id,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.price,
    this.planType = HomePlansPaymentPlanType.standalone,
  });

  @override
  List<Object?> get props => [id, label, title, subtitle, price, planType];
}

/// Route arguments for Home Plans payment method screen.
///
/// Keep this class simple and explicit so it is easy to debug and extend.
class HomePlansPaymentMethodRouteArgs extends Equatable {
  final HomePlansSubscriberType subscriberType;
  final String phoneNumber;

  /// Optional override for the amount the user is paying.
  /// `null` keeps the screen's existing default for legacy callers.
  final double? amount;

  /// Optional override for the VAT note — `'no vat applied'` or `'vat included'`.
  /// `null` keeps the screen's existing default.
  final String? vatNote;

  /// Selected plan/add-on lines from the confirmation screen.
  final List<HomePlansPaymentSelectedItem> selectedItems;
  final bool forceNow;
  final DateTime? selectedBeginDate;

  const HomePlansPaymentMethodRouteArgs({
    this.subscriberType = HomePlansSubscriberType.prepaid,
    this.phoneNumber = '',
    this.amount,
    this.vatNote,
    this.selectedItems = const <HomePlansPaymentSelectedItem>[],
    this.forceNow = false,
    this.selectedBeginDate,
  });

  @override
  List<Object?> get props => [
    subscriberType,
    phoneNumber,
    amount,
    vatNote,
    selectedItems,
    forceNow,
    selectedBeginDate,
  ];
}
