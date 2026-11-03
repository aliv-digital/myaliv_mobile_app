import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/services/guest_plan_presentation_mapper.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanAddons/bloc/guest_purchase_plan_add_ons_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanAddons/bloc/guest_purchase_plan_add_ons_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanAddons/bloc/guest_purchase_plan_add_ons_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanAddons/model/add_on_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanAddons/repository/guest_purchase_plan_add_ons_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

class _Repository extends GuestPurchasePlanAddOnsRepository {
  @override
  Future<FairUsePolicy> fetchFairUsePolicy() async =>
      const FairUsePolicy(title: 'fair use policy', description: 'policy');
}

BasePlanModel _catalog(List<String> names) => BasePlanModel.fromApiMap({
  'PlanID': 'primary',
  'PlanName': 'freedom45',
  'PlanType': 'P',
  'Frequency': 'W',
  // Catalog dates must not gate add-ons for a plan about to be purchased.
  'StartDate': '2099-01-01T00:00:00Z',
  'AvailableBoltOns': [
    for (final name in names)
      {
        'PlanID': name,
        'PlanName': name,
        'PlanType': 'S',
        'PlanAmount': 7.27,
        'VATAmount': 0.73,
        'PlanBuckets': [
          {'Name': 'Data', 'Amount': 1, 'Unit': 'GB'},
        ],
      },
  ],
});

void main() {
  for (final (names, expected) in [
    (<String>[], <String>[]),
    (['freedom45 data1', 'freedom45 data10'], <String>[]),
    (
      ['freedom45 data1', 'freedom data1', 'DATA freedom 10 offer'],
      ['freedom data1', 'DATA freedom 10 offer'],
    ),
  ]) {
    final catalog = _catalog(names);
    blocTest<GuestPurchasePlanAddOnsBloc, GuestPurchasePlanAddOnsState>(
      'purchase page filters $names to $expected',
      build: () => GuestPurchasePlanAddOnsBloc(repository: _Repository()),
      act: (bloc) => bloc.add(
        GuestPurchasePlanAddOnsStarted(
          routeArgs: GuestPurchasePlanAddOnsRouteArgs(
            phoneNumber: '2425550100',
            selectedPlan: const GuestPlanPresentationMapper().map(catalog),
            selectedBasePlan: catalog,
          ),
        ),
      ),
      expect: () => [
        isA<GuestPurchasePlanAddOnsState>().having(
          (s) => s.status,
          'loading',
          GuestPurchasePlanAddOnsStatus.loading,
        ),
        isA<GuestPurchasePlanAddOnsState>()
            .having(
              (s) => s.status,
              'ready',
              GuestPurchasePlanAddOnsStatus.ready,
            )
            .having(
              (s) => s.addOns.map((a) => a.title).toList(),
              'allowed add-ons',
              expected,
            )
            .having((s) => s.activePlan?.name, 'selected plan', 'freedom45'),
      ],
      verify: (bloc) {
        for (final item in bloc.state.addOns) {
          expect(item.price, 7.27);
          expect(item.vatAmount, 0.73);
          expect(item.subtitleLabel, 'data balance');
          expect(item.subtitleValue, '1gb');
        }
      },
    );
  }
}
