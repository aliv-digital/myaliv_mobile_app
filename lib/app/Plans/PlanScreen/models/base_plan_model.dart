import 'package:core/core.dart';

/// Unified plan model for all plan types (Daily, Weekly, Monthly, Roaming, etc.)
///
/// This model consolidates 8 previously duplicated models into one.
/// Differences between plan types are handled by API filtering logic,
/// not by separate model classes.
///
/// Goals:
/// 1. Parse API safely (null/mixed-type tolerant)
/// 2. Single source of truth for all plan data
/// 3. Eliminate code duplication (~3,450 lines saved)
/// 4. Keep raw payload optional for debugging
///
/// Replaces:
/// - DailyPlanModel
/// - WeeklyPlanModel
/// - MonthlyPlanModel
/// - RoamingPlanModel
/// - RoamEasyPlanModel
/// - MifiPlanModel
/// - LibertyGlobalPlanModel
/// - AddOnsPrimaryPlanModel
class BasePlanModel {
  const BasePlanModel({
    required this.planId,
    required this.planName,
    required this.planDescription,
    required this.planAmount,
    required this.planType,
    required this.frequency,
    required this.featureCodes,
    required this.startDate,
    required this.endDate,
    required this.planDetails,
    required this.createdBy,
    required this.publishedBy,
    required this.retiredBy,
    required this.autoRenew,
    required this.isEditable,
    required this.voice,
    required this.data,
    required this.sms,
    required this.mtSubscriptionId,
    required this.voiceUnlimited,
    required this.dataUnlimited,
    required this.smsUnlimited,
    required this.availableBoltOns,
    required this.currentlyAssigned,
    required this.planRenewable,
    required this.paymentOption,
    required this.canIcb,
    required this.hierarchyType,
    required this.planGroup,
    required this.planGroupId,
    required this.planGroupSortOrder,
    required this.prorateOnActivate,
    required this.prorateOnDeactivate,
    required this.planCapabilities,
    required this.planBuckets,
    required this.channelTypes,
    required this.vipTypes,
    required this.roles,
    required this.cugs,
    required this.sugs,
    required this.unlimitedBuckets,
    required this.activeCCard,
    required this.subscriberLines,
    required this.purchaseLimit,
    required this.purchaseLimitStartDate,
    required this.purchaseLimitEndDate,
    required this.contractAge,
    required this.activatedAge,
    required this.contractTerm,
    required this.islands,
    required this.rank,
    required this.creditClass,
    required this.vatAmount,
    required this.planSortOrder,
    required this.dataRules,
    this.rawPayload,
  });

  // ===== Core identifiers =====
  final String planId;
  final String planName;
  final String planType;
  final String frequency;

  // ===== Basic commercial fields =====
  final String planDescription;
  final double planAmount;
  final String paymentOption;
  final double vatAmount;

  // ===== Lifecycle/metadata fields =====
  final String featureCodes;
  final String startDate;
  final String endDate;
  final String planDetails;
  final String createdBy;
  final String publishedBy;
  final String retiredBy;
  final bool autoRenew;
  final bool isEditable;
  final bool currentlyAssigned;
  final bool planRenewable;

  // ===== Benefit summary fields =====
  final double voice;
  final double data;
  final int sms;
  final String mtSubscriptionId;
  final bool voiceUnlimited;
  final bool dataUnlimited;
  final bool smsUnlimited;

  // ===== Group/sort fields =====
  final String hierarchyType;
  final String planGroup;
  final String planGroupId;
  final String planGroupSortOrder;
  final String planSortOrder;

  // ===== Rule/policy fields =====
  final String canIcb;
  final String prorateOnActivate;
  final String prorateOnDeactivate;
  final String activeCCard;
  final String subscriberLines;
  final String purchaseLimit;
  final String purchaseLimitStartDate;
  final String purchaseLimitEndDate;
  final String contractAge;
  final String activatedAge;
  final String contractTerm;
  final String islands;
  final String rank;
  final String creditClass;

  // ===== Channel/access fields =====
  final String channelTypes;
  final String vipTypes;
  final String roles;
  final String cugs;
  final String sugs;
  final String unlimitedBuckets;

  // ===== Nested fields =====
  final List<BasePlanModel> availableBoltOns;
  final List<BasePlanCapabilityModel> planCapabilities;
  final List<BasePlanBucketModel> planBuckets;
  final BasePlanDataRulesModel? dataRules;

  // ===== Debug field (optional) =====
  final Map<String, dynamic>? rawPayload;

  // ===== Factory Constructor =====

