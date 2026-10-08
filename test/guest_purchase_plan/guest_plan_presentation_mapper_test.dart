import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/services/guest_plan_presentation_mapper.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

Map<String, dynamic> _bucket({
  String name = 'data',
  dynamic amount = 5,
  String unit = 'GB',
  String bucketUnit = 'INS_Data',
  dynamic suppress = false,
  dynamic unlimited = false,
}) => <String, dynamic>{
  'Name': name,
  'Amount': amount,
  'Unit': unit,
  'BucketUnit': bucketUnit,
  'Suppress': suppress,
  'Unlimited': unlimited,
};

BasePlanModel _plan({
  String id = '1',
  String name = 'freedom5',
  String description = 'A plan',
  String frequency = 'D',
  dynamic amount = 4.55,
  dynamic vat = 0.45,
  List<Map<String, dynamic>>? buckets,
}) => BasePlanModel.fromApiMap(<String, dynamic>{
  'PlanID': id,
  'PlanName': name,
  'PlanDescription': description,
  'PlanAmount': amount,
  'VATAmount': vat,
  'PlanType': 'P',
  'Frequency': frequency,
  'PlanBuckets': buckets ?? <Map<String, dynamic>>[_bucket()],
});

void main() {
  const mapper = GuestPlanPresentationMapper();

  group('GuestPlanPresentationMapper benefits', () {
    test('maps standard data with the API unit', () {
      final display = mapper.map(_plan());

      expect(display.benefits.single.type, PlanBenefitType.data);
      expect(display.benefits.single.label, 'Data');
      expect(display.benefits.single.value, '5');
      expect(display.benefits.single.sub, 'GB');
      expect(display.benefits.single.displayText, '5 GB Data');
    });

    test('uses the API unlimited flag instead of the numeric amount', () {
      final display = mapper.map(
        _plan(
          buckets: <Map<String, dynamic>>[
            _bucket(amount: 1875, unlimited: true),
          ],
        ),
      );

      expect(display.benefits.single.value, 'Unlimited');
      expect(display.benefits.single.sub, isEmpty);
    });

    test('maps US/Canada minutes from its precise identifier', () {
      final benefit = mapper
          .map(
            _plan(
              buckets: <Map<String, dynamic>>[
                _bucket(
                  name: 'talk',
                  amount: 100,
                  unit: 'Minutes',
                  bucketUnit: 'INS_LDI_US_CANADA',
                ),
              ],
            ),
          )
          .benefits
          .single;

      expect(benefit.type, PlanBenefitType.intlTalkText);
      expect(benefit.displayText, '100 US/Canada minutes');
    });

    test('maps Aliv-to-Aliv messages from its precise identifier', () {
      final benefit = mapper
          .map(
            _plan(
              buckets: <Map<String, dynamic>>[
                _bucket(
                  name: 'ALIV to ALIV mms',
                  amount: 50,
                  unit: 'SMS',
                  bucketUnit: 'INS_MMS_Nat_US',
                ),
              ],
            ),
          )
          .benefits
          .single;

      expect(benefit.type, PlanBenefitType.mms);
      expect(benefit.displayText, '50 Aliv-to-Aliv messages');
    });

    test('maps generic roaming data to a human-readable label', () {
      final benefit = mapper
          .map(
            _plan(
              buckets: <Map<String, dynamic>>[
                _bucket(bucketUnit: 'INS_Data_roam_as_home_v2'),
              ],
            ),
          )
          .benefits
          .single;

      expect(benefit.label, 'Roaming data');
      expect(benefit.sourceIdentifier, 'ins_data_roam_as_home_v2');
    });

    test('filters zero, null-equivalent, empty, and suppressed benefits', () {
      final display = mapper.map(
        _plan(
          buckets: <Map<String, dynamic>>[
            _bucket(amount: 0),
            _bucket(name: '', amount: null, unit: '', bucketUnit: ''),
            _bucket(name: '', amount: 3, unit: '', bucketUnit: ''),
            _bucket(amount: 2, suppress: true),
            _bucket(amount: 3),
          ],
        ),
      );

      expect(display.benefits, hasLength(1));
      expect(display.benefits.single.value, '3');
    });

    test('never exposes raw BucketUnit values as labels', () {
      final display = mapper.map(
        _plan(
          buckets: <Map<String, dynamic>>[
            _bucket(bucketUnit: 'INS_CARIB_DATA'),
            _bucket(bucketUnit: 'INS_UK_EUROPE_DATA'),
            _bucket(bucketUnit: 'INS_LDI_US_CANADA'),
          ],
        ),
      );

      expect(
        display.benefits.map((benefit) => benefit.label.toLowerCase()),
        everyElement(isNot(startsWith('ins_'))),
      );
    });
  });

  group('GuestPlanPresentationMapper RoamEasy', () {
    test('prioritizes the USA/Canada destination allowance', () {
      final display = mapper.map(
        _plan(
          name: 'roameasy usa & can',
          buckets: <Map<String, dynamic>>[
            _bucket(amount: 0.2),
            _bucket(amount: 2, bucketUnit: 'INS_Data_roam_as_home'),
          ],
        ),
        isRoamEasy: true,
      );

      expect(display.destination, 'USA & Canada');
      expect(display.highlights.first.displayText, '2 GB USA & Canada data');
    });

    test('prioritizes the Caribbean destination allowance', () {
      final display = mapper.map(
        _plan(
          name: 'roameasy carib',
          buckets: <Map<String, dynamic>>[
            _bucket(amount: 0.2),
            _bucket(amount: 1.5, bucketUnit: 'INS_Data_Roam_Digicel_Caribbean'),
          ],
        ),
        isRoamEasy: true,
      );

      expect(display.highlights.first.displayText, '1.5 GB Caribbean data');
    });

    test('prioritizes the UK and Europe destination allowance', () {
      final display = mapper.map(
        _plan(
          name: 'roameasy europe',
          buckets: <Map<String, dynamic>>[
            _bucket(amount: 0.1),
            _bucket(amount: 1, bucketUnit: 'INS_Data_roam_UK_Europe'),
          ],
        ),
        isRoamEasy: true,
      );

      expect(display.highlights.first.displayText, '1 GB UK & Europe data');
    });
  });

  group('GuestPlanPresentationMapper plan display', () {
    test('maps B and H frequencies to 14 days', () {
      expect(mapper.map(_plan(frequency: 'B')).subtitle, '14 days');
      expect(mapper.map(_plan(frequency: 'H')).subtitle, '14 days');
    });

    test('maps normal frequency codes to readable durations', () {
      expect(mapper.map(_plan(frequency: 'D')).subtitle, '1 day');
      expect(mapper.map(_plan(frequency: 'W')).subtitle, '7 days');
      expect(mapper.map(_plan(frequency: 'M')).subtitle, '30 days');
    });

    test('formats the VAT-inclusive guest price consistently', () {
      final display = mapper.map(_plan(amount: 4.55, vat: 0.45));

      expect(display.price, 5);
      expect(display.formattedPrice, r'$ 5.00');
      expect(display.basePrice, 4.55);
      expect(display.vatAmount, 0.45);
    });

    test('limits highlights to three and preserves every valid benefit', () {
      final display = mapper.map(
        _plan(
          buckets: <Map<String, dynamic>>[
            _bucket(amount: 1),
            _bucket(amount: 2, bucketUnit: 'INS_Voice_Nat_US'),
            _bucket(amount: 3, bucketUnit: 'INS_SMS_Nat_US'),
            _bucket(amount: 4, bucketUnit: 'INS_LDI_US_CANADA'),
          ],
        ),
      );

      expect(display.highlights, hasLength(3));
      expect(display.benefits, hasLength(4));
    });

    test('preserves backend plan order', () {
      final displays = mapper.mapAll(<BasePlanModel>[
        _plan(id: 'third'),
        _plan(id: 'first'),
        _plan(id: 'second'),
      ]);

      expect(displays.map((plan) => plan.id), <String>[
        'third',
        'first',
        'second',
      ]);
    });

    test('strips HTML from fallback plan details', () {
      final plan = BasePlanModel.fromApiMap(<String, dynamic>{
        'PlanID': 'html',
        'PlanName': 'html plan',
        'PlanDescription': '',
        'PlanDetails': '<p>First &amp; second<br>line</p>',
        'PlanAmount': 5,
        'Frequency': 'D',
      });

      expect(mapper.map(plan).description, 'First & second\nline');
    });
  });
}
