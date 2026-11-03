import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/bundle_response_parser.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plans_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_api_service.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_cache_service.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_parser_service.dart';

class _Api extends Mock implements PlanApiService {}

class _Storage extends Mock implements Storage {}

Map<String, dynamic> _item(
  String name, {
  String type = 'P',
  String frequency = 'M',
  String group = '',
  String payment = 'PrePay',
}) => {
  'PlanID': name,
  'PlanName': name,
  'PlanType': type,
  'Frequency': frequency,
  'PlanGroup': group,
  'PaymentOption': payment,
  'PlanAmount': 10,
  'VATAmount': 1,
  'PlanBuckets': [
    {'Name': 'Data', 'Amount': 2, 'Unit': 'GB'},
  ],
};

List<Map<String, dynamic>> _catalogue() => [
  _item('freedom5', frequency: 'D'),
  _item('freedom50', frequency: 'D'),
  _item('freedom45', frequency: 'W'),
  _item('freedom35', frequency: 'W'),
  _item('liberty70'),
  _item(r'liberty40 bundle for $90'),
  _item('roam50 14-day', type: 'A', group: 'roaming'),
  _item('roam500', type: 'A', group: 'roaming'),
  _item('roameasy usa & can', type: 'A', group: 'roameasy'),
  _item('roameasy20', type: 'A', group: 'roameasy'),
  _item('mifi90', group: 'mifi (30 day)'),
  _item('mifi150', group: 'mifi (30 day)'),
  _item('liberty global Haiti', type: 'A', group: 'liberty global'),
  _item('global20', type: 'A', group: 'liberty global'),
  _item('travel20 7-day', type: 'A', group: 'roaming', payment: 'PostPay'),
  _item('travel200', type: 'A', group: 'roaming', payment: 'PostPay'),
];

