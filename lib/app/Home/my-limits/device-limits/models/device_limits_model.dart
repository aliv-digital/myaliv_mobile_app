/// Data model for device information from Account/devices API
///
/// Contains full device details including limits, settings, and contract info.
/// Currently used for upgrade credit limit screen (max allowed fields).
class DeviceLimitsModel {
  // Device identification
  final String deviceType;
  final int deviceId;
  final String iccid;
  final String imsi;
  final String serialNumber;
  final String model;
  final String tn; // Phone number
  final String? routingNumber;
  final int parentAccountId;
  final String deviceStatus;

  // Auto settings
  final bool autoRenew;
  final bool overRideCoolOff;
  final double roamingLowBalanceThreshold;
  final double roamingTopUpAmount;
  final double balanceThreshold;
  final double autoTopUpAmount;
  final String autoTopUp;
  final bool voiceMailEnabled;

  // Default allowed limits
  final double defaultAllowedRoaming;
  final double defaultAllowedInternational;
  final double defaultAllowedLocalVoice;
  final double defaultAllowedLocalData;
  final double defaultAllowedLocalText;

  // Max allowed limits (used for credit limit screen)
  final double maxAllowedRoaming;
  final double maxAllowedInternational;
  final double maxAllowedLocalVoice;
  final double maxAllowedLocalData;
  final double maxAllowedLocalText;

  // Transfer settings
  final bool canTransferMoney;
  final double perTransTransferMoneyLimit;
  final double perDayTransferMoneyLimit;

  // Profile info
  final String? fName;
  final String? lName;
  final String ocsVersion;
  final String ocsKey;
  final String? island;
  final String salesforceId;
  final String wholeSaleId;
  final String templateId;
  final String? ipAddress;

  // Additional settings
  final bool enableTwoFactor;
  final String musicOnHold;
  final String bNumber;
  final String primaryNumber;
  final String? eid;
  final bool isESim;

  // Nested objects
  final SubscriberContract? subscriberContract;

  const DeviceLimitsModel({
    required this.deviceType,
    required this.deviceId,
    required this.iccid,
    required this.imsi,
    required this.serialNumber,
    required this.model,
    required this.tn,
    this.routingNumber,
    required this.parentAccountId,
    required this.deviceStatus,
    required this.autoRenew,
    required this.overRideCoolOff,
    required this.roamingLowBalanceThreshold,
    required this.roamingTopUpAmount,
    required this.balanceThreshold,
    required this.autoTopUpAmount,
    required this.autoTopUp,
    required this.voiceMailEnabled,
    required this.defaultAllowedRoaming,
    required this.defaultAllowedInternational,
    required this.defaultAllowedLocalVoice,
    required this.defaultAllowedLocalData,
    required this.defaultAllowedLocalText,
    required this.maxAllowedRoaming,
    required this.maxAllowedInternational,
    required this.maxAllowedLocalVoice,
    required this.maxAllowedLocalData,
    required this.maxAllowedLocalText,
    required this.canTransferMoney,
    required this.perTransTransferMoneyLimit,
    required this.perDayTransferMoneyLimit,
    this.fName,
    this.lName,
    required this.ocsVersion,
    required this.ocsKey,
    this.island,
    required this.salesforceId,
    required this.wholeSaleId,
    required this.templateId,
    this.ipAddress,
    required this.enableTwoFactor,
    required this.musicOnHold,
    required this.bNumber,
    required this.primaryNumber,
    this.eid,
    required this.isESim,
    this.subscriberContract,
  });

