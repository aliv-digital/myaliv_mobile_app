# Unused Screens Report

This report lists screen-like files found during a static usage check against
`lib/router/app_router.dart`, `lib/router/app_routes.dart`, direct class
references, and active `context.go` / `context.push` navigation calls.

No app code was modified for this report.

## Likely Unused Screens

| File | Finding |
| --- | --- |
| `lib/app/Aliv-Mobile/userProfile/topup/prepaid/view/wallet_transfer_receipt_screen.dart` | `WalletTransferReceiptScreen` has no active usage. The only reference found is commented out in `pay_from_wallet.dart`; the current active flow uses `AppRoutes.userProfileReceiptScreen`. |
| `lib/app/Aliv-Mobile/userProfile/topup/prepaid/view/send_top_up_success_screen.dart` | File is empty and has no active usage. |

## Related Non-Screen Unused View

| File | Finding |
| --- | --- |
| `lib/app/Plans/PlanScreen/view/aliv_calender_picker.dart` | `AlivCalendarPicker` has no active references. It appears to be a reusable calendar widget rather than a full app screen. |

