import 'package:core/core.dart';

/// Dedicated model for Postpaid roaming plan API data.
///
/// Goals:
/// 1. Parse API safely (null/mixed-type tolerant).
/// 2. Keep the raw postpaid payload mapped into typed fields.
/// 3. Expose simple UI getters for the postpaid plans screen.
class HomePlansPostPaidPlanModel {
  const HomePlansPostPaidPlanModel({
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

  final String planId;
  final String planName;
  final String planDescription;
  final double planAmount;
  final String planType;
  final String frequency;
  final String featureCodes;
  final String startDate;
  final String endDate;
  final String planDetails;
  final String createdBy;
  final String publishedBy;
  final String retiredBy;
  final bool autoRenew;
  final bool isEditable;
  final double voice;
  final double data;
  final int sms;
  final String mtSubscriptionId;
  final bool voiceUnlimited;
  final bool dataUnlimited;
  final bool smsUnlimited;
  final List<HomePlansPostPaidPlanModel> availableBoltOns;
  final bool currentlyAssigned;
  final bool planRenewable;
  final String paymentOption;
  final String canIcb;
  final String hierarchyType;
  final String planGroup;
  final String planGroupId;
  final String planGroupSortOrder;
  final String prorateOnActivate;
  final String prorateOnDeactivate;
  final List<HomePlansPostPaidPlanCapabilityModel> planCapabilities;
  final List<HomePlansPostPaidPlanBucketModel> planBuckets;
  final String channelTypes;
  final String vipTypes;
  final String roles;
  final String cugs;
  final String sugs;
  final String unlimitedBuckets;
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
  final double vatAmount;
  final String planSortOrder;
  final HomePlansPostPaidPlanDataRulesModel? dataRules;
  final Map<String, dynamic>? rawPayload;

  factory HomePlansPostPaidPlanModel.fromApiMap(
    Map<String, dynamic> map, {
    bool includeRawPayload = false,
  }) {
    final safeMap = _toStringKeyedMap(map);

    return HomePlansPostPaidPlanModel(
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
            (addOnMap) => HomePlansPostPaidPlanModel.fromApiMap(
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
          .map(HomePlansPostPaidPlanCapabilityModel.fromApiMap)
          .toList(growable: false),
      planBuckets: _asMapList(safeMap['PlanBuckets'])
          .map(HomePlansPostPaidPlanBucketModel.fromApiMap)
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
          : HomePlansPostPaidPlanDataRulesModel.fromApiMap(
              _asMapOrNull(safeMap['DataRules'])!,
            ),
      rawPayload:
          includeRawPayload ? Map<String, dynamic>.unmodifiable(safeMap) : null,
    );
  }

  bool get isStrictPostPaidRoamingPlan {
    return planType.trim().toUpperCase() == 'A' &&
        planGroup.trim().toLowerCase() == 'roaming' &&
        paymentOption.trim().toLowerCase() == 'postpay';
  }

  DateTime? get startDateTime => startDate.toLocalApiDate();
  DateTime? get endDateTime => endDate.toLocalApiDate();
  double get planAmountWithVat => planAmount + vatAmount; // need to show this

  String get durationText {
    switch (frequency.trim().toUpperCase()) {
      case 'D':
        return '1 day';
      case '3':
        return '3 days';
      case '5':
        return '5 days';
      case 'W':
        return '7 days';
      case 'T':
        return '10 days';
      case 'B':
      case 'H':
        return '14 days';
      case 'M':
        return '30 days';
      case 'S':
        return '60 days';
      case 'N':
        return '90 days';
      case 'A':
        return '1 year';
      default:
        return frequency.trim().isEmpty ? '--' : frequency;
    }
  }

  HomePlansPostPaidPlanBucketModel? get primaryDataBucket {
    if (planBuckets.isEmpty) {
      return null;
    }

    for (final bucket in planBuckets) {
      if (bucket.name.trim().toLowerCase().contains('roaming')) {
        return bucket;
      }
    }

    return planBuckets.first;
  }

  String get primaryDataLabel {
    final bucket = primaryDataBucket;
    if (bucket == null) {
      return 'data balance';
    }

    final normalized = bucket.name.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'data balance';
    }

    if (normalized == 'data' ||
        normalized == 'roaming data' ||
        normalized == 'roam data us/can') {
      return 'data balance';
    }

    return '$normalized balance';
  }

  String get primaryDataValue {
    final bucket = primaryDataBucket;
    if (bucket == null) {
      final fallbackAmount = _formatWholeOrDecimal(data);
      return fallbackAmount == '0' ? '' : '${fallbackAmount}gb';
    }

    final amountText = _formatWholeOrDecimal(bucket.amount);
    final unitText = bucket.unit.trim().toLowerCase();

    if (unitText.isEmpty) {
      return amountText;
    }

    return '$amountText$unitText';
  }

  String get descriptionText {
    final description = planDescription.trim();
    if (description.isNotEmpty) {
      return description;
    }

    final details = _stripHtml(planDetails).trim();
    if (details.isNotEmpty) {
      return details;
    }

    return '--';
  }

  static Map<String, dynamic> _toStringKeyedMap(Map<String, dynamic> input) {
    return input.map(
      (key, value) => MapEntry<String, dynamic>(key.toString(), value),
    );
  }

  static List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) {
      return const <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map(
          (map) => map.map(
            (dynamic key, dynamic value) =>
                MapEntry<String, dynamic>(key.toString(), value),
          ),
        )
        .toList(growable: false);
  }

  static Map<String, dynamic>? _asMapOrNull(dynamic value) {
    if (value is! Map) {
      return null;
    }

    return value.map(
      (dynamic key, dynamic value) =>
          MapEntry<String, dynamic>(key.toString(), value),
    );
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;

    final normalized = value.toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  static String _formatWholeOrDecimal(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  static String _stripHtml(String value) {
    final buffer = StringBuffer();
    var insideTag = false;

    for (final codeUnit in value.codeUnits) {
      if (codeUnit == 60) {
        insideTag = true;
        continue;
      }

      if (codeUnit == 62) {
        insideTag = false;
        buffer.write(' ');
        continue;
      }

      if (!insideTag) {
        if (_isWhitespace(codeUnit)) {
          buffer.write(' ');
        } else {
          buffer.writeCharCode(codeUnit);
        }
      }
    }

    final normalized = buffer.toString().replaceAll('&nbsp;', ' ');
    final collapsed = StringBuffer();
    var previousWasSpace = false;

    for (final codeUnit in normalized.codeUnits) {
      final isWhitespace = _isWhitespace(codeUnit);
      if (isWhitespace) {
        if (!previousWasSpace) {
          collapsed.write(' ');
        }
        previousWasSpace = true;
        continue;
      }

      collapsed.writeCharCode(codeUnit);
      previousWasSpace = false;
    }

    return collapsed.toString().trim();
  }

  static bool _isWhitespace(int codeUnit) {
    return codeUnit == 9 || codeUnit == 10 || codeUnit == 13 || codeUnit == 32;
  }
}

class HomePlansPostPaidPlanCapabilityModel {
  const HomePlansPostPaidPlanCapabilityModel({
    required this.planCapabilityName,
    required this.planCapabilityType,
  });

  final String planCapabilityName;
  final String planCapabilityType;

  factory HomePlansPostPaidPlanCapabilityModel.fromApiMap(
    Map<String, dynamic> map,
  ) {
    return HomePlansPostPaidPlanCapabilityModel(
      planCapabilityName:
          HomePlansPostPaidPlanModel._asString(map['PlanCapabilityName']),
      planCapabilityType:
          HomePlansPostPaidPlanModel._asString(map['PlanCapabilityType']),
    );
  }
}

class HomePlansPostPaidPlanBucketModel {
  const HomePlansPostPaidPlanBucketModel({
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
  final String suppress;
  final String unlimited;
  final String bucketUnit;

  factory HomePlansPostPaidPlanBucketModel.fromApiMap(
    Map<String, dynamic> map,
  ) {
    return HomePlansPostPaidPlanBucketModel(
      name: HomePlansPostPaidPlanModel._asString(map['Name']),
      amount: HomePlansPostPaidPlanModel._asDouble(map['Amount']),
      unit: HomePlansPostPaidPlanModel._asString(map['Unit']),
      bucketOrder: HomePlansPostPaidPlanModel._asString(map['BucketOrder']),
      suppress: HomePlansPostPaidPlanModel._asString(map['Suppress']),
      unlimited: HomePlansPostPaidPlanModel._asString(map['Unlimited']),
      bucketUnit: HomePlansPostPaidPlanModel._asString(map['BucketUnit']),
    );
  }
}

class HomePlansPostPaidPlanDataRulesModel {
  const HomePlansPostPaidPlanDataRulesModel({
    required this.planId,
    required this.requireAltContactPhone,
  });

  final int planId;
  final bool requireAltContactPhone;

  factory HomePlansPostPaidPlanDataRulesModel.fromApiMap(
    Map<String, dynamic> map,
  ) {
    return HomePlansPostPaidPlanDataRulesModel(
      planId: HomePlansPostPaidPlanModel._asInt(map['PlanId']),
      requireAltContactPhone:
          HomePlansPostPaidPlanModel._asBool(map['RequireAltContactPhone']),
    );
  }
}
