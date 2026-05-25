import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';

/// Outcome of resolving the default payment-method selection for the
/// auto-pay (postpaid) / auto-renew (prepaid) screens.
sealed class AutoPaySelection {
  const AutoPaySelection();
}

/// Select the given saved card (server has a valid stored token that
/// matches one of the user's saved cards).
class SelectSavedCard extends AutoPaySelection {
  final SavedCardModel card;
  const SelectSavedCard(this.card);
}

/// Select the "i don't want to auto renew / auto pay" option.
class SelectNoAutoRenew extends AutoPaySelection {
  const SelectNoAutoRenew();
}

/// Select the "pay from wallet" option (prepaid only).
class SelectPayFromWallet extends AutoPaySelection {
  const SelectPayFromWallet();
}

/// Pure business rules for choosing the default payment selection when
/// entering the auto-pay or auto-renew screens.
///
/// Inputs:
/// - [autoEnabled]: `AccountInfoModel.autoRenew` for prepaid or
///   `AccountInfoModel.autoPayInvoice` for postpaid.
/// - [serverToken]: token returned by `GET /CreditCard/auto-renew` (prepaid)
///   or `GET /CreditCard/auto-pay` (postpaid).
/// - [savedCards]: the user's saved cards.
/// - [walletAvailable]: `true` only on prepaid auto-renew, where wallet is
///   a valid auto-renew payment method. `false` on postpaid auto-pay.
///
/// Rules (evaluated in order):
/// 1. `serverToken` matches a saved card → [SelectSavedCard]. A matching
///    token is the strongest signal — if the server points at a card the
///    user actually has, show that card regardless of the autoRenew flag
///    (the flag may be stale or out of sync with the token endpoint).
/// 2. `autoEnabled == false` (and no token match) → [SelectNoAutoRenew].
/// 3. `autoEnabled == true` with no token match:
///    - prepaid (`walletAvailable == true`) → [SelectPayFromWallet]. The
///      stored card is gone but auto-renew is still on, so the active
///      payment method must be wallet.
///    - postpaid (`walletAvailable == false`) → [SelectNoAutoRenew]. There
///      is no wallet option on postpaid; safest UX is to let the user
///      re-pick.
class AutoPaySelectionResolver {
  const AutoPaySelectionResolver._();

  static AutoPaySelection resolve({
    required bool autoEnabled,
    required String? serverToken,
    required List<SavedCardModel> savedCards,
    bool walletAvailable = false,
  }) {
    final token = serverToken?.trim();
    if (token != null && token.isNotEmpty) {
      for (final card in savedCards) {
        if (card.token == token) return SelectSavedCard(card);
      }
    }

    if (!autoEnabled) return const SelectNoAutoRenew();

    if (walletAvailable) return const SelectPayFromWallet();
    return const SelectNoAutoRenew();
  }
}