  /// Build one `BasePlanModel` from API item map.
  ///
  /// This parser is intentionally defensive to avoid runtime crashes.
  factory BasePlanModel.fromApiMap(
    Map<String, dynamic> map, {
    bool includeRawPayload = false,
  }) {
    final Map<String, dynamic> safeMap = _toStringKeyedMap(map);

    return BasePlanModel(
      planId: _asString(safeMap['PlanID']),
      planName: _asString(safeMap['PlanName']),
      planDescription: _asStringWithoutNewlines(safeMap['PlanDescription']),
      planAmount: _asDouble(safeMap['PlanAmount']),
      planType: _asString(safeMap['PlanType']),
      frequency: _asString(safeMap['Frequency']),
      featureCodes: _asString(safeMap['FeatureCodes']),
      startDate: _asString(safeMap['StartDate']),
      endDate: _asString(safeMap['EndDate']),
      planDetails: _asString(safeMap['PlanDetails']),
      createdBy: _asString(safeMap['CreatedBy']),
      publishedBy: _asString(safeMap['PublishedBy']),
      retiredBy: _asString(safeMap['RetiredBy']),
      autoRenew: _asBool(safeMap['AutoRenew']),
      isEditable: _asBool(safeMap['IsEditable']),
      voice: _asDouble(safeMap['Voice']),
      data: _asDouble(safeMap['Data']),
      sms: _asInt(safeMap['SMS']),
      mtSubscriptionId: _asString(safeMap['MTSubscriptionID']),
      voiceUnlimited: _asBool(safeMap['VoiceUnlimited']),
      dataUnlimited: _asBool(safeMap['DataUnlimited']),
      smsUnlimited: _asBool(safeMap['SMSUnlimited']),
      availableBoltOns: _asMapList(safeMap['AvailableBoltOns'])
          .map(
            (Map<String, dynamic> addOnMap) => BasePlanModel.fromApiMap(
              addOnMap,
              includeRawPayload: includeRawPayload,
            ),
          )
          .toList(growable: false),
      currentlyAssigned: _asBool(safeMap['CurrentlyAssigned']),
      planRenewable: _asBool(safeMap['PlanRenewable']),
      paymentOption: _asString(safeMap['PaymentOption']),
      canIcb: _asString(safeMap['CanICB']),
      hierarchyType: _asString(safeMap['HierarchyType']),
      planGroup: _asString(safeMap['PlanGroup']),
      planGroupId: _asString(safeMap['PlanGroupID']),
      planGroupSortOrder: _asString(safeMap['PlanGroupSortOrder']),
      prorateOnActivate: _asString(safeMap['ProrateOnActivate']),
      prorateOnDeactivate: _asString(safeMap['ProrateOnDeactivate']),
      planCapabilities: _asMapList(safeMap['PlanCapabilities'])
          .map(BasePlanCapabilityModel.fromApiMap)
          .toList(growable: false),
      planBuckets: _asMapList(safeMap['PlanBuckets'])
          .map(BasePlanBucketModel.fromApiMap)
          .toList(growable: false),
      channelTypes: _asString(safeMap['ChannelTypes']),
      vipTypes: _asString(safeMap['VIPTypes']),
      roles: _asString(safeMap['Roles']),
      cugs: _asString(safeMap['Cugs']),
      sugs: _asString(safeMap['Sugs']),
      unlimitedBuckets: _asString(safeMap['UnlimitedBuckets']),
      activeCCard: _asString(safeMap['ActiveCCard']),
      subscriberLines: _asString(safeMap['SubscriberLines']),
      purchaseLimit: _asString(safeMap['PurchaseLimit']),
      purchaseLimitStartDate: _asString(safeMap['PurchaseLimitStartDate']),
      purchaseLimitEndDate: _asString(safeMap['PurchaseLimitEndDate']),
      contractAge: _asString(safeMap['ContractAge']),
      activatedAge: _asString(safeMap['ActivatedAge']),
      contractTerm: _asString(safeMap['ContractTerm']),
      islands: _asString(safeMap['Islands']),
      rank: _asString(safeMap['Rank']),
      creditClass: _asString(safeMap['CreditClass']),
      vatAmount: _asDouble(safeMap['VATAmount']),
      planSortOrder: _asString(safeMap['PlanSortOrder']),
      dataRules: _asMapOrNull(safeMap['DataRules']) == null
          ? null
          : BasePlanDataRulesModel.fromApiMap(
              _asMapOrNull(safeMap['DataRules'])!,
            ),
      rawPayload:
          includeRawPayload ? Map<String, dynamic>.unmodifiable(safeMap) : null,
    );
  }

