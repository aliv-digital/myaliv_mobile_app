import '../models/plan_model.dart';
import '../models/add_on_model.dart';
import '../models/add_ons_primary_plan_model.dart';
import '../models/daily_plan_model.dart';
import '../models/weekly_plan_model.dart';
import '../models/monthly_plan_model.dart';
import '../models/roaming_plan_model.dart';
import '../models/roameasy_plan_model.dart';
import '../models/mifi_plan_model.dart';
import '../models/liberty_global_plan_model.dart';
import '../../PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'base_plan_repository.dart';
import 'plan_types.dart';

/// Mock implementation of plan repository with hardcoded data.
///
/// This repository returns static mock data for development and testing purposes.
/// It simulates the same interface as the production repository but doesn't
/// make any network calls.
class MockPlanRepository implements BasePlanRepository {
  // Cache storage (empty for mock)
  final List<Map<String, dynamic>> _lastFetchedPlans = <Map<String, dynamic>>[];
  DateTime? _lastFetchedAt;

  final List<DailyPlanModel> _lastFetchedDailyPlans = <DailyPlanModel>[];
  DateTime? _lastFetchedDailyAt;

  final List<WeeklyPlanModel> _lastFetchedWeeklyPlans = <WeeklyPlanModel>[];
  DateTime? _lastFetchedWeeklyAt;

  final List<MonthlyPlanModel> _lastFetchedMonthlyPlans = <MonthlyPlanModel>[];
  DateTime? _lastFetchedMonthlyAt;

  final List<RoamingPlanModel> _lastFetchedRoamingPlans = <RoamingPlanModel>[];
  DateTime? _lastFetchedRoamingAt;

  final List<RoamEasyPlanModel> _lastFetchedRoamEasyPlans =
      <RoamEasyPlanModel>[];
  DateTime? _lastFetchedRoamEasyAt;

  final List<MifiPlanModel> _lastFetchedMifiPlans = <MifiPlanModel>[];
  DateTime? _lastFetchedMifiAt;

  final List<LibertyGlobalPlanModel> _lastFetchedLibertyGlobalPlans =
      <LibertyGlobalPlanModel>[];
  DateTime? _lastFetchedLibertyGlobalAt;
  final List<HomePlansPostPaidPlanModel> _lastFetchedPostpaidRoamingPlans =
      <HomePlansPostPaidPlanModel>[];
  DateTime? _lastFetchedPostpaidRoamingAt;

  List<AddOnsPrimaryPlanModel> _lastFetchedAddOnsPrimaryPlans =
      <AddOnsPrimaryPlanModel>[];
  DateTime? _lastFetchedAddOnsPrimaryPlansAt;

  @override
  Future<List<Map<String, dynamic>>> getPlans({
    bool printRawResponse = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
    _lastFetchedAt = DateTime.now();
    return _lastFetchedPlans;
  }

  @override
  Future<List<DailyPlanModel>> fetchDailyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredDailyPlans = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
    _lastFetchedDailyAt = DateTime.now();

    // Return mock daily plans
    return [
      DailyPlanModel.fromApiMap(_createMockPlanMap(
        planId: 'd1',
        planName: 'freedom5',
        planDescription: 'A simple daily plan for quick usage.',
        planAmount: 5.00,
        planType: 'P',
        voice: 30.0,
        data: 2.0,
        sms: 30,
      )),
    ];
  }

  @override
  Future<List<WeeklyPlanModel>> fetchWeeklyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredWeeklyPlans = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
    _lastFetchedWeeklyAt = DateTime.now();

