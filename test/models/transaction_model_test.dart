import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/models/transaction_model.dart';

TransactionModel _makeTransaction({
  DateTime? date,
  String? phoneNumber,
  String type = 'TopUp',
  String plan = 'Prepaid 30',
  double amount = 25.0,
  String channel = 'App',
  String? location,
  String? agent,
  String? promotion,
  String? reason,
  String? reasonDesc,
  String? initiatingOrderId,
  int subId = 0,
  DateTime? planStartDate,
}) {
  return TransactionModel(
    date: date ?? DateTime(2026, 1, 15),
    phoneNumber: phoneNumber,
    type: type,
    plan: plan,
    amount: amount,
    channel: channel,
    location: location,
    agent: agent,
    promotion: promotion,
    reason: reason,
    reasonDesc: reasonDesc,
    initiatingOrderId: initiatingOrderId,
    subId: subId,
    planStartDate: planStartDate,
  );
}

void main() {
  group('TransactionModel', () {
    test('two identical instances are equal', () {
      final date = DateTime(2026, 1, 15);
      final a = _makeTransaction(date: date, amount: 25.0);
      final b = _makeTransaction(date: date, amount: 25.0);
      expect(a, equals(b));
    });

    test('instances differing by amount are not equal', () {
      final date = DateTime(2026, 1, 15);
      final a = _makeTransaction(date: date, amount: 25.0);
      final b = _makeTransaction(date: date, amount: 50.0);
      expect(a, isNot(equals(b)));
    });

    test('instances differing by type are not equal', () {
      final a = _makeTransaction(type: 'TopUp');
      final b = _makeTransaction(type: 'Plan');
      expect(a, isNot(equals(b)));
    });

    test('null optional fields are accepted without error', () {
      expect(
        () => _makeTransaction(
          phoneNumber: null,
          location: null,
          agent: null,
          promotion: null,
          reason: null,
          reasonDesc: null,
          initiatingOrderId: null,
          planStartDate: null,
        ),
        returnsNormally,
      );
    });

    test('isCredit is true for positive amount', () {
      final t = _makeTransaction(amount: 10.0);
      expect(t.isCredit, true);
    });

    test('isCredit is false for zero or negative amount', () {
      expect(_makeTransaction(amount: 0.0).isCredit, false);
      expect(_makeTransaction(amount: -5.0).isCredit, false);
    });

    test('displaySubtitle returns phoneNumber first if set', () {
      final t = _makeTransaction(phoneNumber: '2421234567', plan: 'Plan X');
      expect(t.displaySubtitle, '2421234567');
    });

    test('displaySubtitle falls back to plan when phoneNumber is null', () {
      final t = _makeTransaction(phoneNumber: null, plan: 'Plan X');
      expect(t.displaySubtitle, 'Plan X');
    });

    test('displaySubtitle falls back to channel when phone and plan are empty', () {
      final t = _makeTransaction(phoneNumber: null, plan: '', channel: 'Web');
      expect(t.displaySubtitle, 'Web');
    });

    test('fromJson parses standard fields', () {
      final json = {
        'Date': '2026-01-15T10:00:00Z',
        'Type': 'TopUp',
        'Plan': 'Prepaid 30',
        'Amount': 25.0,
        'Channel': 'App',
        'SubID': 42,
      };
      final t = TransactionModel.fromJson(json);

      expect(t.type, 'TopUp');
      expect(t.plan, 'Prepaid 30');
      expect(t.amount, 25.0);
      expect(t.channel, 'App');
      expect(t.subId, 42);
    });

    test('fromJson handles null optional fields gracefully', () {
      final json = {
        'Date': '2026-01-15T10:00:00Z',
        'Type': 'TopUp',
        'Plan': '',
        'Amount': 0.0,
        'Channel': '',
        'SubID': 0,
      };
      expect(() => TransactionModel.fromJson(json), returnsNormally);
    });
  });
}
