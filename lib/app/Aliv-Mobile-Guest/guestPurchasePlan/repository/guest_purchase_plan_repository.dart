import '../models/plan_model.dart';
import '../models/add_on_model.dart';

enum PlanTab {
  daily,
  weekly,
  monthly,
  roaming,
  roameasy,
  mifi,
  libertyGlobal,
  addOns,
}

class GuestPurchasePlanRepository {
  Future<List<PlanModel>> fetchPlans({required PlanTab tab}) async {
    await Future.delayed(const Duration(milliseconds: 450));

    switch (tab) {
      case PlanTab.daily:
        return const [
          PlanModel(
            id: 'd1',
            title: 'daily10',
            subtitle: '1 day',
            price: 10.00,
            description: 'A simple daily plan for quick usage.',
            benefits: [
              PlanBenefit(
                  type: PlanBenefitType.data,
                  label: 'data',
                  value: '1',
                  sub: 'GB'
              ),
              PlanBenefit(
                  type: PlanBenefitType.talkMins,
                  label: 'talk mins',
                  value: '10',
                  sub: 'local talk mins'),
              PlanBenefit(
                  type: PlanBenefitType.sms,
                  label: 'sms',
                  value: '10',
                  sub: 'local text'),
            ],
          ),
          PlanModel(
            id: 'd2',
            title: 'daily20',
            subtitle: '1 day',
            price: 20.00,
            description: 'Higher daily bundle for heavier usage.',
            benefits: [
              PlanBenefit(
                  type: PlanBenefitType.data,
                  label: 'data',
                  value: '2',
                  sub: 'GB'),
              PlanBenefit(
                  type: PlanBenefitType.talkMins,
                  label: 'talk mins',
                  value: '20',
                  sub: 'local talk mins'),
              PlanBenefit(
                  type: PlanBenefitType.sms,
                  label: 'sms',
                  value: '20',
                  sub: 'local text'),
            ],
          ),
        ];

      case PlanTab.weekly:
        return const [
          // ✅ weekly card screenshot অনুযায়ী: unlimited talk + unlimited sms
          PlanModel(
            id: 'w1',
            title: 'freedom 5',
            subtitle: '7 day',
            price: 8.00,
            description: 'Weekly plan with unlimited local talk and text.',
            benefits: [
              PlanBenefit(
                  type: PlanBenefitType.data,
                  label: 'data',
                  value: '1',
                  sub: 'gb'),
              PlanBenefit(
                  type: PlanBenefitType.talkMins,
                  label: 'talk mins',
                  value: 'unlimited',
                  sub: 'local talk mins'),
              PlanBenefit(
                  type: PlanBenefitType.sms,
                  label: 'sms',
                  value: 'unlimited',
                  sub: 'local text'),
            ],
          ),
        ];

      case PlanTab.monthly:
        return const [
          PlanModel(
            id: 'm1',
            title: 'liberty40',
            subtitle: '30 days',
            price: 40.00,
            description:
            'The ALIV Freedom 6 Plan provides users with unlimited talk and text within the Bahamas...',
            benefits: [
              PlanBenefit(
                  type: PlanBenefitType.data,
                  label: 'data',
                  value: '1',
                  sub: 'gb'),
              PlanBenefit(
                  type: PlanBenefitType.talkMins,
                  label: 'talk mins',
                  value: '30',
                  sub: 'local talk mins'),
              PlanBenefit(
                  type: PlanBenefitType.sms,
                  label: 'sms',
                  value: '30',
                  sub: 'local text'),
              PlanBenefit(
                  type: PlanBenefitType.bonusData,
                  label: 'bonus data',
                  value: '5',
                  sub: 'gb'),
              PlanBenefit(
                  type: PlanBenefitType.intlTalkText,
                  label: "int'l talk & text",
                  value: '300',
                  sub: 'sms text'),
              PlanBenefit(
                  type: PlanBenefitType.mms,
                  label: 'mms',
                  value: '0',
                  sub: 'ALIV to ALIV'),
            ],
          ),
          PlanModel(
            id: 'm2',
            title: 'liberty70',
            subtitle: '30 days',
            price: 70.00,
            description: 'Monthly plan with extended value.',
            benefits: [
              PlanBenefit(
                  type: PlanBenefitType.data,
                  label: 'data',
                  value: '1',
                  sub: 'gb'),
              PlanBenefit(
                  type: PlanBenefitType.talkMins,
                  label: 'talk mins',
                  value: '30',
                  sub: 'local talk mins'),
              PlanBenefit(
                  type: PlanBenefitType.sms,
                  label: 'sms',
                  value: '30',
                  sub: 'local text'),
              PlanBenefit(
                  type: PlanBenefitType.bonusData,
                  label: 'bonus data',
                  value: '5',
                  sub: 'gb'),
              PlanBenefit(
                  type: PlanBenefitType.intlTalkText,
                  label: "int'l talk & text",
                  value: '300',
                  sub: 'sms text'),
              PlanBenefit(
                  type: PlanBenefitType.mms,
                  label: 'mms',
                  value: '0',
                  sub: 'ALIV to ALIV'),
            ],
          ),
          PlanModel(
            id: 'm3',
            title: 'liberty120',
            subtitle: 'begins immediately',
            price: 120.00,
            description: 'Premium monthly option for heavy usage.',
            benefits: [
              PlanBenefit(
                  type: PlanBenefitType.data,
                  label: 'data',
                  value: '1',
                  sub: 'gb'),
              PlanBenefit(
                  type: PlanBenefitType.talkMins,
                  label: 'talk mins',
                  value: '30',
                  sub: 'local talk mins'),
              PlanBenefit(
                  type: PlanBenefitType.sms,
                  label: 'sms',
                  value: '30',
                  sub: 'local text'),
              PlanBenefit(
                  type: PlanBenefitType.bonusData,
                  label: 'bonus data',
                  value: '5',
                  sub: 'gb'),
              PlanBenefit(
                  type: PlanBenefitType.intlTalkText,
                  label: "int'l talk & text",
                  value: '300',
                  sub: 'sms text'),
              PlanBenefit(
                  type: PlanBenefitType.mms,
                  label: 'mms',
                  value: '0',
                  sub: 'ALIV to ALIV'),
            ],
          ),
        ];

      case PlanTab.roaming:
        return const [
          // ✅ roaming card: center metric usually data (you made roaming card separately)
          PlanModel(
            id: 'r1',
            title: 'roam 20',
            subtitle: '7 days',
            price: 20.00,
            description: 'Roaming plan for travel usage.',
            benefits: [
              PlanBenefit(
                  type: PlanBenefitType.data,
                  label: 'data',
                  value: '0.25',
                  sub: 'gb'),
            ],
          ),
        ];

      case PlanTab.roameasy:
        return const [
          // ✅ roameasy same like roaming
          PlanModel(
            id: 're1',
            title: 'roameasy 30',
            subtitle: '7 days',
            price: 30.00,
            description: 'Easy roaming pack for short trips.',
            benefits: [
              PlanBenefit(
                  type: PlanBenefitType.data,
                  label: 'data',
                  value: '0.50',
                  sub: 'gb'),
            ],
          ),
        ];

      case PlanTab.mifi:
        return const [
          // ✅ mifi card: center metric = data
          PlanModel(
            id: 'mi1',
            title: 'mifi 75',
            subtitle: '30 days',
            price: 70.00,
            description: 'MiFi data plan for hotspot usage.',
            benefits: [
              PlanBenefit(
                  type: PlanBenefitType.data,
                  label: 'data',
                  value: '50',
                  sub: 'gb'),
            ],
          ),
        ];

      case PlanTab.libertyGlobal:
        return [
          // ✅ liberty global card: center metric = intl talk
          PlanModel(
            id: 'lg1',
            title: 'liberty global haiti',
            subtitle: '365 days',
            price: 10.00,
            description: 'International talk plan for Liberty Global.',
            benefits: [
              PlanBenefit(
                  type: PlanBenefitType.intlTalkText,
                  label: "int'l talk",
                  value: '30',
                  sub: 'talk mins'),
            ],
          ),
        ];

      case PlanTab.addOns:
      // ✅ AddOns tab এর জন্য plans না, addons আলাদা model হওয়া উচিত
      // তাই এখানে empty list return করছি (screen addOns হলে fetchAddOns() call করবে)
        return const [];
    }
  }

  // ✅ AddOns tab data (separate model for checkbox selection)
  Future<List<AddOnModel>> fetchAddOns() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return const [
      AddOnModel(
        id: 'a1',
        title: 'liberty data 1',
        label: 'data balance',
        value: '1gb',
        price: 5.00,
      ),
      AddOnModel(
        id: 'a2',
        title: 'liberty data 2',
        label: 'data balance',
        value: '2gb',
        price: 8.00,
      ),
      AddOnModel(
        id: 'a3',
        title: 'liberty data 5',
        label: 'data balance',
        value: '5gb',
        price: 15.00,
      ),
    ];
  }
}
