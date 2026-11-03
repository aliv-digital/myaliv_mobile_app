import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/repository/guest_purchase_plan_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_parser_service.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/bundle_response_parser.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_visibility_filter.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class _FakeNetworkService extends NetworkService {
  _FakeNetworkService(this.responseData)
    : super(authManager: AuthManager(), onHardLogout: _noopLogout);

  final dynamic responseData;
  int requestCount = 0;
  String? requestedPath;
  HttpMethod? requestedMethod;
  dynamic requestedData;
  Options? requestedOptions;

  static Future<void> _noopLogout() async {}

  @override
  Future<Response<T>> request<T>(
    String path, {
    required HttpMethod method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    String? requestId,
  }) async {
    requestCount++;
    requestedPath = path;
    requestedMethod = method;
    requestedData = data;
    requestedOptions = options;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: responseData as T,
    );
  }
}

Map<String, dynamic> _plan({
  String id = '27129',
  String name = 'freedom30',
  String type = 'P',
  String frequency = 'M',
  String group = '',
}) {
  return <String, dynamic>{
    'PlanID': id,
    'PlanName': name,
    'PlanDescription': '30-day plan',
    'PlanAmount': 30,
    'VATAmount': '3.00',
    'PlanType': type,
    'Frequency': frequency,
    'PaymentOption': 'PrePay',
    'PlanGroup': group,
    'PlanBuckets': <Map<String, dynamic>>[
      <String, dynamic>{
        'Name': 'Data',
        'Amount': 14,
        'Unit': 'GB',
        'BucketUnit': 'GB',
        'Suppress': false,
        'Unlimited': false,
      },
    ],
  };
}

void main() {
  group('guest existing-plan add-ons filter', () {
    test(
      'accepts reordered names without changing plan data or shared parsing',
      () async {
        final now = DateTime.now();
        final bundles = {
          'PrimaryPlans': [
            {
              ..._plan(),
              'StartDate': now
                  .subtract(const Duration(days: 1))
                  .toIso8601String(),
              'EndDate': now.add(const Duration(days: 1)).toIso8601String(),
              'AvailableBoltOns': [
                _plan(id: 'allowed', name: 'data 10 freedom offer', type: 'S'),
                _plan(id: 'hidden', name: 'travel data1', type: 'S'),
              ],
            },
          ],
          'SecondaryPlans': [_plan(id: 'secondary', type: 'S')],
          'StandAlonePlans': [_plan(id: 'standalone', type: 'A')],
        };
        final network = _FakeNetworkService(bundles);
        final repository = GuestPurchasePlanRepository(
          phoneNumber: '(242) 555-0100',
          networkService: network,
        );
        final shared = BundleResponseParser.parse(bundles);
        final result = await repository.fetchExistingBundles();

        expect(result.addOns.single.id, 'allowed');
        expect(result.addOns.single.title, 'data 10 freedom offer');
        expect(result.addOns.single.price, 30);
        expect(result.addOns.single.vatAmount, 3);
        expect(
          result.primaryPlans.map((p) => p.toJson()),
          shared.primaryPlans.map((p) => p.toJson()),
        );
        expect(
          result.secondaryPlans.map((p) => p.toJson()),
          shared.secondaryPlans.map((p) => p.toJson()),
        );
        expect(
          result.standAlonePlans.map((p) => p.toJson()),
          shared.standAlonePlans.map((p) => p.toJson()),
        );
        expect(BundleResponseParser.parse(bundles).addOns.single.id, 'hidden');
        expect(network.requestCount, 1);
        expect(network.requestedPath, Api.guestExistingPlansUrl);
        expect(network.requestedMethod, HttpMethod.post);
        expect(network.requestedData, {
          'ChannelType': 'SelfCare',
          'PhoneNumber': '2425550100',
        });
        expect(network.requestedOptions?.extra?['skipAuth'], isTrue);
      },
    );

    test(
      'returns no add-ons when only secondary or standalone plans exist',
      () async {
        final repository = GuestPurchasePlanRepository(
          phoneNumber: '2425550100',
          networkService: _FakeNetworkService({
            'PrimaryPlans': [],
            'SecondaryPlans': [_plan(type: 'S')],
            'StandAlonePlans': [_plan(type: 'A')],
          }),
        );
        final result = await repository.fetchExistingBundles();
        expect(result.addOns, isEmpty);
        expect(result.secondaryPlans, hasLength(1));
        expect(result.standAlonePlans, hasLength(1));
      },
    );
  });

  group('guest available plans', () {
    test('parses API fields into BasePlanModel', () {
      final plan = BasePlanModel.fromApiMap(_plan());

      expect(plan.planId, '27129');
      expect(plan.planAmount, 30);
      expect(plan.vatAmount, 3);
      expect(plan.planBuckets.single.name, 'Data');
      expect(plan.planBuckets.single.amount, 14);
    });

    test('uses API plan type semantics', () {
      expect(BasePlanModel.fromApiMap(_plan(type: 'P')).isPrimaryPlan, isTrue);
      expect(BasePlanModel.fromApiMap(_plan(type: 'S')).isAddOnPlan, isTrue);
      expect(
        BasePlanModel.fromApiMap(_plan(type: 'A')).isStandAlonePlan,
        isTrue,
      );
    });

    test(
      'reuses authorized-user categorization and visibility rules',
      () async {
        final result = await PlanParserService()
            .parseAndCategorize(<Map<String, dynamic>>[
              _plan(),
              _plan(id: 'hidden', name: 'BMP 30-day'),
              _plan(
                id: 'roaming',
                name: 'Roaming Pass',
                type: 'A',
                frequency: 'D',
                group: 'Roaming',
              ),
            ]);

        expect(
          PlanVisibilityFilter.visibleBasePlans(
            result.monthlyPlans,
          ).map((plan) => plan.planId),
          <String>['27129'],
        );
        expect(result.roamingPlans.single.planId, 'roaming');
      },
    );

    test('requests and caches the unauthenticated guest catalogue', () async {
      final network = _FakeNetworkService(<Map<String, dynamic>>[
        _plan(),
        _plan(id: 'weekly', name: 'freedom8', frequency: 'W'),
      ]);
      final repository = GuestPurchasePlanRepository(
        phoneNumber: '(242) 555-0100',
        networkService: network,
      );

      expect(
        (await repository.fetchPlans(tab: PlanTab.monthly)).single.id,
        '27129',
      );
      expect(
        (await repository.fetchPlans(tab: PlanTab.weekly)).single.id,
        'weekly',
      );

      expect(network.requestCount, 1);
      expect(network.requestedPath, Api.guestAvailablePlansUrl);
      expect(network.requestedMethod, HttpMethod.post);
      expect(network.requestedData, <String, dynamic>{
        'RedirectURL': 'myaliv://topup-callback',
        'ChannelType': 'SelfCare',
        'Branch': 'branch',
        'PhoneNumber': '2425550100',
      });
      expect((network.requestedData as Map).containsKey('Amount'), isFalse);
      expect(network.requestedOptions?.extra?['skipAuth'], isTrue);
    });
  });
}