  /// Returns a new `BasePlanModel` with selected fields overridden.
  /// Used by `PlansState.standAlonePlansForBucketUsage` to merge duplicate
  /// stand-alone purchases (same `planId`, different date ranges) into a
  /// single card spanning the earliest start to the latest end.
  BasePlanModel copyWith({
    String? startDate,
    String? endDate,
  }) {
    return BasePlanModel(
      planId: planId,
      planName: planName,
      planDescription: planDescription,
      planAmount: planAmount,
      planType: planType,
      frequency: frequency,
      featureCodes: featureCodes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      planDetails: planDetails,
      createdBy: createdBy,
      publishedBy: publishedBy,
      retiredBy: retiredBy,
      autoRenew: autoRenew,
      isEditable: isEditable,
      voice: voice,
      data: data,
      sms: sms,
      mtSubscriptionId: mtSubscriptionId,
      voiceUnlimited: voiceUnlimited,
      dataUnlimited: dataUnlimited,
      smsUnlimited: smsUnlimited,
      availableBoltOns: availableBoltOns,
      currentlyAssigned: currentlyAssigned,
      planRenewable: planRenewable,
      paymentOption: paymentOption,
      canIcb: canIcb,
      hierarchyType: hierarchyType,
      planGroup: planGroup,
      planGroupId: planGroupId,
      planGroupSortOrder: planGroupSortOrder,
      prorateOnActivate: prorateOnActivate,
      prorateOnDeactivate: prorateOnDeactivate,
      planCapabilities: planCapabilities,
      planBuckets: planBuckets,
      channelTypes: channelTypes,
      vipTypes: vipTypes,
      roles: roles,
      cugs: cugs,
      sugs: sugs,
      unlimitedBuckets: unlimitedBuckets,
      activeCCard: activeCCard,
      subscriberLines: subscriberLines,
      purchaseLimit: purchaseLimit,
      purchaseLimitStartDate: purchaseLimitStartDate,
      purchaseLimitEndDate: purchaseLimitEndDate,
      contractAge: contractAge,
      activatedAge: activatedAge,
      contractTerm: contractTerm,
      islands: islands,
      rank: rank,
      creditClass: creditClass,
      vatAmount: vatAmount,
      planSortOrder: planSortOrder,
      dataRules: dataRules,
      rawPayload: rawPayload,
    );
  }

  // ===== Computed Getters (ONLY used ones - removed dead code) =====

  /// Backend dates come as UTC. We localize at the getter so every
  /// downstream formatter (`DateFormat(...).format(...)`, the
  /// `DateTimeX` extension, comparisons against `DateTime.now()`)
  /// sees the device's wall-clock time without each call site
  /// having to remember to convert.
  DateTime? get startDateTime => startDate.toLocalApiDate();

  DateTime? get endDateTime => endDate.toLocalApiDate();

  // ===== Plan type helpers =====
  // PlanType codes: P = Primary, S = Stand-alone, A = Add-on.
  bool get isPrimaryPlan => planType.toUpperCase() == 'P';
  bool get isStandAlonePlan => planType.toUpperCase() == 'S';
  bool get isAddOnPlan => planType.toUpperCase() == 'A';

  // ===== Debug Method =====

  /// Full typed map for debugging or temporary logging.
  Map<String, dynamic> toDebugMap() {
    return <String, dynamic>{
      'PlanID': planId,
      'PlanName': planName,
      'PlanDescription': planDescription,
      'PlanAmount': planAmount,
      'PlanType': planType,
      'Frequency': frequency,
      'FeatureCodes': featureCodes,
      'StartDate': startDate,
      'EndDate': endDate,
      'PlanDetails': planDetails,
      'CreatedBy': createdBy,
      'PublishedBy': publishedBy,
      'RetiredBy': retiredBy,
      'AutoRenew': autoRenew,
      'IsEditable': isEditable,
      'Voice': voice,
      'Data': data,
      'SMS': sms,
      'MTSubscriptionID': mtSubscriptionId,
      'VoiceUnlimited': voiceUnlimited,
      'DataUnlimited': dataUnlimited,
      'SMSUnlimited': smsUnlimited,
      'AvailableBoltOns':
          availableBoltOns.map((item) => item.toDebugMap()).toList(),
      'CurrentlyAssigned': currentlyAssigned,
      'PlanRenewable': planRenewable,
      'PaymentOption': paymentOption,
      'CanICB': canIcb,
      'HierarchyType': hierarchyType,
      'PlanGroup': planGroup,
      'PlanGroupID': planGroupId,
      'PlanGroupSortOrder': planGroupSortOrder,
      'ProrateOnActivate': prorateOnActivate,
      'ProrateOnDeactivate': prorateOnDeactivate,
      'PlanCapabilities':
          planCapabilities.map((item) => item.toDebugMap()).toList(),
      'PlanBuckets': planBuckets.map((item) => item.toDebugMap()).toList(),
      'ChannelTypes': channelTypes,
      'VIPTypes': vipTypes,
      'Roles': roles,
      'Cugs': cugs,
      'Sugs': sugs,
      'UnlimitedBuckets': unlimitedBuckets,
      'ActiveCCard': activeCCard,
      'SubscriberLines': subscriberLines,
      'PurchaseLimit': purchaseLimit,
      'PurchaseLimitStartDate': purchaseLimitStartDate,
      'PurchaseLimitEndDate': purchaseLimitEndDate,
      'ContractAge': contractAge,
      'ActivatedAge': activatedAge,
      'ContractTerm': contractTerm,
      'Islands': islands,
      'Rank': rank,
      'CreditClass': creditClass,
      'VATAmount': vatAmount,
      'PlanSortOrder': planSortOrder,
      'DataRules': dataRules?.toDebugMap(),
      'HasRawPayload': rawPayload != null,
    };
  }

