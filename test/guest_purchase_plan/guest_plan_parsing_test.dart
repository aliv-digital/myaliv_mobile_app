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
    test(
      'liberty global keeps only listed destinations and API prices',
      () async {
        const names = [
          'liberty global Caribbean',
          'liberty global China',
          'liberty global Europe',
          'liberty global Haiti',
        ];
        final raw = [
          for (final name in names)
            {
              ..._plan(
                id: name,
                name: name,
                type: 'A',
                group: 'liberty global',
              ),
              'PlanAmount': name == names.last ? 10 : 21,
            },
          _plan(
            id: 'hidden',
            name: 'global20',
            type: 'A',
            group: 'liberty global',
          ),
          _plan(
            id: 'bundle',
            name: 'liberty global Caribbean bundle',
            type: 'A',
            group: 'liberty global',
          ),
        ];
        final network = _FakeNetworkService(raw);
        final repository = GuestPurchasePlanRepository(
          phoneNumber: '2425550100',
          networkService: network,
        );
        final result = await repository.fetchPlans(tab: PlanTab.libertyGlobal);
        expect(result.map((plan) => plan.title), unorderedEquals(names));
        for (final name in names) {
          final plan = result.singleWhere((plan) => plan.id == name);
          expect(plan.basePrice, name == names.last ? 10 : 21);
          expect(plan.vatAmount, 3);
          expect(plan.price, plan.basePrice + 3);
        }
        final shared = await PlanParserService().parseAndCategorize(raw);
        expect(
          result.map((plan) => plan.id),
          shared.libertyGlobalPlans
              .where(
                (plan) => plan.planId != 'hidden' && plan.planId != 'bundle',
              )
              .map((plan) => plan.planId),
        );
        expect(shared.libertyGlobalPlans, hasLength(6));
        expect(
          await repository.fetchEmptyPlanTabs(),
          isNot(contains(PlanTab.libertyGlobal)),
        );
        expect(network.requestCount, 1);
      },
    );

    test(
      'roameasy keeps only listed destinations and preserves API pricing',
      () async {
        const names = [
          'roameasy usa & can',
          'roameasy carib',
          'roameasy europe',
        ];
        final raw = [
          for (final name in names)
            {
              ..._plan(id: name, name: name, type: 'A', group: 'roameasy'),
              'PlanAmount': name == names.first ? 30 : 25,
            },
          _plan(id: 'hidden', name: 'roameasy20', type: 'A', group: 'roameasy'),
          _plan(
            id: 'bundle',
            name: 'roameasy europe bundle',
            type: 'A',
            group: 'roameasy',
          ),
        ];
        final network = _FakeNetworkService(raw);
        final repository = GuestPurchasePlanRepository(
          phoneNumber: '2425550100',
          networkService: network,
        );
        final result = await repository.fetchPlans(tab: PlanTab.roameasy);
        expect(result.map((plan) => plan.title), unorderedEquals(names));
        expect(
          result.singleWhere((plan) => plan.id == names.first).basePrice,
          30,
        );
        expect(result.singleWhere((plan) => plan.id == names[1]).basePrice, 25);
        expect(result.singleWhere((plan) => plan.id == names[2]).basePrice, 25);
        expect(result.map((plan) => plan.vatAmount), [3, 3, 3]);
        final shared = await PlanParserService().parseAndCategorize(raw);
        expect(
          result.map((plan) => plan.id),
          shared.roamEasyPlans
              .where(
                (plan) => plan.planId != 'hidden' && plan.planId != 'bundle',
              )
              .map((plan) => plan.planId),
        );
        expect(shared.roamEasyPlans, hasLength(5));
        expect(
          await repository.fetchEmptyPlanTabs(),
          isNot(contains(PlanTab.roameasy)),
        );
        expect(network.requestCount, 1);
      },
    );

    test('roaming keeps only the three listed standalone plans', () async {
      final raw = [
        for (final name in ['roam50', 'roam30', 'roam20'])
          {
            ..._plan(
              id: name,
              name: name,
              type: 'A',
              frequency: 'W',
              group: 'Roaming',
            ),
            'PlanAmount': int.parse(name.substring(4)),
          },
        _plan(id: 'hidden', name: 'roam500', type: 'A', group: 'Roaming'),
        _plan(id: 'bundle', name: 'roam20 bundle', type: 'A', group: 'Roaming'),
        _plan(
          id: 'roameasy',
          name: 'roameasy carib',
          type: 'A',
          group: 'roameasy',
        ),
        _plan(
          id: 'global',
          name: 'liberty global Haiti',
          type: 'A',
          group: 'liberty global',
        ),
      ];
      final network = _FakeNetworkService(raw);
      final repository = GuestPurchasePlanRepository(
        phoneNumber: '2425550100',
        networkService: network,
      );
      final result = await repository.fetchPlans(tab: PlanTab.roaming);
      expect(result.map((plan) => plan.id), ['roam50', 'roam30', 'roam20']);
      expect(result.map((plan) => plan.basePrice), [50, 30, 20]);
      expect(result.map((plan) => plan.vatAmount), [3, 3, 3]);
      expect(
        (await repository.fetchPlans(tab: PlanTab.roameasy)).single.id,
        'roameasy',
      );
      expect(
        (await repository.fetchPlans(tab: PlanTab.libertyGlobal)).single.id,
        'global',
      );
      expect(
        await repository.fetchEmptyPlanTabs(),
        isNot(contains(PlanTab.roaming)),
      );
      expect(network.requestCount, 1);
      final shared = await PlanParserService().parseAndCategorize(raw);
      expect(shared.roamingPlans, hasLength(5));
    });

    test(
      'MiFi keeps only listed mifi and tab plans with API pricing and ordering',
      () async {
        const names = [
          'mifi140',
          'mifi90',
          'mifi75',
          'tab140',
          'tab90',
          'tab75',
        ];
        final raw = [
          for (final name in names)
            {
              ..._plan(id: name, name: name, group: 'mifi (30 day)'),
              'PlanAmount': name == 'tab75' ? 90 : 75,
            },
          _plan(id: 'hidden', name: 'mifi150', group: 'mifi (30 day)'),
          _plan(id: 'bundle', name: 'tab90 bundle', group: 'mifi (30 day)'),
        ];
        final network = _FakeNetworkService(raw);
        final repository = GuestPurchasePlanRepository(
          phoneNumber: '2425550100',
          networkService: network,
        );
        final result = await repository.fetchPlans(tab: PlanTab.mifi);
        expect(result.map((plan) => plan.title), unorderedEquals(names));
        expect(result.singleWhere((plan) => plan.id == 'tab75').basePrice, 90);
        expect(result.singleWhere((plan) => plan.id == 'tab75').vatAmount, 3);
        final shared = await PlanParserService().parseAndCategorize(raw);
        expect(
          result.map((plan) => plan.id),
          shared.mifiPlans
              .where(
                (plan) => plan.planId != 'hidden' && plan.planId != 'bundle',
              )
              .map((plan) => plan.planId),
        );
        expect(shared.mifiPlans, hasLength(8));
        expect(
          await repository.fetchEmptyPlanTabs(),
          isNot(contains(PlanTab.mifi)),
        );
        expect(network.requestCount, 1);
      },
    );

    test('filters only the guest daily, weekly and monthly lists', () async {
      final raw = [
        _plan(id: 'daily', name: 'freedom5', frequency: 'D'),
        _plan(id: 'hidden-daily', name: 'freedom50', frequency: 'D'),
        _plan(id: 'weekly', name: 'freedom45', frequency: 'W'),
        _plan(id: 'hidden-weekly', name: 'freedom35', frequency: 'W'),
        _plan(id: 'monthly', name: ' LIBERTY 40 '),
        _plan(id: 'bundle', name: r'liberty40 bundle for $90'),
        _plan(
          id: 'roaming',
          name: 'roam20',
          type: 'A',
          frequency: 'D',
          group: 'Roaming',
        ),
      ];
      final network = _FakeNetworkService(raw);
      final repository = GuestPurchasePlanRepository(
        phoneNumber: '2425550100',
        networkService: network,
      );
      for (final (tab, expectedId) in [
        (PlanTab.daily, 'daily'),
        (PlanTab.weekly, 'weekly'),
        (PlanTab.monthly, 'monthly'),
        (PlanTab.roaming, 'roaming'),
      ]) {
        final display = (await repository.fetchPlans(tab: tab)).single;
        expect(display.id, expectedId);
        expect(display.basePrice, 30);
        expect(display.vatAmount, 3);
        expect(display.price, 33);
      }
      final empty = await repository.fetchEmptyPlanTabs();
      expect(empty, isNot(contains(PlanTab.daily)));
      expect(empty, isNot(contains(PlanTab.weekly)));
      expect(empty, isNot(contains(PlanTab.monthly)));
      expect(network.requestCount, 1);
      expect(repository.findBasePlanById('weekly')?.availableBoltOns, isEmpty);
      expect(
        repository.findBasePlanById('hidden-weekly')?.planName,
        'freedom35',
      );
      // Shared parsing retains other products for authenticated flows.
      final shared = await PlanParserService().parseAndCategorize(raw);
      expect(shared.dailyPlans, hasLength(2));
      expect(shared.weeklyPlans, hasLength(2));
      expect(shared.monthlyPlans, hasLength(2));
    });

    test(
      'empty tab metadata uses the same guest allowlists as the rows',
      () async {
        final network = _FakeNetworkService([
          _plan(name: 'freedom50', frequency: 'D'),
          _plan(name: 'freedom35', frequency: 'W'),
          _plan(name: r'liberty40 bundle for $90'),
          _plan(name: 'mifi150', group: 'mifi (30 day)'),
          _plan(name: 'roam500', type: 'A', group: 'Roaming'),
          _plan(name: 'roameasy20', type: 'A', group: 'roameasy'),
          _plan(name: 'global20', type: 'A', group: 'liberty global'),
        ]);
        final repository = GuestPurchasePlanRepository(
          phoneNumber: '2425550100',
          networkService: network,
        );
        expect(
          await repository.fetchEmptyPlanTabs(),
          containsAll([
            PlanTab.daily,
            PlanTab.weekly,
            PlanTab.monthly,
            PlanTab.mifi,
            PlanTab.roaming,
            PlanTab.roameasy,
            PlanTab.libertyGlobal,
          ]),
        );
        for (final tab in [
          PlanTab.daily,
          PlanTab.weekly,
          PlanTab.monthly,
          PlanTab.mifi,
          PlanTab.roaming,
          PlanTab.roameasy,
          PlanTab.libertyGlobal,
        ]) {
          expect(await repository.fetchPlans(tab: tab), isEmpty);
        }
        expect(network.requestCount, 1);
      },
    );

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
        _plan(name: 'liberty70'),
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
