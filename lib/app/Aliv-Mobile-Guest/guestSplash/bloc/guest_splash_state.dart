import 'package:country_picker/country_picker.dart';
import '../model/guest_purchase_plan_input.dart';


abstract class GuestSplashState {}

class GuestSplashInitial extends GuestSplashState {}

enum GuestSplashPurchasePlanStatus { idle, success, failure }

class GuestSplashLoadedState extends GuestSplashState {
  final bool isLoaded;

  // ✅ Bottom sheet fields inside same state
  final Country? purchaseCountry;
  final String purchasePhone;
  final String purchaseConfirmPhone;

  final GuestSplashPurchasePlanStatus purchaseStatus;
  final String? purchaseErrorMessage;

  final GuestSplashPurchasePlanInput? purchaseResult;

  GuestSplashLoadedState({
    required this.isLoaded,
    this.purchaseCountry,
    this.purchasePhone = '',
    this.purchaseConfirmPhone = '',
    this.purchaseStatus = GuestSplashPurchasePlanStatus.idle,
    this.purchaseErrorMessage,
    this.purchaseResult,
  });

  GuestSplashLoadedState copyWith({
    bool? isLoaded,
    Country? purchaseCountry,
    String? purchasePhone,
    String? purchaseConfirmPhone,
    GuestSplashPurchasePlanStatus? purchaseStatus,
    String? purchaseErrorMessage,
    GuestSplashPurchasePlanInput? purchaseResult,
    bool clearPurchaseErrorMessage = false,
    bool clearPurchaseResult = false,
  }) {
    return GuestSplashLoadedState(
      isLoaded: isLoaded ?? this.isLoaded,
      purchaseCountry: purchaseCountry ?? this.purchaseCountry,
      purchasePhone: purchasePhone ?? this.purchasePhone,
      purchaseConfirmPhone: purchaseConfirmPhone ?? this.purchaseConfirmPhone,
      purchaseStatus: purchaseStatus ?? this.purchaseStatus,
      purchaseErrorMessage: clearPurchaseErrorMessage ? null : (purchaseErrorMessage ?? this.purchaseErrorMessage),
      purchaseResult: clearPurchaseResult ? null : (purchaseResult ?? this.purchaseResult),
    );
  }
}
