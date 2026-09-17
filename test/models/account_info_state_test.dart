import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';

AccountInfoModel _makeAccount({
  String fName = 'John',
  String lName = 'Doe',
  String email = 'john@example.com',
  String paymentOption = 'PrePay',
  String accountStatus = 'Active',
  bool autoPayInvoice = false,
}) {
  return AccountInfoModel(
    fName: fName,
    lName: lName,
    email: email,
    paymentOption: paymentOption,
    accountStatus: accountStatus,
    autoPayInvoice: autoPayInvoice,
  );
}

void main() {
  group('AccountInfoState', () {
    test('initial state has no account and initial status', () {
      const state = AccountInfoState();
      expect(state.hasAccount, false);
      expect(state.status, AccountInfoStatus.initial);
      expect(state.accountInfo, isNull);
      expect(state.lastFetchedAt, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isTogglingAutoPayInvoice, false);
    });

    test('hasAccount is true when accountInfo is set', () {
      final state = AccountInfoState(accountInfo: _makeAccount());
      expect(state.hasAccount, true);
    });

    test('hasAccount is false when accountInfo is null', () {
      const state = AccountInfoState();
      expect(state.hasAccount, false);
    });

    test('isPrepaid returns true for PrePay paymentOption', () {
      final state = AccountInfoState(
        accountInfo: _makeAccount(paymentOption: 'PrePay'),
      );
      expect(state.isPrepaid, true);
      expect(state.isPostpaid, false);
    });

    test('isPostpaid returns true for PostPay paymentOption', () {
      final state = AccountInfoState(
        accountInfo: _makeAccount(paymentOption: 'PostPay'),
      );
      expect(state.isPostpaid, true);
      expect(state.isPrepaid, false);
    });

    test('email getter delegates to accountInfo', () {
      final state = AccountInfoState(
        accountInfo: _makeAccount(email: 'test@aliv.com'),
      );
      expect(state.email, 'test@aliv.com');
    });

    test('email getter returns null when no accountInfo', () {
      const state = AccountInfoState();
      expect(state.email, isNull);
    });

    test('fullName concatenates first and last name', () {
      final state = AccountInfoState(
        accountInfo: _makeAccount(fName: 'Jane', lName: 'Smith'),
      );
      expect(state.fullName, 'Jane Smith');
    });

    test('fullName returns null when no accountInfo', () {
      const state = AccountInfoState();
      expect(state.fullName, isNull);
    });

    test('fullName trims when one name is empty', () {
      final state = AccountInfoState(
        accountInfo: _makeAccount(fName: 'Jane', lName: ''),
      );
      expect(state.fullName, 'Jane');
    });

    test('isCacheStale is true when lastFetchedAt is null', () {
      const state = AccountInfoState();
      expect(state.isCacheStale(), true);
    });

    test('isCacheStale is false when fetched recently', () {
      final state = AccountInfoState(lastFetchedAt: DateTime.now());
      expect(state.isCacheStale(), false);
    });

    test('isCacheStale is true when TTL is exceeded', () {
      final state = AccountInfoState(
        lastFetchedAt: DateTime.now().subtract(const Duration(hours: 25)),
      );
      expect(state.isCacheStale(), true);
    });

    test('isCacheStale respects custom TTL', () {
      final state = AccountInfoState(
        lastFetchedAt: DateTime.now().subtract(const Duration(hours: 13)),
      );
      expect(state.isCacheStale(ttl: const Duration(hours: 12)), true);
      expect(state.isCacheStale(ttl: const Duration(hours: 24)), false);
    });

    test('cleared() resets all fields to initial', () {
      final state = AccountInfoState(
        status: AccountInfoStatus.success,
        accountInfo: _makeAccount(),
        lastFetchedAt: DateTime.now(),
        errorMessage: 'oops',
        isTogglingAutoPayInvoice: true,
      );
      final cleared = state.cleared();

      expect(cleared.status, AccountInfoStatus.initial);
      expect(cleared.accountInfo, isNull);
      expect(cleared.lastFetchedAt, isNull);
      expect(cleared.errorMessage, isNull);
      expect(cleared.isTogglingAutoPayInvoice, false);
    });

    test('two states with same accountInfo are equal', () {
      final account = _makeAccount();
      final a = AccountInfoState(status: AccountInfoStatus.success, accountInfo: account);
      final b = AccountInfoState(status: AccountInfoStatus.success, accountInfo: account);
      expect(a, equals(b));
    });

    test('states differing by status are not equal', () {
      final account = _makeAccount();
      final a = AccountInfoState(status: AccountInfoStatus.loading, accountInfo: account);
      final b = AccountInfoState(status: AccountInfoStatus.success, accountInfo: account);
      expect(a, isNot(equals(b)));
    });

    test('copyWith only changes provided fields', () {
      final original = AccountInfoState(
        status: AccountInfoStatus.success,
        accountInfo: _makeAccount(),
        lastFetchedAt: DateTime(2026, 1, 1),
      );
      final updated = original.copyWith(status: AccountInfoStatus.refreshing);

      expect(updated.status, AccountInfoStatus.refreshing);
      expect(updated.accountInfo, original.accountInfo);
      expect(updated.lastFetchedAt, original.lastFetchedAt);
    });

    group('toJson / fromJson', () {
      test('round-trips state with accountInfo', () {
        final original = AccountInfoState(
          status: AccountInfoStatus.success,
          accountInfo: _makeAccount(email: 'roundtrip@test.com'),
          lastFetchedAt: DateTime(2026, 6, 15, 12, 0, 0),
          errorMessage: null,
        );
        final json = original.toJson();
        final restored = AccountInfoState.fromJson(json);

        expect(restored.status, original.status);
        expect(restored.email, 'roundtrip@test.com');
        expect(restored.lastFetchedAt?.year, 2026);
      });

      test('round-trips empty state', () {
        const original = AccountInfoState();
        final json = original.toJson();
        final restored = AccountInfoState.fromJson(json);

        expect(restored.status, AccountInfoStatus.initial);
        expect(restored.accountInfo, isNull);
        expect(restored.lastFetchedAt, isNull);
      });
    });
  });
}
