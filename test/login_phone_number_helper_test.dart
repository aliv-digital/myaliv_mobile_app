import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/model/login_country_selection.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/login_phone_number_helper.dart';

void main() {
  group('LoginPhoneNumberHelper Bahamas validation', () {
    const helper = LoginPhoneNumberHelper();
    const bahamas = LoginCountrySelection.defaultBahamas;

    test('accepts formatted 10 digit Bahamas local numbers', () {
      final result = helper.validateAndBuildApiUsername(
        rawPhoneNumber: '(242) 345-4356',
        selectedCountry: bahamas,
      );

      expect(result.isValid, isTrue);
      expect(result.phoneNumberForApi, '2423454356');
    });

    test('accepts 7 digit Bahamas subscriber numbers', () {
      final result = helper.validateAndBuildApiUsername(
        rawPhoneNumber: '3454356',
        selectedCountry: bahamas,
      );

      expect(result.isValid, isTrue);
      expect(result.phoneNumberForApi, '2423454356');
    });

    test('does not show live error for valid Bahamas subscriber numbers', () {
      final hasError = helper.hasLiveValidationError(
        rawPhoneNumber: '3454356',
        selectedCountry: bahamas,
      );

      expect(hasError, isFalse);
    });

    test('rejects Bahamas numbers that are not 7 or 10 local digits', () {
      final result = helper.validateAndBuildApiUsername(
        rawPhoneNumber: '34543567',
        selectedCountry: bahamas,
      );

      expect(result.isValid, isFalse);
    });

    test('rejects 10 digit Bahamas numbers without the 242 area code', () {
      final result = helper.validateAndBuildApiUsername(
        rawPhoneNumber: '1234567890',
        selectedCountry: bahamas,
      );

      expect(result.isValid, isFalse);
    });
  });
}
