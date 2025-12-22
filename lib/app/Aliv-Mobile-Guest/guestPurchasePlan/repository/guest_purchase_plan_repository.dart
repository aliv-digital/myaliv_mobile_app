import '../models/plan_model.dart';

enum PlanTab { daily, weekly, monthly, roaming, roameasy }

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
              PlanBenefit(type: PlanBenefitType.data, label: 'data', value: '1', sub: 'GB'),
              PlanBenefit(type: PlanBenefitType.talkMins, label: 'talk mins', value: '10', sub: 'local talk mins'),
              PlanBenefit(type: PlanBenefitType.sms, label: 'sms', value: '10', sub: 'local text'),
            ],
          ),
          PlanModel(
            id: 'd2',
            title: 'daily20',
            subtitle: '1 day',
            price: 20.00,
            description: 'Higher daily bundle for heavier usage.',
            benefits: [
              PlanBenefit(type: PlanBenefitType.data, label: 'data', value: '2', sub: 'GB'),
              PlanBenefit(type: PlanBenefitType.talkMins, label: 'talk mins', value: '20', sub: 'local talk mins'),
              PlanBenefit(type: PlanBenefitType.sms, label: 'sms', value: '20', sub: 'local text'),
            ],
          ),
        ];

      case PlanTab.weekly:
        return const [
          PlanModel(
            id: 'w1',
            title: 'weekly25',
            subtitle: '7 days',
            price: 25.00,
            description: 'Weekly plan that balances data and calling.',
            benefits: [
              PlanBenefit(type: PlanBenefitType.data, label: 'data', value: '3', sub: 'GB'),
              PlanBenefit(type: PlanBenefitType.talkMins, label: 'talk mins', value: '50', sub: 'local talk mins'),
              PlanBenefit(type: PlanBenefitType.sms, label: 'sms', value: '50', sub: 'local text'),
            ],
          ),
          PlanModel(
            id: 'w2',
            title: 'weekly35',
            subtitle: '7 days',
            price: 35.00,
            description: 'Weekly plan for higher usage.',
            benefits: [
              PlanBenefit(type: PlanBenefitType.data, label: 'data', value: '5', sub: 'GB'),
              PlanBenefit(type: PlanBenefitType.talkMins, label: 'talk mins', value: '80', sub: 'local talk mins'),
              PlanBenefit(type: PlanBenefitType.sms, label: 'sms', value: '80', sub: 'local text'),
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
              PlanBenefit(type: PlanBenefitType.data, label: 'data', value: '1', sub: 'GB'),
              PlanBenefit(type: PlanBenefitType.talkMins, label: 'talk mins', value: '30', sub: 'local talk mins'),
              PlanBenefit(type: PlanBenefitType.sms, label: 'sms', value: '30', sub: 'local text'),
              PlanBenefit(type: PlanBenefitType.bonusData, label: 'bonus data', value: '5', sub: 'GB'),
              PlanBenefit(type: PlanBenefitType.intlTalkText, label: "int'l talk & text", value: '300', sub: 'sms text'),
              PlanBenefit(type: PlanBenefitType.mms, label: 'mms', value: '0', sub: 'ALIV to ALIV'),
            ],
          ),
          PlanModel(
            id: 'm2',
            title: 'liberty70',
            subtitle: '30 days',
            price: 70.00,
            description: 'Monthly plan with extended value.',
            benefits: [
              PlanBenefit(type: PlanBenefitType.data, label: 'data', value: '1', sub: 'GB'),
              PlanBenefit(type: PlanBenefitType.talkMins, label: 'talk mins', value: '30', sub: 'local talk mins'),
              PlanBenefit(type: PlanBenefitType.sms, label: 'sms', value: '30', sub: 'local text'),
              PlanBenefit(type: PlanBenefitType.bonusData, label: 'bonus data', value: '5', sub: 'GB'),
              PlanBenefit(type: PlanBenefitType.intlTalkText, label: "int'l talk & text", value: '300', sub: 'sms text'),
              PlanBenefit(type: PlanBenefitType.mms, label: 'mms', value: '0', sub: 'ALIV to ALIV'),
            ],
          ),
          PlanModel(
            id: 'm3',
            title: 'liberty120',
            subtitle: 'begins immediately',
            price: 120.00,
            description: 'Premium monthly option for heavy usage.',
            benefits: [
              PlanBenefit(type: PlanBenefitType.data, label: 'data', value: '1', sub: 'GB'),
              PlanBenefit(type: PlanBenefitType.talkMins, label: 'talk mins', value: '30', sub: 'local talk mins'),
              PlanBenefit(type: PlanBenefitType.sms, label: 'sms', value: '30', sub: 'local text'),
              PlanBenefit(type: PlanBenefitType.bonusData, label: 'bonus data', value: '5', sub: 'GB'),
              PlanBenefit(type: PlanBenefitType.intlTalkText, label: "int'l talk & text", value: '300', sub: 'sms text'),
              PlanBenefit(type: PlanBenefitType.mms, label: 'mms', value: '0', sub: 'ALIV to ALIV'),
            ],
          ),
        ];

      case PlanTab.roaming:
        return const [
          PlanModel(
            id: 'r1',
            title: 'roam50',
            subtitle: '10 days',
            price: 50.00,
            description: 'Roaming bundle for travel.',
            benefits: [
              PlanBenefit(type: PlanBenefitType.data, label: 'data', value: '2', sub: 'GB'),
              PlanBenefit(type: PlanBenefitType.talkMins, label: 'talk mins', value: '20', sub: 'local talk mins'),
              PlanBenefit(type: PlanBenefitType.sms, label: 'sms', value: '20', sub: 'local text'),
            ],
          ),
        ];

      case PlanTab.roameasy:
        return const [
          PlanModel(
            id: 're1',
            title: 'roameasy30',
            subtitle: '7 days',
            price: 30.00,
            description: 'Easy roaming pack for short trips.',
            benefits: [
              PlanBenefit(type: PlanBenefitType.data, label: 'data', value: '1', sub: 'GB'),
              PlanBenefit(type: PlanBenefitType.talkMins, label: 'talk mins', value: '15', sub: 'local talk mins'),
              PlanBenefit(type: PlanBenefitType.sms, label: 'sms', value: '15', sub: 'local text'),
            ],
          ),
        ];
    }
  }
}
