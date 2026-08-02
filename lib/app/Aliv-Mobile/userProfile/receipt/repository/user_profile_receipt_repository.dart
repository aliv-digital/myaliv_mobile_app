import 'package:core/core.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';

import '../models/user_profile_receipt_data.dart';
import '../models/user_profile_receipt_route_args.dart';

class UserProfileReceiptRepository {
  UserProfileReceiptData buildReceipt(UserProfileReceiptRouteArgs args) {
    final createdAt = args.createdAt ?? DateTime.now();
    final phoneNumber = _formatPhoneNumber(
      _firstNonEmpty([args.phoneNumber, _loggedInPhoneNumber()]),
    );

    return UserProfileReceiptData(
      typeLabel: args.receiptTypeLabel,
      topUpType: args.topUpType,
      dateText: DateFormat('MMM d, yyyy').format(createdAt),
      timeText: DateFormat('h:mm a').format(createdAt).toLowerCase(),
      phoneNumber: args.recipientPhone == null
          ? phoneNumber
          : _formatPhoneNumber(args.recipientPhone!),
      paymentMethod: args.paymentMethod,
      amount: args.amount,
      title: args.title,
      message: args.receiptMessage,
      variant: args.variant,
    );
  }

  String _loggedInPhoneNumber() {
    final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
    if (accountInfo == null) return '';

    final phoneNumbers = _accountPhoneNumbers(accountInfo);
    final primaryPhone = accountInfo.primaryPhoneNumber.trim();

    if (primaryPhone.isNotEmpty &&
        (phoneNumbers.isEmpty || phoneNumbers.contains(primaryPhone))) {
      return primaryPhone;
    }

    return _firstNonEmpty([
      accountInfo.phoneNumber,
      accountInfo.altPhoneNumber,
      phoneNumbers.isNotEmpty ? phoneNumbers.first : '',
      accountInfo.username,
    ]);
  }

  List<String> _accountPhoneNumbers(AccountInfoModel accountInfo) {
    if (accountInfo.tNs.isNotEmpty) {
      final uniquePhones = <String>{};
      for (final phone in accountInfo.tNs) {
        final trimmed = phone.trim();
        if (trimmed.isNotEmpty) uniquePhones.add(trimmed);
      }
      return uniquePhones.toList();
    }

    final phones = <String>{};
    if (accountInfo.phoneNumber.trim().isNotEmpty) {
      phones.add(accountInfo.phoneNumber.trim());
    }
    if (accountInfo.altPhoneNumber.trim().isNotEmpty) {
      phones.add(accountInfo.altPhoneNumber.trim());
    }

    return phones.toList();
  }

  String _formatPhoneNumber(String value) {
    final trimmed = value.trim();
    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) return trimmed;

    if (digitsOnly.length == 10) {
      return '${digitsOnly.substring(0, 3)}-'
          '${digitsOnly.substring(3, 6)}-'
          '${digitsOnly.substring(6)}';
    }

    if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
      return '${digitsOnly.substring(1, 4)}-'
          '${digitsOnly.substring(4, 7)}-'
          '${digitsOnly.substring(7)}';
    }

    return trimmed;
  }

  String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final text = value?.trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }
}