  // ===== Parsing Utilities =====

  static String _asString(dynamic value) => value?.toString().trim() ?? '';

  /// Same as _asString but also replaces newlines with spaces.
  /// Used for fields like planDescription that may contain embedded \n.
  static String _asStringWithoutNewlines(dynamic value) {
    final String str = value?.toString().trim() ?? '';
    return str.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final String normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'y';
  }

  static Map<String, dynamic> _toStringKeyedMap(Map<dynamic, dynamic> map) {
    return map.map(
      (dynamic key, dynamic value) =>
          MapEntry<String, dynamic>(key.toString(), value),
    );
  }

  static Map<String, dynamic>? _asMapOrNull(dynamic value) {
    if (value is! Map) return null;
    return _toStringKeyedMap(value);
  }

  static List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];

    return value
        .whereType<Map>()
        .map(_toStringKeyedMap)
        .toList(growable: false);
  }

}

// ===== Nested Models =====

/// Plan capability block from API payload.
class BasePlanCapabilityModel {
  const BasePlanCapabilityModel({
    required this.planCapabilityName,
    required this.planCapabilityType,
  });

  final String planCapabilityName;
  final String planCapabilityType;

  factory BasePlanCapabilityModel.fromApiMap(Map<String, dynamic> map) {
    return BasePlanCapabilityModel(
      planCapabilityName: BasePlanModel._asString(map['PlanCapabilityName']),
      planCapabilityType: BasePlanModel._asString(map['PlanCapabilityType']),
    );
  }

  Map<String, dynamic> toDebugMap() {
    return <String, dynamic>{
      'PlanCapabilityName': planCapabilityName,
      'PlanCapabilityType': planCapabilityType,
    };
  }
}

/// One bucket inside a plan payload.
class BasePlanBucketModel {
  const BasePlanBucketModel({
    required this.name,
    required this.amount,
    required this.unit,
    required this.bucketOrder,
    required this.suppress,
    required this.unlimited,
    required this.bucketUnit,
  });

  final String name;
  final double amount;
  final String unit;
  final String bucketOrder;
  final bool suppress;
  final bool unlimited;
  final String bucketUnit;

  factory BasePlanBucketModel.fromApiMap(Map<String, dynamic> map) {
    return BasePlanBucketModel(
      name: BasePlanModel._asString(map['Name']),
      amount: BasePlanModel._asDouble(map['Amount']),
      unit: BasePlanModel._asString(map['Unit']),
      bucketOrder: BasePlanModel._asString(map['BucketOrder']),
      suppress: BasePlanModel._asBool(map['Suppress']),
      unlimited: BasePlanModel._asBool(map['Unlimited']),
      bucketUnit: BasePlanModel._asString(map['BucketUnit']),
    );
  }

  Map<String, dynamic> toDebugMap() {
    return <String, dynamic>{
      'Name': name,
      'Amount': amount,
      'Unit': unit,
      'BucketOrder': bucketOrder,
      'Suppress': suppress,
      'Unlimited': unlimited,
      'BucketUnit': bucketUnit,
    };
  }
}

/// DataRules nested object from API payload.
class BasePlanDataRulesModel {
  const BasePlanDataRulesModel({
    required this.planId,
    required this.requireAltContactPhone,
  });

  final int planId;
  final bool requireAltContactPhone;

  factory BasePlanDataRulesModel.fromApiMap(Map<String, dynamic> map) {
    return BasePlanDataRulesModel(
      planId: BasePlanModel._asInt(map['PlanId']),
      requireAltContactPhone:
          BasePlanModel._asBool(map['RequireAltContactPhone']),
    );
  }

  Map<String, dynamic> toDebugMap() {
    return <String, dynamic>{
      'PlanId': planId,
      'RequireAltContactPhone': requireAltContactPhone,
    };
  }
}
