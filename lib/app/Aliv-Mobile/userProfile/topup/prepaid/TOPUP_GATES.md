# Top-Up Preflight Gates

Concise reference for the vendor-mandated preflight applied to the **My Number** and **Send Top-up** tabs of the prepaid top-up screen.

---

## The gates (in order, cheap → expensive)

| # | Endpoint | Scope | Fail-closed? |
|---|---|---|---|
| **Limit** | `GET /Account/top-up-limit-left` | Both tabs (fetched on screen load) | Yes → Case D |
| **Gate 0** | `GET /device/exists/{phoneNumber}` | Send Top-up only (first async check on proceed) | 3-value result — see below |
| **Gate 2** | `GET /device/can-top-up/{phoneNumber}?amount={amount}` | Send Top-up only | Yes → recipient toast |
| **Gate 3** | `GET /Account/can-submit-order?amount={amount}` | Both tabs (on proceed tap) | Yes → Case D |

Then POST `/Order/top-up/{phone}` (My Number) or `/Order/transfer` (Send Top-up).

### Gate 0 result semantics
Backend distinguishes "not an Aliv number" from a network failure. Repository returns `PhoneExistsResult`:
- `exists` — `{ "Success": true }` → proceed
- `invalidDevice` — error envelope `{ "ErrorCode": 501, "ErrorCodeName": "InvalidDevice" }` → toast: *"this number is not registered on aliv. please verify the number."*
- `unknown` — any other failure (timeout, 5xx, malformed body) → Case D toast

---

## Case A/B/C/D (limit gate)

Same copy on both tabs; field sources differ.

| Case | Trigger | Message |
|---|---|---|
| A | **any** required limit is 0/null (per-tx OR daily ceiling — see below) | *"your top up limit is not set on your account. to process this payment, please contact support at 1-242-300-2548"* |
| B | `amount > perTxLimit` | *"your single top up limit is $X. please lower the amount…"* |
| C | daily bucket exceeded | *"your daily top up limit is $Y. please try a smaller amount…"* |
| D | fetch failed / data missing | *"please try again in a few minutes. if this continues, contact support at 1-242-300-2548"* |

**Case A rationale**: the vendor spec says *"Limit not set (NULL or $0.00)"* without naming which limit. If we only checked `perTxLimit`, an account with `topUp24HourLimit=0` and `perTxLimit=100` would sail past Case A and hit Case C, rendering *"your daily top up limit is $0.00"* — wrong copy. So Case A fires when **either** required limit is missing.

### Field mapping

| Tab | perTxLimit | daily ceiling (Case A + Case C msg) | daily gate |
|---|---|---|---|
| **My Number** | `AccountInfo.topUpPerTransLimit` | `AccountInfo.topUp24HourLimit` | `amount > TopUp24HourLimitLeft` |
| **Send Top-up** | `DeviceLimits.perTransTransferMoneyLimit` | `DeviceLimits.perDayTransferMoneyLimit` (msg) + `AccountInfo.topUp24HourLimit` (needed for cumsum) | `(topUp24HourLimit − TopUp24HourLimitLeft) + amount > perDayTransferMoneyLimit` |

**Case A checks** (any → fire Case A):
- **My Number**: `topUpPerTransLimit <= 0` **OR** `topUp24HourLimit <= 0`
- **Send Top-up**: `!canTransferMoney` **OR** `perTransTransferMoneyLimit <= 0` **OR** `perDayTransferMoneyLimit <= 0` **OR** `topUp24HourLimit <= 0` *(needed for cumsum)*

---

## Concrete examples

**My Number, Case B**
> Account: `topUpPerTransLimit=100`, `topUp24HourLimit=200`, `TopUp24HourLimitLeft=200`
> User enters `150` → **"your single top up limit is $100.00. please lower the amount to continue your transaction."**

**My Number, Case C**
> Account: same as above but `TopUp24HourLimitLeft=50`
> User enters `80` → **"your daily top up limit is $200.00. please try a smaller amount to complete your transaction."**

