import '../models/plan_model.dart';
import '../models/add_on_model.dart';

enum HomePlanTab {
  daily,
  weekly,
  monthly,
  roaming,
  roameasy,
  mifi,
  libertyGlobal,
  addOns,
}

class HomePlanRepository {
  Future<List<HomePlanModel>> fetchPlans({required HomePlanTab tab}) async {
    await Future.delayed(const Duration(milliseconds: 450));

    switch (tab) {
      case HomePlanTab.daily:
        return const [
          HomePlanModel(
            id: 'd1',
            title: 'freedom 5',
            subtitle: '1 day',
            price: 10.00,
            description: 'A simple daily plan for quick usage.',
            benefits: [
              HomePlanBenefit(
                  type: HomePlanBenefitType.data,
                  label: 'data',
                  value: '1',
                  sub: 'GB'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.talkMins,
                  label: 'talk mins',
                  value: '10',
                  sub: 'local talk mins'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.sms,
                  label: 'sms',
                  value: '10',
                  sub: 'local text'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.data,
                  label: 'data',
                  value: '1',
                  sub: 'GB'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.talkMins,
                  label: 'talk mins',
                  value: '10',
                  sub: 'local talk mins'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.sms,
                  label: 'sms',
                  value: '10',
                  sub: 'local text'),
            ],
          ),
          HomePlanModel(
            id: 'd2',
            title: 'freedom 5',
            subtitle: '1 day',
            price: 20.00,
            description: 'Higher daily bundle for heavier usage.',
            benefits: [
              HomePlanBenefit(
                  type: HomePlanBenefitType.data,
                  label: 'data',
                  value: '2',
                  sub: 'GB'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.talkMins,
                  label: 'talk mins',
                  value: '20',
                  sub: 'local talk mins'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.sms,
                  label: 'sms',
                  value: '20',
                  sub: 'local text'),
            ],
          ),
          HomePlanModel(
            id: 'd3',
            title: 'freedom 5',
            subtitle: '1 day',
            price: 30.00,
            description: 'Premium daily option for maximum value.',
            benefits: [
              HomePlanBenefit(
                  type: HomePlanBenefitType.data,
                  label: 'data',
                  value: '5',
                  sub: 'GB'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.talkMins,
                  label: 'talk mins',
                  value: '50',
                  sub: 'local talk mins'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.sms,
                  label: 'sms',
                  value: '50',
                  sub: 'local text'),
            ],
          ),
        ];

      case HomePlanTab.weekly:
        return const [
          // ✅ weekly card screenshot অনুযায়ী: unlimited talk + unlimited sms
          HomePlanModel(
            id: 'w1',
            title: 'freedom 5',
            subtitle: '7 day',
            price: 8.00,
            description: 'Weekly plan with unlimited local talk and text.',
            benefits: [
              HomePlanBenefit(
                  type: HomePlanBenefitType.data,
                  label: 'data',
                  value: '1',
                  sub: 'gb'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.talkMins,
                  label: 'talk mins',
                  value: 'unlimited',
                  sub: 'local talk mins'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.sms,
                  label: 'sms',
                  value: 'unlimited',
                  sub: 'local text'),
            ],
          ),
        ];

      case HomePlanTab.monthly:
        return const [
          HomePlanModel(
            id: 'm1',
            title: 'liberty40',
            subtitle: '30 days',
            price: 40.00,
            description:
                'The ALIV Freedom 6 Plan provides users with unlimited talk and text within the Bahamas...',
            benefits: [
              HomePlanBenefit(
                  type: HomePlanBenefitType.data,
                  label: 'data',
                  value: '1',
                  sub: 'gb'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.talkMins,
                  label: 'talk mins',
                  value: '30',
                  sub: 'local talk mins'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.sms,
                  label: 'sms',
                  value: '30',
                  sub: 'local text'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.bonusData,
                  label: 'bonus data',
                  value: '5',
                  sub: 'gb'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.intlTalkText,
                  label: "int'l talk & text",
                  value: '300',
                  sub: 'sms text'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.mms,
                  label: 'mms',
                  value: '0',
                  sub: 'ALIV to ALIV'),
            ],
          ),
          HomePlanModel(
            id: 'm2',
            title: 'liberty70',
            subtitle: '30 days',
            price: 70.00,
            description: 'Monthly plan with extended value.',
            benefits: [
              HomePlanBenefit(
                  type: HomePlanBenefitType.data,
                  label: 'data',
                  value: '1',
                  sub: 'gb'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.talkMins,
                  label: 'talk mins',
                  value: '30',
                  sub: 'local talk mins'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.sms,
                  label: 'sms',
                  value: '30',
                  sub: 'local text'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.bonusData,
                  label: 'bonus data',
                  value: '5',
                  sub: 'gb'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.intlTalkText,
                  label: "int'l talk & text",
                  value: '300',
                  sub: 'sms text'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.mms,
                  label: 'mms',
                  value: '0',
                  sub: 'ALIV to ALIV'),
            ],
          ),
          HomePlanModel(
            id: 'm3',
            title: 'liberty120',
            subtitle: 'begins immediately',
            price: 120.00,
            description: 'Premium monthly option for heavy usage.',
            benefits: [
              HomePlanBenefit(
                  type: HomePlanBenefitType.data,
                  label: 'data',
                  value: '1',
                  sub: 'gb'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.talkMins,
                  label: 'talk mins',
                  value: '30',
                  sub: 'local talk mins'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.sms,
                  label: 'sms',
                  value: '30',
                  sub: 'local text'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.bonusData,
                  label: 'bonus data',
                  value: '5',
                  sub: 'gb'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.intlTalkText,
                  label: "int'l talk & text",
                  value: '300',
                  sub: 'sms text'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.mms,
                  label: 'mms',
                  value: '0',
                  sub: 'ALIV to ALIV'),
            ],
          ),
        ];

      case HomePlanTab.roaming:
        return const [
          // ✅ roaming card: center metric usually data (you made roaming card separately)
          HomePlanModel(
            id: 'r1',
            title: 'roam 20',
            subtitle: '7 days',
            price: 20.00,
            description: 'Roaming plan for travel usage.',
            benefits: [
              HomePlanBenefit(
                  type: HomePlanBenefitType.data,
                  label: 'data',
                  value: '0.25',
                  sub: 'gb'),
            ],
          ),
          HomePlanModel(
            id: 'r2',
            title: 'roam 20',
            subtitle: '7 days',
            price: 20.00,
            description: 'Roaming plan for travel usage.',
            benefits: [
              HomePlanBenefit(
                  type: HomePlanBenefitType.data,
                  label: 'data',
                  value: '0.25',
                  sub: 'gb'),
            ],
          ),
          HomePlanModel(
            id: 'r3',
            title: 'roam 20',
            subtitle: '7 days',
            price: 20.00,
            description: 'Roaming plan for travel usage.',
            benefits: [
              HomePlanBenefit(
                  type: HomePlanBenefitType.data,
                  label: 'data',
                  value: '0.25',
                  sub: 'gb'),
            ],
          ),
          HomePlanModel(
            id: 'r4',
            title: 'roam 20',
            subtitle: '7 days',
            price: 20.00,
            description: 'Roaming plan for travel usage.',
            benefits: [
              HomePlanBenefit(
                  type: HomePlanBenefitType.data,
                  label: 'data',
                  value: '0.25',
                  sub: 'gb'),
            ],
          ),
        ];

      case HomePlanTab.roameasy:
        return const [
          // ✅ roameasy same like roaming
          HomePlanModel(
            id: 're1',
            title: 'roameasy 30',
            subtitle: '7 days',
            price: 30.00,
            description: 'Easy roaming pack for short trips.',
            benefits: [
              HomePlanBenefit(
                  type: HomePlanBenefitType.data,
                  label: 'data',
                  value: '0.50',
                  sub: 'gb'),
            ],
          ),
        ];

      case HomePlanTab.mifi:
        return const [
          // ✅ mifi card: center metric = data
          HomePlanModel(
            id: 'mi1',
            title: 'mifi 75',
            subtitle: '30 days',
            price: 70.00,
            description: 'MiFi data plan for hotspot usage.',
            benefits: [
              HomePlanBenefit(
                  type: HomePlanBenefitType.data,
                  label: 'data',
                  value: '50',
                  sub: 'gb'),
            ],
          ),
        ];

      case HomePlanTab.libertyGlobal:
        return [
          // ✅ liberty global card: center metric = intl talk
          HomePlanModel(
            id: 'lg1',
            title: 'liberty global haiti',
            subtitle: '365 days',
            price: 10.00,
            description: 'International talk plan for Liberty Global.',
            benefits: [
              HomePlanBenefit(
                  type: HomePlanBenefitType.intlTalkText,
                  label: "int'l talk",
                  value: '30',
                  sub: 'talk mins'),
            ],
          ),
        ];

      case HomePlanTab.addOns:
        // ✅ AddOns tab এর জন্য plans না, addons আলাদা model হওয়া উচিত
        // তাই এখানে empty list return করছি (screen addOns হলে fetchAddOns() call করবে)
        return const [];
    }
  }

  // ✅ AddOns tab data (separate model for checkbox selection)
  Future<List<HomePlanAddOnModel>> fetchAddOns() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return const [
      HomePlanAddOnModel(
        id: 'a1',
        title: 'liberty data 1',
        label: 'data balance',
        value: '1gb',
        price: 5.00,
      ),
      HomePlanAddOnModel(
        id: 'a2',
        title: 'liberty data 2',
        label: 'data balance',
        value: '2gb',
        price: 8.00,
      ),
      HomePlanAddOnModel(
        id: 'a3',
        title: 'liberty data 5',
        label: 'data balance',
        value: '5gb',
        price: 15.00,
      ),
    ];
  }
}
