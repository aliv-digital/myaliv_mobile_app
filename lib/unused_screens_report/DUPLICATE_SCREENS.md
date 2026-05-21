# Duplicate Screens Report

This report lists duplicate or highly similar screen-like files found during a
static audit across `lib/app`. The audit compared screen-like Dart files,
normalized screen names, and content similarity.

No exact duplicate screen file was found. The items below are refactor
candidates, not automatic deletion candidates.

No app code was modified for this report.

## High Similarity

| Similarity | Files | Notes |
| --- | --- | --- |
| 92.5% | `lib/app/Aliv-Mobile/reviewInvoices/Otp/postpaid/view/otp_postpaid_screen.dart`<br>`lib/app/Aliv-Mobile/userProfile/Otp/prepaid/view/otp_profile_prepaid_screen.dart` | Very similar OTP screens. |
| 92.1% | `lib/app/Aliv-Mobile/reviewInvoices/enterPassword/postpaid/view/enter_password_postpaid_screen.dart`<br>`lib/app/Aliv-Mobile/userProfile/enterPassword/prepaid/view/enter_password_prepaid_screen.dart` | Very similar password-entry screens. |
| 90.0% | `lib/app/Aliv-Mobile/reviewInvoices/enterPassword/postpaid/view/enter_password_postpaid_screen.dart`<br>`lib/app/Aliv-Mobile/autoRenew/enterPassword/prepaid/view/enter_password_autoRenew_prepaid_screen.dart` | Very similar password-entry screens. |
| 86.6% | `lib/app/Aliv-Mobile/settings/fingerPrintSecurity/view/fingerprint_security_screen.dart`<br>`lib/app/Aliv-Mobile/settings/faceIdSecurity/view/face_id_security_screen.dart` | Similar biometric security screens. |

## Medium Similarity

| Similarity | Files | Notes |
| --- | --- | --- |
| 77.9% | `lib/app/Aliv-Mobile-Guest/guestPaymentMethod/prepaid/view/guest_payment_method_prepaid_screen.dart`<br>`lib/app/Aliv-Mobile/revBillPay/paymentMethod/prepaid/view/rev_payment_method_prepaid_screen.dart` | Similar payment-method screens. |
| 77.0% | `lib/app/Plans/homePlanConfirmation/view/home_plan_confirmation_screen.dart`<br>`lib/app/Plans/homeRoamingConfirmation/view/home_roaming_confirmation_screen.dart` | Similar plan confirmation screens. |
| 75.8% | `lib/app/Aliv-Mobile/userProfile/profile/prepaid/view/profile_prepaid_screen.dart`<br>`lib/app/Aliv-Mobile/userProfile/profile/postpaid/view/profile_postpaid_screen.dart` | Similar prepaid/postpaid profile screens. |
| 66.9% | `lib/app/Aliv-Mobile-Guest/addOnsConfirmation/view/add_ons_confirmation_screen.dart`<br>`lib/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/view/guest_purchase_plan_confirmation_screen.dart` | Similar guest confirmation screens. |
| 63.7% | `lib/app/Aliv-Mobile-Guest/guestTopUpReceipt/view/guest_top_up_receipt_screen.dart`<br>`lib/app/Aliv-Mobile/userProfile/receipt/view/user_profile_receipt_screen.dart` | Similar receipt screens. |

## Main Refactor Opportunity

The strongest duplication cluster is the password flow:

| File | Screen |
| --- | --- |
| `lib/app/Security/secuirity_common_password_screen.dart` | `CommonEnterPasswordPage` |
| `lib/app/Aliv-Mobile/reviewInvoices/enterPassword/postpaid/view/enter_password_postpaid_screen.dart` | `EnterPasswordPostpaidScreen` |
| `lib/app/Aliv-Mobile/autoRenew/enterPassword/prepaid/view/enter_password_autoRenew_prepaid_screen.dart` | `EnterPasswordAutoRenewPrepaidScreen` |
| `lib/app/Aliv-Mobile/userProfile/enterPassword/prepaid/view/enter_password_prepaid_screen.dart` | `EnterPasswordPrepaidScreen` |
| `lib/app/Aliv-Mobile/userProfile/changePassword/prepaid/view/change_password_prepaid_screen.dart` | `ChangePasswordPrepaidScreen` |

These could likely share a common password or verification layout with
configurable title, body copy, action, and route behavior.

