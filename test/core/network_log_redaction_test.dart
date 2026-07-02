import 'package:core/src/network/network_interceptors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('redacts configured fields recursively without mutating input', () {
    final input = <String, dynamic>{
      'Number': '4111111111111111',
      'Name': 'Demo Visa User',
      'ExpirationMonth': 12,
      'SecurityCode': '456',
      'response': <String, dynamic>{'Token': 'secret-token'},
    };

    final redacted = redactNetworkLogData(
      input,
      const <String>['Number', 'Name', 'SecurityCode', 'Token'],
    ) as Map;

    expect(redacted['Number'], '<redacted>');
    expect(redacted['Name'], '<redacted>');
    expect(redacted['SecurityCode'], '<redacted>');
    expect((redacted['response'] as Map)['Token'], '<redacted>');
    expect(redacted['ExpirationMonth'], 12);
    expect(input['Number'], '4111111111111111');
  });

  test('redacts configured fields from JSON string bodies', () {
    final redacted = redactNetworkLogData(
      '{"Token":"secret-token","Success":true}',
      const <String>['Token'],
    ) as Map;

    expect(redacted['Token'], '<redacted>');
    expect(redacted['Success'], isTrue);
  });
}
