import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/services/guest_plan_presentation_mapper.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/models/guest_purchase_plan_confirmation_models.dart'
    as primary;
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/repository/guest_purchase_plan_confirmation_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/widgets/purchase_item_row.dart'
    as primary_row;
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/roamingPlanConfirmation/models/roaming_plan_confirmation_models.dart'
    as roaming;
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/roamingPlanConfirmation/repository/roaming_plan_confirmation_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/roamingPlanConfirmation/widgets/purchase_summary_card.dart'
    as roaming_card;
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/roamingPlanConfirmation/widgets/purchase_item_row.dart'
    as roaming_row;
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/addOnsConfirmation/models/add_ons_confirmation_models.dart'
    as addons;
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/addOnsConfirmation/repository/add_ons_confirmation_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/addOnsConfirmation/widgets/purchase_item_row.dart'
    as addon_row;
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/bundle_response_parser.dart';
import 'package:myaliv_mobile_app/core/utils/appUtils.dart';

void main() {
  for (final vat in [0.0, 2.37]) {
    for (final category in [
      'daily',
      'weekly',
      'monthly',
      'mifi',
      'roaming',
      'roameasy',
      'libertyGlobal',
    ]) {
      testWidgets(
        '$category VAT $vat: label uses base, existing totals unchanged',
        (tester) async {
          final api = BasePlanModel.fromApiMap({
            'PlanID': '123',
            'PlanName': category,
            'PlanAmount': 41.26,
            'VATAmount': vat,
            'PlanType': 'P',
          });
          final display = const GuestPlanPresentationMapper().map(api);
          final gross = api.planAmount + api.vatAmount;
          expect(display.price, gross);
          expect(display.formattedPrice, AppUtils.formatPrice(gross));

          for (final scheduled in [false, true]) {
            if (['roaming', 'roameasy', 'libertyGlobal'].contains(category)) {
              final args = roaming.RoamingPlanConfirmationRouteArgs.fromExtra(
                {
                  'phoneNumber': '2425550100',
                  'planId': display.id,
                  'planName': display.title,
                  'planPrice': display.price,
                  'planBasePrice': display.basePrice,
                  'beginDate': DateTime(2027, 2, 3),
                  'showDateField': scheduled,
                  'forceNow': !scheduled,
                },
                fallbackPhoneNumber: '',
                fallbackShowDateField: false,
              );
              expect(
                args.copyWith(beginDate: DateTime(2027, 3, 4)).planBasePrice,
                api.planAmount,
              );
              final repository = RoamingPlanConfirmationRepository();
              final original = await repository.load(args: args);
              final data = repository.updateBeginDate(
                data: original,
                beginDate: DateTime(2027, 3, 4),
              );
              expect(data.items.single.price, gross);
              expect(data.items.single.basePrice, api.planAmount);
              expect(data.totals.subTotal, gross);
              expect(data.totals.vat, 0);
              expect(data.totals.total, gross);
              await tester.pumpWidget(
                MaterialApp(
                  home: Scaffold(
                    body: roaming_card.PurchaseSummaryCard(
                      data: data,
                      showDateField: scheduled,
                      onRemoveItem: (_) {},
                    ),
                  ),
                ),
              );
              expect(
                find.descendant(
                  of: find.byType(roaming_row.PurchaseItemRow),
                  matching: find.text(AppUtils.formatPrice(api.planAmount)),
                ),
                findsOneWidget,
              );
            } else {
              for (final flow
                  in primary.GuestPurchasePlanConfirmationEntryFlow.values) {
                final args = primary.GuestPurchasePlanConfirmationRouteArgs(
                  phoneNumber: '2425550100',
                  accountHolderName: 'Guest',
                  primaryPlanName: display.title,
                  primaryPlanPrice: display.price,
                  primaryPlanBasePrice: display.basePrice,
                  selectedPlan: display,
                  flow: flow,
                  forceNow: !scheduled,
                  futurePlanStartDate: '2027-02-03',
                  selectedAddOns: const [
                    primary.GuestPurchasePlanConfirmationSelectedAddOn(
                      id: '456',
                      title: 'addon',
                      price: 7.43,
                    ),
                  ],
                );
                final data = await GuestPurchasePlanConfirmationRepository()
                    .load(args: args);
                final expectedTotal =
                    gross +
                    (flow ==
                            primary
                                .GuestPurchasePlanConfirmationEntryFlow
                                .proceed
                        ? 7.43
                        : 0);
                expect(data.items.first.price, gross);
                expect(data.totals.subTotal, expectedTotal);
                expect(data.totals.vat, 0);
                expect(data.totals.total, expectedTotal);
                await tester.pumpWidget(
                  MaterialApp(
                    home: Scaffold(
                      body: Column(
                        children: [
                          for (final item in data.items)
                            primary_row.PurchaseItemRow(
                              item: item,
                              onRemove: () {},
                            ),
                        ],
                      ),
                    ),
                  ),
                );
                expect(
                  find.text(AppUtils.formatPrice(api.planAmount)),
                  findsOneWidget,
                );
                if (data.items.length > 1) {
                  expect(
                    find.text(AppUtils.formatPrice(data.items.last.price)),
                    findsOneWidget,
                  );
                }
              }
            }
          }
        },
      );
    }
  }

  testWidgets(
    'guest add-ons already display API base without changing totals',
    (tester) async {
      final parsed = BundleResponseParser.parse({
        'PrimaryPlans': [
          {
            'PlanID': '1',
            'AvailableBoltOns': [
              {
                'PlanID': '2',
                'PlanName': 'addon',
                'PlanAmount': 13.57,
                'VATAmount': 1.21,
              },
            ],
          },
        ],
      });
      final addon = parsed.addOns.single;
      final data = await AddOnsConfirmationRepository().load(
        args: addons.AddOnsConfirmationRouteArgs(
          phoneNumber: '2425550100',
          selectedAddOns: [
            addons.AddOnsConfirmationSelectedAddOn(
              id: addon.id,
              title: addon.title,
              price: addon.price,
            ),
          ],
        ),
      );
      expect(addon.vatAmount, 1.21);
      expect(data.totals.subTotal, addon.price);
      expect(data.totals.vat, 0);
      expect(data.totals.total, addon.price);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: addon_row.PurchaseItemRow(
              item: data.items.single,
              onRemove: () {},
            ),
          ),
        ),
      );
      expect(find.text(AppUtils.formatPrice(addon.price)), findsOneWidget);
    },
  );

  test(
    'display fields participate in equality without changing monetary fields',
    () {
      const item = roaming.PurchaseLineItem(
        id: '1',
        type: roaming.PurchaseLineType.primaryPlan,
        label: 'plan',
        title: 'test',
        subtitle: '',
        price: 50,
        basePrice: 46,
      );
      expect(item.copyWith(subtitle: 'scheduled').basePrice, 46);
      expect(
        item,
        isNot(
          const roaming.PurchaseLineItem(
            id: '1',
            type: roaming.PurchaseLineType.primaryPlan,
            label: 'plan',
            title: 'test',
            subtitle: '',
            price: 50,
            basePrice: 47,
          ),
        ),
      );
      const primaryItem = primary.PurchaseLineItem(
        id: '1',
        type: primary.PurchaseLineType.primaryPlan,
        label: 'plan',
        title: 'test',
        subtitle: '',
        price: 50,
        basePrice: 46,
      );
      expect(
        primaryItem,
        isNot(
          const primary.PurchaseLineItem(
            id: '1',
            type: primary.PurchaseLineType.primaryPlan,
            label: 'plan',
            title: 'test',
            subtitle: '',
            price: 50,
            basePrice: 47,
          ),
        ),
      );
    },
  );
}