void main() {
  late _Api api;
  late PlanCacheService cache;
  late PlansRepository repository;

  setUp(() {
    api = _Api();
    cache = PlanCacheService();
    repository = PlansRepository(apiService: api, cacheService: cache);
    final storage = _Storage();
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.write(any(), any())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  test(
    'authenticated fresh and cached catalogues filter all eight categories',
    () async {
      when(
        () => api.fetchRawPlansJson(),
      ).thenAnswer((_) async => jsonEncode(_catalogue()));
      final result = await repository.fetchCategorizedPlans();
      final cached = await repository.fetchCategorizedPlans();
      for (final category in PlanCategory.values.where(
        (category) => category != PlanCategory.unknown,
      )) {
        expect(result.getCategoryCount(category), 1, reason: category.name);
        expect(cached.getCategoryCount(category), 1, reason: category.name);
      }
      expect(result.monthlyPlans.single.planAmount, 10);
      expect(result.monthlyPlans.single.vatAmount, 1);
      expect(result.roamingPlans.single.planName, 'roam50 14-day');
      expect(result.postpaidRoamingPlans.single.planName, 'travel20 7-day');
      expect(cache.getCategorizedPlans()!.monthlyPlans, hasLength(2));
      expect(repository.getCachedResult()!.monthlyPlans, hasLength(1));
      verify(() => api.fetchRawPlansJson()).called(1);
    },
  );

  test(
    'cache visibility is false when the category contains only rejected products',
    () async {
      cache.setCategorizedPlans(
        await PlanParserService().parseAndCategorize([
          _item('freedom35', frequency: 'W'),
        ]),
      );
      expect(repository.hasCachedDataForCategory(PlanCategory.weekly), isFalse);
      expect((await repository.fetchCategorizedPlans()).weeklyPlans, isEmpty);
      verifyZeroInteractions(api);
    },
  );

  test(
    'hydrated catalogues are filtered before restored plans are displayed',
    () async {
      final raw = await PlanParserService().parseAndCategorize(_catalogue());
      final original = PlansState(
        status: PlansStatus.success,
        dailyApiPlans: raw.dailyPlans,
        weeklyApiPlans: raw.weeklyPlans,
        monthlyApiPlans: raw.monthlyPlans,
        roamingApiPlans: raw.roamingPlans,
        roamEasyApiPlans: raw.roamEasyPlans,
        mifiApiPlans: raw.mifiPlans,
        libertyGlobalApiPlans: raw.libertyGlobalPlans,
        postpaidRoamingApiPlans: raw.postpaidRoamingPlans,
        lastFetchedAt: DateTime.utc(2026, 11, 4),
      );
      final cubit = PlansCubit(repository: repository);
      addTearDown(cubit.close);
      final restored = cubit.fromJson(original.toJson())!;
      for (final list in [
        restored.dailyApiPlans,
        restored.weeklyApiPlans,
        restored.monthlyApiPlans,
        restored.roamingApiPlans,
        restored.roamEasyApiPlans,
        restored.mifiApiPlans,
        restored.libertyGlobalApiPlans,
        restored.postpaidRoamingApiPlans,
      ]) {
        expect(list, hasLength(1));
      }
      expect(restored.lastFetchedAt, original.lastFetchedAt);
      expect(raw.monthlyPlans, hasLength(2));
    },
  );

  Map<String, dynamic> primary({
    String id = 'primary',
    String name = 'liberty70',
    int startsIn = -1,
    int endsIn = 7,
    String addonName = 'liberty data1',
  }) => {
    ..._item(name),
    'PlanID': id,
    'StartDate': DateTime.now().add(Duration(days: startsIn)).toIso8601String(),
    'EndDate': DateTime.now().add(Duration(days: endsIn)).toIso8601String(),
    'AvailableBoltOns': [
      _item(addonName, type: 'S'),
      _item('liberty70 data1', type: 'S'),
    ],
  };

  test(
    'bundle filtering retains owned plans and reads cached bundles safely',
    () async {
      final bundles = {
        'PrimaryPlans': [
          primary(id: 'expired', startsIn: -30, endsIn: -1),
          primary(),
          primary(id: 'future', startsIn: 10, endsIn: 40),
        ],
        'SecondaryPlans': [_item('old addon', type: 'S')],
        'StandAlonePlans': [_item('old roaming', type: 'A')],
      };
      when(
        () => api.fetchRawBundlesJson(),
      ).thenAnswer((_) async => jsonEncode(bundles));
      final raw = BundleResponseParser.parse(bundles);
      for (final result in [
        await repository.fetchAddOnsData(),
        await repository.fetchAddOnsData(),
      ]) {
        expect(result.addOns.map((a) => a.title), ['liberty data1']);
        expect(result.addOns.single.price, 10);
        expect(result.addOns.single.vatAmount, 1);
        expect(
          result.primaryPlans.map((p) => p.toJson()),
          raw.primaryPlans.map((p) => p.toJson()),
        );
        expect(
          result.secondaryPlans.map((p) => p.toJson()),
          raw.secondaryPlans.map((p) => p.toJson()),
        );
        expect(
          result.standAlonePlans.map((p) => p.toJson()),
          raw.standAlonePlans.map((p) => p.toJson()),
        );
      }
      verify(() => api.fetchRawBundlesJson()).called(1);
    },
  );

  for (final scenario in ['no primary', 'expired', 'future', 'no matches']) {
    test('bundles hide add-ons with $scenario', () async {
      cache.setBundles({
        'PrimaryPlans': switch (scenario) {
          'no primary' => [],
          'expired' => [primary(startsIn: -30, endsIn: -1)],
          'future' => [primary(startsIn: 10, endsIn: 40)],
          _ => [primary(addonName: 'liberty70 data10')],
        },
      });
      expect((await repository.fetchAddOnsData()).addOns, isEmpty);
      verifyZeroInteractions(api);
    });
  }

  test(
    'restored add-ons are rebuilt from the active primary, never stale display rows',
    () {
      final current = BasePlanModel.fromApiMap(primary());
      final original = PlansState(
        addOnsApiPrimaryPlans: [current],
        selectedAddOnIds: const {'removed-addon'},
      );
      final cubit = PlansCubit(repository: repository);
      addTearDown(cubit.close);
      final restored = cubit.fromJson(original.toJson())!;
      expect(restored.addOns.map((a) => a.title), ['liberty data1']);
      expect(restored.selectedAddOnIds, isEmpty);
      expect(restored.addOnsApiPrimaryPlans.single.toJson(), current.toJson());
      expect(restored.addOnsPrimaryPlan!.planId, current.planId);
    },
  );

  test(
    'primary replacement filters optimistic add-ons and clears hidden selections',
    () async {
      final cubit = PlansCubit(repository: repository);
      addTearDown(cubit.close);
      final current = BasePlanModel.fromApiMap(primary());
      cubit.injectOptimisticPrimaryPlanChange(
        plan: current,
        addOns: const [],
        purchasedAt: DateTime.now(),
      );
      expect(cubit.state.addOns.map((a) => a.title), ['liberty data1']);
      cubit.toggleAddon(cubit.state.addOns.single);
      expect(cubit.state.selectedAddOnIds, {'liberty data1'});
      final hidden = BundleResponseParser.parse({
        'PrimaryPlans': [primary(addonName: 'liberty70 data10')],
      }).addOns.first;
      cubit.toggleAddon(hidden);
      expect(cubit.state.selectedAddOnIds, {'liberty data1'});
      cubit.injectOptimisticPrimaryPlanChange(
        plan: BasePlanModel.fromApiMap(
          primary(id: 'replacement', addonName: 'liberty70 data10'),
        ),
        addOns: const [],
        purchasedAt: DateTime.now(),
      );
      expect(cubit.state.addOns, isEmpty);
      expect(cubit.state.selectedAddOnIds, isEmpty);
      expect(cubit.state.optimisticActivePlan!.planId, 'replacement');
      expect(cubit.state.effectiveSecondaryPlans, isEmpty);
    },
  );
}
