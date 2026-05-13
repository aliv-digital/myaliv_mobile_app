import 'dart:convert';

import 'package:equatable/equatable.dart';

class HomePlanPromoResponse extends Equatable {
  const HomePlanPromoResponse({
    required this.promoCodeId,
    required this.definition,
    this.value,
    required this.deviceId,
    required this.addedDate,
    required this.addedBy,
    this.addedByName,
    required this.usedDate,
    required this.usedBy,
    this.usedByName,
    required this.orderId,
    required this.endDate,
  });

  final int promoCodeId;
  final PromoCodeDefinition definition;
  final dynamic value;
  final int deviceId;
  final DateTime? addedDate;
  final int addedBy;
  final String? addedByName;
  final DateTime? usedDate;
  final int usedBy;
  final String? usedByName;
  final int orderId;
  final DateTime? endDate;

  factory HomePlanPromoResponse.fromDynamic(dynamic source) {
    if (source is String) {
      final decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) {
        return HomePlanPromoResponse.fromJson(decoded);
      }
      if (decoded is Map) {
        return HomePlanPromoResponse.fromJson(_stringKeyMap(decoded));
      }
    }

    if (source is Map<String, dynamic>) {
      return HomePlanPromoResponse.fromJson(source);
    }

    if (source is Map) {
      return HomePlanPromoResponse.fromJson(_stringKeyMap(source));
    }

    throw const FormatException('Invalid promo response format.');
  }

  factory HomePlanPromoResponse.fromJson(Map<String, dynamic> json) {
    return HomePlanPromoResponse(
      promoCodeId: _asInt(json['PromoCodeID']),
      definition: PromoCodeDefinition.fromJson(_asMap(json['Definition'])),
      value: json['Value'],
      deviceId: _asInt(json['DeviceID']),
      addedDate: _asDateTime(json['AddedDate']),
      addedBy: _asInt(json['AddedBy']),
      addedByName: _asStringOrNull(json['AddedByName']),
      usedDate: _asDateTime(json['UsedDate']),
      usedBy: _asInt(json['UsedBy']),
      usedByName: _asStringOrNull(json['UsedByName']),
      orderId: _asInt(json['OrderID']),
      endDate: _asDateTime(json['EndDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'PromoCodeID': promoCodeId,
      'Definition': definition.toJson(),
      'Value': value,
      'DeviceID': deviceId,
      'AddedDate': _dateToJson(addedDate),
      'AddedBy': addedBy,
      'AddedByName': addedByName,
      'UsedDate': _dateToJson(usedDate),
      'UsedBy': usedBy,
      'UsedByName': usedByName,
      'OrderID': orderId,
      'EndDate': _dateToJson(endDate),
    };
  }

  dynamic valueAtPath(String path) {
    dynamic current = toJson();
    for (final segment in path.split('.')) {
      if (current is! Map) return null;
      current = current[segment];
    }
    return current;
  }

  String textAtPath(String path, {String fallback = ''}) {
    final value = valueAtPath(path);
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? fallback : text;
  }

  bool get hasPromoCode => promoCodeId > 0;

  bool get isApplied => hasPromoCode;

  @override
  List<Object?> get props => [
    promoCodeId,
    definition,
    value,
    deviceId,
    addedDate,
    addedBy,
    addedByName,
    usedDate,
    usedBy,
    usedByName,
    orderId,
    endDate,
  ];
}

class PromoCodeDefinition extends Equatable {
  const PromoCodeDefinition({
    required this.promoCodeDefId,
    this.promoCodePrefix,
    this.promoCodeName,
    this.promoCodeDesc,
    this.unitType,
    required this.unitQty,
    required this.startDate,
    required this.endDate,
    required this.createdDate,
    this.createdBy,
    required this.agentCreatable,
    this.planList,
    required this.isActive,
    required this.days,
  });

  final int promoCodeDefId;
  final String? promoCodePrefix;
  final String? promoCodeName;
  final String? promoCodeDesc;
  final String? unitType;
  final double unitQty;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdDate;
  final String? createdBy;
  final bool agentCreatable;
  final dynamic planList;
  final bool isActive;
  final int days;

  factory PromoCodeDefinition.fromJson(Map<String, dynamic> json) {
    return PromoCodeDefinition(
      promoCodeDefId: _asInt(json['PromoCodeDefID']),
      promoCodePrefix: _asStringOrNull(json['PromoCodePrefix']),
      promoCodeName: _asStringOrNull(json['PromoCodeName']),
      promoCodeDesc: _asStringOrNull(json['PromoCodeDesc']),
      unitType: _asStringOrNull(json['UnitType']),
      unitQty: _asDouble(json['UnitQty']),
      startDate: _asDateTime(json['StartDate']),
      endDate: _asDateTime(json['EndDate']),
      createdDate: _asDateTime(json['CreatedDate']),
      createdBy: _asStringOrNull(json['CreatedBy']),
      agentCreatable: _asBool(json['AgentCreatable']),
      planList: json['PlanList'],
      isActive: _asBool(json['IsActive']),
      days: _asInt(json['Days']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'PromoCodeDefID': promoCodeDefId,
      'PromoCodePrefix': promoCodePrefix,
      'PromoCodeName': promoCodeName,
      'PromoCodeDesc': promoCodeDesc,
      'UnitType': unitType,
      'UnitQty': unitQty,
      'StartDate': _dateToJson(startDate),
      'EndDate': _dateToJson(endDate),
      'CreatedDate': _dateToJson(createdDate),
      'CreatedBy': createdBy,
      'AgentCreatable': agentCreatable,
      'PlanList': planList,
      'IsActive': isActive,
      'Days': days,
    };
  }

  @override
  List<Object?> get props => [
    promoCodeDefId,
    promoCodePrefix,
    promoCodeName,
    promoCodeDesc,
    unitType,
    unitQty,
    startDate,
    endDate,
    createdDate,
    createdBy,
    agentCreatable,
    planList,
    isActive,
    days,
  ];
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return _stringKeyMap(value);
  return <String, dynamic>{};
}

Map<String, dynamic> _stringKeyMap(Map<dynamic, dynamic> source) {
  return source.map((key, value) => MapEntry(key.toString(), value));
}

String? _asStringOrNull(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text == 'null') return null;
  return text;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  final text = value?.toString().toLowerCase().trim();
  return text == 'true' || text == '1';
}

DateTime? _asDateTime(dynamic value) {
  final text = _asStringOrNull(value);
  if (text == null) return null;
  return DateTime.tryParse(text);
}

String? _dateToJson(DateTime? value) {
  return value?.toIso8601String();
}