    // Return mock weekly plans
    return [
      WeeklyPlanModel.fromApiMap(_createMockPlanMap(
        planId: 'w1',
        planName: 'freedom8',
        planDescription: 'Weekly plan with unlimited local talk and text.',
        planAmount: 8.00,
        planType: 'P',
        data: 1.0,
        voiceUnlimited: true,
        smsUnlimited: true,
      )),
      WeeklyPlanModel.fromApiMap(_createMockPlanMap(
        planId: 'w2',
        planName: 'freedom15',
        planDescription: 'Weekly plan with unlimited local talk and text.',
        planAmount: 15.00,
        planType: 'P',
        data: 3.0,
        voiceUnlimited: true,
        smsUnlimited: true,
      )),
    ];
  }

  @override
  Future<List<MonthlyPlanModel>> fetchMonthlyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredMonthlyPlans = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
    _lastFetchedMonthlyAt = DateTime.now();

    // Return mock monthly plans
    return [
      MonthlyPlanModel.fromApiMap(_createMockPlanMap(
        planId: 'm1',
        planName: 'liberty40',
        planDescription:
            'The ALIV Freedom 6 Plan provides users with unlimited talk and text within the Bahamas...',
        planAmount: 40.00,
        planType: 'P',
        data: 5.0,
        voiceUnlimited: true,
        smsUnlimited: true,
      )),
      MonthlyPlanModel.fromApiMap(_createMockPlanMap(
        planId: 'm2',
        planName: 'liberty70',
        planDescription: 'Monthly plan with extended value.',
        planAmount: 70.00,
        planType: 'P',
        data: 14.0,
        voiceUnlimited: true,
        smsUnlimited: true,
      )),
      MonthlyPlanModel.fromApiMap(_createMockPlanMap(
        planId: 'm3',
        planName: 'liberty120',
        planDescription: 'Premium monthly option for heavy usage.',
        planAmount: 120.00,
        planType: 'P',
        dataUnlimited: true,
        voiceUnlimited: true,
        smsUnlimited: true,
      )),
    ];
  }

  @override
  Future<List<RoamingPlanModel>> fetchRoamingPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredRoamingPlans = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
    _lastFetchedRoamingAt = DateTime.now();

    // Return mock roaming plans
    return [
      RoamingPlanModel.fromApiMap(_createMockPlanMap(
        planId: 'r1',
        planName: 'roam20',
        planDescription: 'Roaming plan for travel usage.',
        planAmount: 20.00,
        planType: 'A',
        planGroup: 'roaming',
        data: 0.25,
      )),
      RoamingPlanModel.fromApiMap(_createMockPlanMap(
        planId: 'r2',
        planName: 'roam30',
        planDescription: 'Roaming plan for travel usage.',
        planAmount: 30.00,
        planType: 'A',
        planGroup: 'roaming',
        data: 0.5,
      )),
    ];
  }

  @override
  Future<List<RoamEasyPlanModel>> fetchRoamEasyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredRoamEasyPlans = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
    _lastFetchedRoamEasyAt = DateTime.now();

    // Return mock RoamEasy plans
    return [
      RoamEasyPlanModel.fromApiMap(_createMockPlanMap(
        planId: 're1',
        planName: 'roameasy carib',
        planDescription: 'Easy roaming pack for short trips.',
        planAmount: 25.00,
        planType: 'A',
        planGroup: 'roameasy',
        data: 1.5,
      )),
      RoamEasyPlanModel.fromApiMap(_createMockPlanMap(
        planId: 're2',
        planName: 'roameasy usa & can',
        planDescription: 'Easy roaming pack for short trips.',
        planAmount: 25.00,
        planType: 'A',
        planGroup: 'roameasy',
        data: 2.0,
      )),
    ];
  }

  @override
  Future<List<MifiPlanModel>> fetchMifiPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredMifiPlans = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
    _lastFetchedMifiAt = DateTime.now();

    // Return mock MiFi plans
    return [
      MifiPlanModel.fromApiMap(_createMockPlanMap(
        planId: 'mi1',
        planName: 'mifi75',
        planDescription: 'MiFi data plan for hotspot usage.',
        planAmount: 75.00,
        planType: 'P',
        planGroup: 'mifi',
        data: 50.0,
      )),
      MifiPlanModel.fromApiMap(_createMockPlanMap(
        planId: 'mi2',
        planName: 'mifi125',
        planDescription: 'MiFi data plan for hotspot usage.',
        planAmount: 125.00,
        planType: 'P',
        planGroup: 'mifi',
        data: 125.0,
      )),
    ];
  }

  @override
  Future<List<LibertyGlobalPlanModel>> fetchLibertyGlobalPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredLibertyGlobalPlans = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
    _lastFetchedLibertyGlobalAt = DateTime.now();

    // Return mock Liberty Global plans
    return [
      LibertyGlobalPlanModel.fromApiMap(_createMockPlanMap(
        planId: 'lg1',
        planName: 'liberty global haiti',
        planDescription: 'International talk plan for Liberty Global.',
        planAmount: 10.00,
        planType: 'A',
        planGroup: 'liberty global',
        voice: 30.0,
      )),
      LibertyGlobalPlanModel.fromApiMap(_createMockPlanMap(
        planId: 'lg2',
        planName: 'liberty global caribbean',
        planDescription: 'International talk plan for Liberty Global.',
        planAmount: 21.00,
        planType: 'A',
        planGroup: 'liberty global',
        voice: 50.0,
      )),
    ];
  }

  @override
  Future<List<HomePlansPostPaidPlanModel>> fetchPostpaidRoamingPlansFromApi({
    bool printRawResponse = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
    _lastFetchedPostpaidRoamingAt = DateTime.now();
    return _lastFetchedPostpaidRoamingPlans;
  }

  /// Helper method to create a mock plan map with common fields
  Map<String, dynamic> _createMockPlanMap({
    required String planId,
    required String planName,
    required String planDescription,
    required double planAmount,
    required String planType,
    String planGroup = '',
    double voice = 0.0,
    double data = 0.0,
    int sms = 0,
    bool voiceUnlimited = false,
    bool dataUnlimited = false,
    bool smsUnlimited = false,
  }) {
    return {
      'PlanID': planId,
      'PlanName': planName,
      'PlanDescription': planDescription,
      'PlanAmount': planAmount,
      'PlanType': planType,
      'Frequency': '',
      'FeatureCodes': '',
      'StartDate': '',
      'EndDate': '',
      'PlanDetails': planDescription,
      'CreatedBy': '',
      'PublishedBy': '',
      'RetiredBy': '',
      'AutoRenew': false,
      'IsEditable': false,
      'Voice': voice,
      'Data': data,
      'SMS': sms,
      'MTSubscriptionID': '',
      'VoiceUnlimited': voiceUnlimited,
      'DataUnlimited': dataUnlimited,
      'SMSUnlimited': smsUnlimited,
      'AvailableBoltOns': [],
      'CurrentlyAssigned': false,
      'PlanRenewable': true,
      'PaymentOption': '',
      'CanICB': '',
      'HierarchyType': '',
      'PlanGroup': planGroup,
      'PlanGroupID': '',
      'PlanGroupSortOrder': '',
      'ProrateOnActivate': '',
      'ProrateOnDeactivate': '',
      'PlanCapabilities': [],
      'PlanBuckets': [],
      'ChannelTypes': '',
      'VIPTypes': '',
      'Roles': '',
      'Cugs': '',
      'Sugs': '',
      'UnlimitedBuckets': '',
      'ActiveCCard': '',
      'SubscriberLines': '',
      'PurchaseLimit': '',
      'PurchaseLimitStartDate': '',
      'PurchaseLimitEndDate': '',
      'ContractAge': '',
      'ActivatedAge': '',
      'ContractTerm': '',
      'Islands': '',
      'Rank': '',
      'CreditClass': '',
      'VATAmount': 0.0,
      'PlanSortOrder': '',
    };
  }

  @override
  Future<List<HomePlanModel>> fetchPlans({required HomePlanTab tab}) async {
    await Future.delayed(const Duration(milliseconds: 450));

    switch (tab) {
      case HomePlanTab.daily:
        return const [
          HomePlanModel(
            id: 'd1',
            title: 'freedom5',
            subtitle: '1 day',
            price: 5.00,
            description: 'A simple daily plan for quick usage.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '2',
                sub: 'gb',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.talkMins,
                label: 'talk mins',
                value: '30',
                sub: 'local talk mins',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.sms,
                label: 'sms',
                value: '30',
                sub: 'local text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.bonusData,
                label: 'bonus data',
                value: 'unlimited',
                sub: 'whatsApp messaging',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.intlTalkText,
                label: 'us/can text',
                value: '300',
                sub: "int'l text",
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.mms,
                label: "int'l us/can talk",
                value: '30',
                sub: "int'l talk",
              ),
            ],
          ),
        ];

      case HomePlanTab.weekly:
        return const [
          HomePlanModel(
            id: 'w1',
            title: 'freedom8',
            subtitle: '7 day',
            price: 8.00,
            description: 'Weekly plan with unlimited local talk and text.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '1',
                sub: 'gb',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.talkMins,
                label: 'talk mins',
                value: 'unlimited',
                sub: 'local talk mins',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.sms,
                label: 'sms',
                value: 'unlimited',
                sub: 'local text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.bonusData,
                label: 'bonus data',
                value: 'unlimited',
                sub: 'whatsApp messaging',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.intlTalkText,
                label: 'us/can text',
                value: '300',
                sub: "int'l text",
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.mms,
                label: "int'l us/can talk",
                value: '30',
                sub: "int'l talk",
              ),
            ],
          ),
          HomePlanModel(
            id: 'w2',
            title: 'freedom15',
            subtitle: '7 day',
            price: 15.00,
            description: 'Weekly plan with unlimited local talk and text.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '3',
                sub: 'gb',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.talkMins,
                label: 'talk mins',
                value: 'unlimited',
                sub: 'local talk mins',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.sms,
                label: 'sms',
                value: 'unlimited',
                sub: 'local text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.bonusData,
                label: 'bonus data',
                value: 'unlimited',
                sub: 'whatsApp messaging',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.intlTalkText,
                label: 'us/can text',
                value: '300',
                sub: "int'l text",
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.mms,
                label: "int'l us/can talk",
                value: '30',
                sub: "int'l talk",
              ),
            ],
          ),
          HomePlanModel(
            id: 'w3',
            title: 'freedom45',
            subtitle: '7 day',
            price: 45.00,
            description: 'Weekly plan with unlimited local talk and text.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: 'unlimited',
                sub: 'gb',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.talkMins,
                label: 'talk mins',
                value: 'unlimited',
                sub: 'local talk mins',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.sms,
                label: 'sms',
                value: 'unlimited',
                sub: 'local text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.bonusData,
                label: 'bonus data',
                value: 'unlimited',
                sub: 'whatsApp messaging',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.intlTalkText,
                label: 'us/can text',
                value: '300',
                sub: "int'l text",
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.mms,
                label: "int'l us/can talk",
                value: '30',
                sub: "int'l talk",
              ),
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
                value: '5',
                sub: 'gb',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.talkMins,
                label: 'talk mins',
                value: 'unlimited',
                sub: 'local talk mins',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.sms,
                label: 'sms',
                value: 'unlimited',
                sub: 'local text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.bonusData,
                label: 'bonus data',
                value: 'unlimited',
                sub: 'whatsApp messaging',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.intlTalkText,
                label: 'us/can text',
                value: '300',
                sub: "int'l text",
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.mms,
                label: "int'l us/can talk",
                value: '30',
                sub: "int'l talk",
              ),
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
                value: '14',
                sub: 'gb',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.talkMins,
                label: 'talk mins',
                value: 'unlimited',
                sub: 'local talk mins',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.sms,
                label: 'sms',
                value: 'unlimited',
                sub: 'local text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.bonusData,
                label: 'bonus data',
                value: 'unlimited',
                sub: 'whatsApp messaging',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.intlTalkText,
                label: 'us/can text',
                value: '300',
                sub: "int'l text",
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.mms,
                label: "int'l us/can talk",
                value: '30',
                sub: "int'l talk",
              ),
            ],
          ),
          HomePlanModel(
            id: 'm3',
            title: 'liberty120',
            subtitle: '30 days',
            price: 120.00,
            description: 'Premium monthly option for heavy usage.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: 'unlimited',
                sub: 'gb',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.talkMins,
                label: 'talk mins',
                value: 'unlimited',
                sub: 'local talk mins',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.sms,
                label: 'sms',
                value: 'unlimited',
                sub: 'local text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.bonusData,
                label: 'bonus data',
                value: 'unlimited',
                sub: 'whatsApp messaging',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.intlTalkText,
                label: 'us/can text',
                value: '300',
                sub: "int'l text",
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.mms,
                label: "int'l us/can talk",
                value: '30',
                sub: "int'l talk",
              ),
            ],
          ),
        ];

      case HomePlanTab.roaming:
        return const [
          HomePlanModel(
            id: 'r1',
            title: 'roam20',
            subtitle: '7 days',
            price: 20.00,
            description: 'Roaming plan for travel usage.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '0.25',
                sub: 'gb',
              ),
            ],
          ),
          HomePlanModel(
            id: 'r2',
            title: 'roam30',
            subtitle: '7 days',
            price: 30.00,
            description: 'Roaming plan for travel usage.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '0.5',
                sub: 'gb',
              ),
            ],
          ),
          HomePlanModel(
            id: 'r3',
            title: 'roam50',
            subtitle: '14 days',
            price: 50.00,
            description: 'Roaming plan for travel usage.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '1',
                sub: 'gb',
              ),
            ],
          ),
        ];

      case HomePlanTab.roameasy:
        return const [
          HomePlanModel(
            id: 're1',
            title: 'roameasy carib',
            subtitle: '7 days',
            price: 25.00,
            description: 'Easy roaming pack for short trips.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '1.5',
                sub: 'gb',
              ),
            ],
          ),
          HomePlanModel(
            id: 're2',
            title: 'roameasy usa & can',
            subtitle: '7 days',
            price: 25.00,
            description: 'Easy roaming pack for short trips.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '2',
                sub: 'gb',
              ),
            ],
          ),
          HomePlanModel(
            id: 're3',
            title: 'roameasy europe',
            subtitle: '7 days',
            price: 30.00,
            description: 'Easy roaming pack for short trips.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '1',
                sub: 'gb',
              ),
            ],
          ),
        ];

      case HomePlanTab.mifi:
        return const [
          HomePlanModel(
            id: 'mi1',
            title: 'mifi75',
            subtitle: '30 days',
            price: 75.00,
            description: 'MiFi data plan for hotspot usage.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '50',
                sub: 'gb',
              ),
            ],
          ),
          HomePlanModel(
            id: 'mi2',
            title: 'mifi90',
            subtitle: '30 days',
            price: 125.00,
            description: 'MiFi data plan for hotspot usage.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '125',
                sub: 'gb',
              ),
            ],
          ),
          HomePlanModel(
            id: 'mi3',
            title: 'mifi140',
            subtitle: '30 days',
            price: 140.00,
            description: 'MiFi data plan for hotspot usage.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '200',
                sub: 'gb',
              ),
            ],
          ),
        ];

      case HomePlanTab.libertyGlobal:
        return [
          HomePlanModel(
            id: 'lg1',
            title: 'liberty global haiti',
            subtitle: '365 days',
            price: 10.00,
            description: 'International talk plan for Liberty Global.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.mms,
                label: "int'l talk",
                value: '30',
                sub: 'talk mins',
              ),
            ],
          ),
          HomePlanModel(
            id: 'lg2',
            title: 'liberty global caribbean',
            subtitle: '365 days',
            price: 21.00,
            description: 'International talk plan for Liberty Global.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.mms,
                label: "int'l talk",
                value: '50',
                sub: 'talk mins',
              ),
            ],
          ),
          HomePlanModel(
            id: 'lg3',
            title: 'liberty global china',
            subtitle: '365 days',
            price: 21.00,
            description: 'International talk plan for Liberty Global.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.mms,
                label: "int'l talk",
                value: '250',
                sub: 'talk mins',
              ),
            ],
          ),
        ];

      case HomePlanTab.addOns:
        return const [];
      case HomePlanTab.postpaidRoaming:
        return const [];
    }
  }

  @override
  Future<List<HomePlanAddOnModel>> fetchAddOns() async {
    final primaryPlans = await fetchAddOnsPrimaryPlansFromApi();
    final selectedPrimaryPlan = selectEarliestAddOnsPrimaryPlan(primaryPlans);

    if (selectedPrimaryPlan == null) {
      return const <HomePlanAddOnModel>[];
    }

    return mapAvailableBoltOnsToUiAddOns(primaryPlan: selectedPrimaryPlan);
  }

  @override
  Future<List<AddOnsPrimaryPlanModel>> fetchAddOnsPrimaryPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredPrimaryPlans = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    _lastFetchedAddOnsPrimaryPlans = <AddOnsPrimaryPlanModel>[
      _createMockAddOnsPrimaryPlan(
        planId: 'm2',
        planName: 'liberty70',
        planType: 'P',
        planAmount: 70.00,
        autoRenew: true,
        availableBoltOns: <AddOnsPrimaryPlanModel>[
          _createMockAddOnsPrimaryPlan(
            planId: 'a1',
            planName: 'liberty data 1',
            planType: 'S',
            planAmount: 5.00,
            planBuckets: const <AddOnsPrimaryPlanBucketModel>[
              AddOnsPrimaryPlanBucketModel(
                name: 'Data',
                amount: 1,
                unit: 'gb',
                bucketOrder: '1',
                suppress: false,
                unlimited: false,
                bucketUnit: 'GB',
              ),
            ],
          ),
          _createMockAddOnsPrimaryPlan(
            planId: 'a2',
            planName: 'liberty data 2',
            planType: 'S',
            planAmount: 10.00,
            planBuckets: const <AddOnsPrimaryPlanBucketModel>[
              AddOnsPrimaryPlanBucketModel(
                name: 'Data',
                amount: 2,
                unit: 'gb',
                bucketOrder: '1',
                suppress: false,
                unlimited: false,
                bucketUnit: 'GB',
              ),
            ],
          ),
          _createMockAddOnsPrimaryPlan(
            planId: 'a3',
            planName: 'liberty data 3',
            planType: 'S',
            planAmount: 16.00,
            planBuckets: const <AddOnsPrimaryPlanBucketModel>[
              AddOnsPrimaryPlanBucketModel(
                name: 'Data',
                amount: 3,
                unit: 'gb',
                bucketOrder: '1',
                suppress: false,
                unlimited: false,
                bucketUnit: 'GB',
              ),
            ],
          ),
        ],
      ),
    ];
    _lastFetchedAddOnsPrimaryPlansAt = DateTime.now();

    return _lastFetchedAddOnsPrimaryPlans;
  }

  @override
  AddOnsPrimaryPlanModel? selectEarliestAddOnsPrimaryPlan(
    List<AddOnsPrimaryPlanModel> primaryPlans,
  ) {
    if (primaryPlans.isEmpty) {
      return null;
    }

    return primaryPlans.first;
  }

  @override
  List<HomePlanAddOnModel> mapAvailableBoltOnsToUiAddOns({
    required AddOnsPrimaryPlanModel primaryPlan,
  }) {
    return primaryPlan.availableBoltOns
        .map(
          (addOnPlan) => HomePlanAddOnModel(
            id: addOnPlan.planId,
            title: addOnPlan.planName,
            label: _buildAddOnLabel(addOnPlan),
            value: _buildAddOnValue(addOnPlan),
            price: addOnPlan.planAmount,
            vatAmount: addOnPlan.vatAmount,
          ),
        )
        .toList(growable: false);
  }

  // ========== Read-Only Getters ==========

  @override
  List<Map<String, dynamic>> get lastFetchedPlans =>
      List<Map<String, dynamic>>.unmodifiable(_lastFetchedPlans);

  @override
  DateTime? get lastFetchedAt => _lastFetchedAt;

  @override
  List<DailyPlanModel> get lastFetchedDailyPlans =>
      List<DailyPlanModel>.unmodifiable(_lastFetchedDailyPlans);

  @override
  DateTime? get lastFetchedDailyAt => _lastFetchedDailyAt;

  @override
  List<WeeklyPlanModel> get lastFetchedWeeklyPlans =>
      List<WeeklyPlanModel>.unmodifiable(_lastFetchedWeeklyPlans);

  @override
  DateTime? get lastFetchedWeeklyAt => _lastFetchedWeeklyAt;

  @override
  List<MonthlyPlanModel> get lastFetchedMonthlyPlans =>
      List<MonthlyPlanModel>.unmodifiable(_lastFetchedMonthlyPlans);

  @override
  DateTime? get lastFetchedMonthlyAt => _lastFetchedMonthlyAt;

  @override
  List<RoamingPlanModel> get lastFetchedRoamingPlans =>
      List<RoamingPlanModel>.unmodifiable(_lastFetchedRoamingPlans);

  @override
  DateTime? get lastFetchedRoamingAt => _lastFetchedRoamingAt;

  @override
  List<RoamEasyPlanModel> get lastFetchedRoamEasyPlans =>
      List<RoamEasyPlanModel>.unmodifiable(_lastFetchedRoamEasyPlans);

  @override
  DateTime? get lastFetchedRoamEasyAt => _lastFetchedRoamEasyAt;

  @override
  List<MifiPlanModel> get lastFetchedMifiPlans =>
      List<MifiPlanModel>.unmodifiable(_lastFetchedMifiPlans);

  @override
  DateTime? get lastFetchedMifiAt => _lastFetchedMifiAt;

  @override
  List<LibertyGlobalPlanModel> get lastFetchedLibertyGlobalPlans =>
      List<LibertyGlobalPlanModel>.unmodifiable(_lastFetchedLibertyGlobalPlans);

  @override
  DateTime? get lastFetchedLibertyGlobalAt => _lastFetchedLibertyGlobalAt;

  @override
  List<HomePlansPostPaidPlanModel> get lastFetchedPostpaidRoamingPlans =>
      List<HomePlansPostPaidPlanModel>.unmodifiable(
        _lastFetchedPostpaidRoamingPlans,
      );

  @override
  DateTime? get lastFetchedPostpaidRoamingAt => _lastFetchedPostpaidRoamingAt;

  @override
  List<AddOnsPrimaryPlanModel> get lastFetchedAddOnsPrimaryPlans =>
      List<AddOnsPrimaryPlanModel>.unmodifiable(_lastFetchedAddOnsPrimaryPlans);

  @override
  DateTime? get lastFetchedAddOnsPrimaryPlansAt =>
      _lastFetchedAddOnsPrimaryPlansAt;

  AddOnsPrimaryPlanModel _createMockAddOnsPrimaryPlan({
    required String planId,
    required String planName,
    required String planType,
    double planAmount = 0,
    String startDate = '2024-08-20 00:00:00',
    String endDate = '2024-09-19 23:59:59',
    bool autoRenew = false,
    List<AddOnsPrimaryPlanModel> availableBoltOns =
        const <AddOnsPrimaryPlanModel>[],
    List<AddOnsPrimaryPlanBucketModel> planBuckets =
        const <AddOnsPrimaryPlanBucketModel>[],
  }) {
    return AddOnsPrimaryPlanModel(
      planId: planId,
      planName: planName,
      planDescription: '',
      planAmount: planAmount,
      planType: planType,
      frequency: '',
      featureCodes: '',
      startDate: startDate,
      endDate: endDate,
      planDetails: '',
      createdBy: '',
      publishedBy: '',
      retiredBy: '',
      autoRenew: autoRenew,
      isEditable: false,
      voice: 0,
      data: 0,
      sms: 0,
      mtSubscriptionId: '',
      voiceUnlimited: false,
      dataUnlimited: false,
      smsUnlimited: false,
      availableBoltOns: availableBoltOns,
      currentlyAssigned: false,
      planRenewable: false,
      paymentOption: '',
      canIcb: '',
      hierarchyType: '',
      planGroup: '',
      planGroupId: '',
      planGroupSortOrder: '',
      prorateOnActivate: '',
      prorateOnDeactivate: '',
      planCapabilities: const <AddOnsPrimaryPlanCapabilityModel>[],
      planBuckets: planBuckets,
      channelTypes: '',
      vipTypes: '',
      roles: '',
      cugs: '',
      sugs: '',
      unlimitedBuckets: '',
      activeCCard: '',
      subscriberLines: '',
      purchaseLimit: '',
      purchaseLimitStartDate: '',
      purchaseLimitEndDate: '',
      contractAge: '',
      activatedAge: '',
      contractTerm: '',
      islands: '',
      rank: '',
      creditClass: '',
      vatAmount: 0,
      planSortOrder: '',
      dataRules: null,
    );
  }

  String _buildAddOnLabel(AddOnsPrimaryPlanModel addOnPlan) {
    final firstBucket =
        addOnPlan.planBuckets.isEmpty ? null : addOnPlan.planBuckets.first;

    if (firstBucket == null) {
      return 'balance';
    }

    switch (firstBucket.name.trim().toLowerCase()) {
      case 'data':
        return 'data balance';
      case 'minutes':
        return 'minutes balance';
      case 'texts':
        return 'text balance';
      default:
        return 'balance';
    }
  }

  String _buildAddOnValue(AddOnsPrimaryPlanModel addOnPlan) {
    final firstBucket =
        addOnPlan.planBuckets.isEmpty ? null : addOnPlan.planBuckets.first;

    if (firstBucket == null) {
      return '';
    }

    final amountText =
        firstBucket.amount == firstBucket.amount.truncateToDouble()
            ? firstBucket.amount.toInt().toString()
            : firstBucket.amount.toString();
    return '$amountText${firstBucket.unit.trim().toLowerCase()}';
  }
}