**Send Top-up, Case C (cumulative)**
> Device: `perDayTransferMoneyLimit=100`
> Account: `topUp24HourLimit=200`, `TopUp24HourLimitLeft=120` → spent today = `200 − 120 = 80`
> User enters `30` → `80 + 30 = 110 > 100` → **"your daily top up limit is $100.00. please try a smaller amount…"**

**Gate 2 blocked**
> Send Top-up to `2425550181` with `amount=25` → `{ "Success": false }` → **"this number cannot receive a top-up right now. please verify the number or try again."**

**Gate 3 blocked**
> Any tab, proceed tapped → `{ "Info": "Order # 12234 is in progress for # 2428999726." }` → toast displays that string verbatim.

**Gate 3 network error**
> Endpoint times out → `CanSubmitOrderException` → Case D toast.

---

## UTC → local for `EarliestTopUpDate`

API returns bare `"2024-10-04 21:14:19"` (no `Z`, no `T`). Parsed once in `TopUpLimitLeft.fromJson` by normalizing to `"2024-10-04T21:14:19Z"` and calling `.toLocal()`. Downstream code uses `earliestTopUpDateLocal` directly — no timezone reasoning at the UI layer.

*(The mandated Case C copy doesn't reference this time — it's kept in state for future UX if design ever wants "you can top up again after 9:14 PM".)*

---

## File map

```
lib/core/networkService/api_paths.dart
    + Api.topUpLimitLeft
    + Api.canTopUpRecipient(phoneNumber, amount)
    + Api.canSubmitOrder(amount)

lib/app/Aliv-Mobile/userProfile/topup/prepaid/
├── repository/
│   ├── top_up_limit_left_model.dart          [NEW] UTC→local parser
│   ├── can_submit_order_result.dart          [NEW] Info-based OK/blocked
│   ├── top_up_prepaid_repository.dart        + fetchTopUpLimitLeft(), canSubmitOrder()
│   └── send_topup_repository.dart            + canTopUpRecipient()
├── logic/
│   └── top_up_limit_gate.dart                [NEW] pure A/B/C/D helpers
├── bloc/
│   ├── top_up_prepaid_state.dart             + limitLeft, earliestTopUpDateLocal, limitFetchFailed
│   ├── top_up_prepaid_event.dart             + TopUpPrepaidLimitRefreshed
│   └── top_up_prepaid_bloc.dart              parallel Future.wait for balance + limit
├── view/
│   └── top_up_prepaid_screen.dart            _MyNumberTab → stateful, Gate 3 preflight
└── widgets/
    └── send_top_up_placeholder_tab.dart      Gate 2 + Gate 3 preflight w/ spinner
```

---

## Open items

- **`?amount=` query param on Gates 2/3** — app-observed, not in v1.0 spec. Strict gateway could silently ignore.
- **Gate 2 path param** — spec confirms `{phoneNumber}`, not `{deviceId}`.
- **Gate 3 copy** — displayed verbatim from `Info` field; may not match app's lowercase style. No product guidance yet.
- **`AppSession.appRoute = 'sendTopUp'`** — side-effect mutation left in place; consider moving into the confirmation-screen args when refactored.

---

## UAT vectors

| Case | Test account (from vendor matrix) |
|---|---|
| A | 899-8519, 899-9357, 899-9620, 899-9958 — `topUp24HourLimit=0`. Case A fires on the daily-ceiling check (the account may still have a non-zero `topUpPerTransLimit`, which is why the old per-tx-only trigger missed this). |
| B | any with `topUpPerTransLimit=100`, submit `150` |
| C | any with `topUp24HourLimit=200`, do two `100` back-to-back on My Number |
| D | airplane mode after screen load |
| Gate 2 | invalid recipient number |
| Gate 3 | trigger a top-up, then immediately submit another before backend clears |
