# referAFriend

Updated on `2026-04-27`.

## Why this change

The `login` flow already had the correct phone input behavior:

- country picker opens on tap
- Bahamas defaults to `+1`
- Bahamas input is formatted as `(242) 345-4356`
- validation is country-aware
- invalid phone state is shown inline under the input
- API submission uses the normalized phone number, not the UI-formatted text

The `referFriend` prepaid flow was not using the same behavior. It rendered a phone row, but:

- the country picker tap was not wired
- selected country was not stored in bloc state
- invalid phone numbers were not validated like `login`
- the API was receiving the raw field text

## What changed

### Phone input behavior

- Added a dedicated `ReferFriendPrepaidPhoneRow` widget.
- Reused the same login phone utilities for:
  - country selection mapping
  - live phone validation
  - Bahamas phone formatting
- Kept the error text aligned under the phone field only, matching the login pattern.

### Bloc and state

- Added selected country state to the refer flow.
- Added a phone field error flag for submit-time validation.
- Added an email field error flag for submit-time validation.
- Added a country-changed event.
- Normalized the phone number before calling the refer API.
- Improved `copyWith` so toast/error values stay stable unless explicitly changed.

### UI fixes

- Country picker now opens when the user taps the flag/code area.
- Phone and email stay borderless in the neutral idle state.
- Phone border and phone text turn error-red when the number is invalid.
- Bahamas hint/format now matches the login experience.
- Email now uses inline validation with error text under the field, matching the phone input behavior.
- Disposed the `TapGestureRecognizer` in the refer tab to avoid leaks.

## Files touched

- `referFriend/prepaid/bloc/refer_friend_prepaid_event.dart`
- `referFriend/prepaid/bloc/refer_friend_prepaid_state.dart`
- `referFriend/prepaid/bloc/refer_friend_prepaid_bloc.dart`
- `referFriend/prepaid/theme/refer_friend_prepaid_theme.dart`
- `referFriend/prepaid/utils/refer_friend_prepaid_email_helper.dart`
- `referFriend/prepaid/widgets/refer_friend_prepaid_refer_tab.dart`
- `referFriend/prepaid/widgets/refer_friend_prepaid_phone_row.dart`

## Validation behavior now

- Empty phone still keeps the inline phone error quiet until the user types or submits.
- Invalid typed phone shows inline `invalid phone number`.
- Empty email keeps the inline email error quiet until the user types or submits.
- Invalid typed email shows inline `invalid email address`.
- Valid phone is converted to the API-ready number before submission.
- Non-phone submission errors still use the existing toast flow.