  factory DeviceLimitsModel.fromJson(Map<String, dynamic> json) {
    return DeviceLimitsModel(
      deviceType: json['DeviceType'] as String? ?? '',
      deviceId: json['DeviceID'] as int? ?? 0,
      iccid: json['ICCID'] as String? ?? '',
      imsi: json['IMSI'] as String? ?? '',
      serialNumber: json['SerialNumber'] as String? ?? '',
      model: json['Model'] as String? ?? '',
      tn: json['TN'] as String? ?? '',
      routingNumber: json['RoutingNumber'] as String?,
      parentAccountId: json['ParentAccountID'] as int? ?? 0,
      deviceStatus: json['DeviceStatus'] as String? ?? '',
      autoRenew: json['AutoRenew'] as bool? ?? false,
      overRideCoolOff: json['OverRideCoolOff'] as bool? ?? false,
      roamingLowBalanceThreshold:
          (json['RoamingLowBalanceThreshold'] as num?)?.toDouble() ?? 0.0,
      roamingTopUpAmount:
          (json['RoamingTopUpAmount'] as num?)?.toDouble() ?? 0.0,
      balanceThreshold: (json['BalanceThreshold'] as num?)?.toDouble() ?? 0.0,
      autoTopUpAmount: (json['AutoTopUpAmount'] as num?)?.toDouble() ?? 0.0,
      autoTopUp: json['AutoTopUp'] as String? ?? '',
      voiceMailEnabled: json['VoiceMailEnabled'] as bool? ?? false,
      defaultAllowedRoaming:
          (json['DefaultAllowedRoaming'] as num?)?.toDouble() ?? 0.0,
      defaultAllowedInternational:
          (json['DefaultAllowedInternational'] as num?)?.toDouble() ?? 0.0,
      defaultAllowedLocalVoice:
          (json['DefaultAllowedLocalVoice'] as num?)?.toDouble() ?? 0.0,
      defaultAllowedLocalData:
          (json['DefaultAllowedLocalData'] as num?)?.toDouble() ?? 0.0,
      defaultAllowedLocalText:
          (json['DefaultAllowedLocalText'] as num?)?.toDouble() ?? 0.0,
      maxAllowedRoaming:
          (json['MaxAllowedRoaming'] as num?)?.toDouble() ?? 0.0,
      maxAllowedInternational:
          (json['MaxAllowedInternational'] as num?)?.toDouble() ?? 0.0,
      maxAllowedLocalVoice:
          (json['MaxAllowedLocalVoice'] as num?)?.toDouble() ?? 0.0,
      maxAllowedLocalData:
          (json['MaxAllowedLocalData'] as num?)?.toDouble() ?? 0.0,
      maxAllowedLocalText:
          (json['MaxAllowedLocalText'] as num?)?.toDouble() ?? 0.0,
      canTransferMoney: json['CanTransferMoney'] as bool? ?? false,
      perTransTransferMoneyLimit:
          (json['PerTransTransferMoneyLimit'] as num?)?.toDouble() ?? 0.0,
      perDayTransferMoneyLimit:
          (json['PerDayTransferMoneyLimit'] as num?)?.toDouble() ?? 0.0,
      fName: json['FName'] as String?,
      lName: json['LName'] as String?,
      ocsVersion: json['OCSVersion'] as String? ?? '',
      ocsKey: json['OCSKey'] as String? ?? '',
      island: json['Island'] as String?,
      salesforceId: json['SalesforceID'] as String? ?? '',
      wholeSaleId: json['WholeSaleID'] as String? ?? '',
      templateId: json['TemplateID'] as String? ?? '',
      ipAddress: json['IPAddress'] as String?,
      enableTwoFactor: json['EnableTwoFactor'] as bool? ?? false,
      musicOnHold: json['MusicOnHold'] as String? ?? '',
      bNumber: json['BNumber'] as String? ?? '',
      primaryNumber: json['PrimaryNumber'] as String? ?? '',
      eid: json['EID'] as String?,
      isESim: json['IsESim'] as bool? ?? false,
      subscriberContract: json['SubscriberContract'] != null
          ? SubscriberContract.fromJson(
              json['SubscriberContract'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DeviceType': deviceType,
      'DeviceID': deviceId,
      'ICCID': iccid,
      'IMSI': imsi,
      'SerialNumber': serialNumber,
      'Model': model,
      'TN': tn,
      'RoutingNumber': routingNumber,
      'ParentAccountID': parentAccountId,
      'DeviceStatus': deviceStatus,
      'AutoRenew': autoRenew,
      'OverRideCoolOff': overRideCoolOff,
      'RoamingLowBalanceThreshold': roamingLowBalanceThreshold,
      'RoamingTopUpAmount': roamingTopUpAmount,
      'BalanceThreshold': balanceThreshold,
      'AutoTopUpAmount': autoTopUpAmount,
      'AutoTopUp': autoTopUp,
      'VoiceMailEnabled': voiceMailEnabled,
      'DefaultAllowedRoaming': defaultAllowedRoaming,
      'DefaultAllowedInternational': defaultAllowedInternational,
      'DefaultAllowedLocalVoice': defaultAllowedLocalVoice,
      'DefaultAllowedLocalData': defaultAllowedLocalData,
      'DefaultAllowedLocalText': defaultAllowedLocalText,
      'MaxAllowedRoaming': maxAllowedRoaming,
      'MaxAllowedInternational': maxAllowedInternational,
      'MaxAllowedLocalVoice': maxAllowedLocalVoice,
      'MaxAllowedLocalData': maxAllowedLocalData,
      'MaxAllowedLocalText': maxAllowedLocalText,
      'CanTransferMoney': canTransferMoney,
      'PerTransTransferMoneyLimit': perTransTransferMoneyLimit,
      'PerDayTransferMoneyLimit': perDayTransferMoneyLimit,
      'FName': fName,
      'LName': lName,
      'OCSVersion': ocsVersion,
      'OCSKey': ocsKey,
      'Island': island,
      'SalesforceID': salesforceId,
      'WholeSaleID': wholeSaleId,
      'TemplateID': templateId,
      'IPAddress': ipAddress,
      'EnableTwoFactor': enableTwoFactor,
      'MusicOnHold': musicOnHold,
      'BNumber': bNumber,
      'PrimaryNumber': primaryNumber,
      'EID': eid,
      'IsESim': isESim,
      'SubscriberContract': subscriberContract?.toJson(),
    };
  }

  // ============ Formatted getters for credit limit screen ============

  String get localTextFormatted => maxAllowedLocalText.toStringAsFixed(2);
  String get localDataFormatted => maxAllowedLocalData.toStringAsFixed(2);
  String get localVoiceFormatted => maxAllowedLocalVoice.toStringAsFixed(2);
  String get internationalFormatted =>
      maxAllowedInternational.toStringAsFixed(2);
  String get roamingFormatted => maxAllowedRoaming.toStringAsFixed(2);

  @override
  String toString() {
    return 'DeviceLimitsModel(deviceId: $deviceId, tn: $tn, '
        'maxLocalText: \$$localTextFormatted, '
        'maxLocalData: \$$localDataFormatted, '
        'maxLocalVoice: \$$localVoiceFormatted, '
        'maxInternational: \$$internationalFormatted, '
        'maxRoaming: \$$roamingFormatted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceLimitsModel && other.deviceId == deviceId;
  }

  @override
  int get hashCode => deviceId.hashCode;
}

/// Subscriber contract details
class SubscriberContract {
  final int deviceId;
  final String created;
  final String createdAgent;
  final String createdChannel;
  final String updated;
  final String updatedAgent;
  final String updatedChannel;
  final int contractId;
  final String contractStartDate;
  final int contractTerm;
  final double depositAmount;
  final String expectedEndDate;
  final String actualEndDate;

  const SubscriberContract({
    required this.deviceId,
    required this.created,
    required this.createdAgent,
    required this.createdChannel,
    required this.updated,
    required this.updatedAgent,
    required this.updatedChannel,
    required this.contractId,
    required this.contractStartDate,
    required this.contractTerm,
    required this.depositAmount,
    required this.expectedEndDate,
    required this.actualEndDate,
  });

  factory SubscriberContract.fromJson(Map<String, dynamic> json) {
    return SubscriberContract(
      deviceId: json['DeviceID'] as int? ?? 0,
      created: json['Created'] as String? ?? '',
      createdAgent: json['CreatedAgent'] as String? ?? '',
      createdChannel: json['CreatedChannel'] as String? ?? '',
      updated: json['Updated'] as String? ?? '',
      updatedAgent: json['UpdatedAgent'] as String? ?? '',
      updatedChannel: json['UpdatedChannel'] as String? ?? '',
      contractId: json['ContractID'] as int? ?? 0,
      contractStartDate: json['ContractStartDate'] as String? ?? '',
      contractTerm: json['ContractTerm'] as int? ?? 0,
      depositAmount: (json['DepositAmount'] as num?)?.toDouble() ?? 0.0,
      expectedEndDate: json['ExpectedEndDate'] as String? ?? '',
      actualEndDate: json['ActualEndDate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DeviceID': deviceId,
      'Created': created,
      'CreatedAgent': createdAgent,
      'CreatedChannel': createdChannel,
      'Updated': updated,
      'UpdatedAgent': updatedAgent,
      'UpdatedChannel': updatedChannel,
      'ContractID': contractId,
      'ContractStartDate': contractStartDate,
      'ContractTerm': contractTerm,
      'DepositAmount': depositAmount,
      'ExpectedEndDate': expectedEndDate,
      'ActualEndDate': actualEndDate,
    };
  }
}
