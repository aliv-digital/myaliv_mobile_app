/// Dedicated model for Roaming tab API data.
///
/// Goals:
/// 1. Parse API safely (null/mixed-type tolerant).
/// 2. Expose typed properties for easy UI integration from state.
/// 3. Keep raw payload optional for debug-only use (memory safe by default).
class RoamingPlanModel {
  const RoamingPlanModel({
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

  // Core identifiers
  final String planId;
  final String planName;
  final String planType;
  final String frequency;

  // Basic commercial fields
  final String planDescription;
  final double planAmount;
  final String paymentOption;
  final double vatAmount;

  // Lifecycle/metadata fields
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

  // Benefit summary fields
  final double voice;
  final double data;
  final int sms;
  final String mtSubscriptionId;
  final bool voiceUnlimited;
  final bool dataUnlimited;
  final bool smsUnlimited;

  // Group/sort fields
  final String hierarchyType;
  final String planGroup;
  final String planGroupId;
  final String planGroupSortOrder;
  final String planSortOrder;

  // Rule/policy fields
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

  // Channel/access fields
  final String channelTypes;
  final String vipTypes;
  final String roles;
  final String cugs;
  final String sugs;
  final String unlimitedBuckets;

  // Nested fields
  final List<RoamingPlanModel> availableBoltOns;
  final List<RoamingPlanCapabilityModel> planCapabilities;
  final List<RoamingPlanBucketModel> planBuckets;
  final RoamingPlanDataRulesModel? dataRules;

  // Full raw object (optional, debug-only to reduce runtime memory).
  final Map<String, dynamic>? rawPayload;

  /// Build one `RoamingPlanModel` from one API item map.
  ///
  /// This parser is intentionally defensive to avoid runtime crashes.
  factory RoamingPlanModel.fromApiMap(
    Map<String, dynamic> map, {
    bool includeRawPayload = false,
  }) {
    final Map<String, dynamic> safeMap = _toStringKeyedMap(map);

    return RoamingPlanModel(
      planId: _asString(safeMap['PlanID']),
      planName: _asString(safeMap['PlanName']),
      planDescription: _asString(safeMap['PlanDescription']),
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
            (Map<String, dynamic> addOnMap) => RoamingPlanModel.fromApiMap(
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
          .map(RoamingPlanCapabilityModel.fromApiMap)
          .toList(growable: false),
      planBuckets: _asMapList(safeMap['PlanBuckets'])
          .map(RoamingPlanBucketModel.fromApiMap)
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
          : RoamingPlanDataRulesModel.fromApiMap(
              _asMapOrNull(safeMap['DataRules'])!,
            ),
      rawPayload:
          includeRawPayload ? Map<String, dynamic>.unmodifiable(safeMap) : null,
    );
  }

  /// Strict Roaming filter rule from requirement.
  /// - PlanType = A
  /// - PlanGroup = roaming
  bool get isStrictRoamingPlan {
    return planType.trim().toUpperCase() == 'A' &&
        planGroup.trim().toLowerCase() == 'roaming';
  }

  /// Convenient list forms for UI chips/dropdowns.
  List<String> get channelTypeList => _toCsvList(channelTypes);
  List<String> get vipTypeList => _toCsvList(vipTypes);
  List<String> get roleList => _toCsvList(roles);

  /// Safe date parsing helper for UI formatting.
  /// Returns `null` when source date is empty/invalid.
  DateTime? get startDateTime => _tryParseApiDate(startDate);
  DateTime? get endDateTime => _tryParseApiDate(endDate);

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

  static String _asString(dynamic value) => value?.toString().trim() ?? '';

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

  static List<String> _toCsvList(String value) {
    if (value.trim().isEmpty) return const <String>[];
    return value
        .split(',')
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static DateTime? _tryParseApiDate(String value) {
    if (value.trim().isEmpty) return null;

    final String isoCandidate = value.replaceFirst(' ', 'T');
    final DateTime? isoParsed = DateTime.tryParse(isoCandidate);
    if (isoParsed != null) return isoParsed;

    final RegExp meridiemPattern = RegExp(
      r'^(\d{1,2})/(\d{1,2})/(\d{4}) (\d{1,2}):(\d{2}):(\d{2}) (AM|PM)$',
      caseSensitive: false,
    );
    final RegExpMatch? match = meridiemPattern.firstMatch(value.trim());
    if (match == null) return null;

    final int month = int.tryParse(match.group(1) ?? '') ?? 1;
    final int day = int.tryParse(match.group(2) ?? '') ?? 1;
    final int year = int.tryParse(match.group(3) ?? '') ?? 1970;
    int hour = int.tryParse(match.group(4) ?? '') ?? 0;
    final int minute = int.tryParse(match.group(5) ?? '') ?? 0;
    final int second = int.tryParse(match.group(6) ?? '') ?? 0;
    final String meridiem = (match.group(7) ?? '').toUpperCase();

    if (meridiem == 'PM' && hour < 12) hour += 12;
    if (meridiem == 'AM' && hour == 12) hour = 0;

    return DateTime(year, month, day, hour, minute, second);
  }
}

/// Plan capability block from API payload.
class RoamingPlanCapabilityModel {
  const RoamingPlanCapabilityModel({
    required this.planCapabilityName,
    required this.planCapabilityType,
  });

  final String planCapabilityName;
  final String planCapabilityType;

  factory RoamingPlanCapabilityModel.fromApiMap(Map<String, dynamic> map) {
    return RoamingPlanCapabilityModel(
      planCapabilityName: RoamingPlanModel._asString(map['PlanCapabilityName']),
      planCapabilityType: RoamingPlanModel._asString(map['PlanCapabilityType']),
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
class RoamingPlanBucketModel {
  const RoamingPlanBucketModel({
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

  factory RoamingPlanBucketModel.fromApiMap(Map<String, dynamic> map) {
    return RoamingPlanBucketModel(
      name: RoamingPlanModel._asString(map['Name']),
      amount: RoamingPlanModel._asDouble(map['Amount']),
      unit: RoamingPlanModel._asString(map['Unit']),
      bucketOrder: RoamingPlanModel._asString(map['BucketOrder']),
      suppress: RoamingPlanModel._asBool(map['Suppress']),
      unlimited: RoamingPlanModel._asBool(map['Unlimited']),
      bucketUnit: RoamingPlanModel._asString(map['BucketUnit']),
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
class RoamingPlanDataRulesModel {
  const RoamingPlanDataRulesModel({
    required this.planId,
    required this.requireAltContactPhone,
  });

  final int planId;
  final bool requireAltContactPhone;

  factory RoamingPlanDataRulesModel.fromApiMap(Map<String, dynamic> map) {
    return RoamingPlanDataRulesModel(
      planId: RoamingPlanModel._asInt(map['PlanId']),
      requireAltContactPhone:
          RoamingPlanModel._asBool(map['RequireAltContactPhone']),
    );
  }

  Map<String, dynamic> toDebugMap() {
    return <String, dynamic>{
      'PlanId': planId,
      'RequireAltContactPhone': requireAltContactPhone,
    };
  }
}
