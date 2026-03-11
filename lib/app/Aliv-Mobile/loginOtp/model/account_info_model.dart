class AccountInfoModel {
  final String island;
  final double topUp24HourLimit;
  final double topUpPerTransLimit;
  final String dob;
  final String gender;
  final String altPhoneNumber;
  final IdentificationInfoModel identificationInfo;
  final String occupation;
  final int parentAccountId;
  final int idAcc;
  final String username;
  final String fName;
  final String lName;
  final String email;
  final String phoneNumber;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String postal;
  final String country;
  final String company;
  final String hierarchyType;
  final String invoiceType;
  final String paymentOption;
  final String vip;
  final double creditLimit;
  final String notificationOption;
  final bool autoRenew;
  final double depositAmount;
  final int corpId;
  final String accountStatus;
  final String accountType;
  final String taxId;
  final bool taxExempt;
  final bool userNameLocked;
  final List<String> tNs;
  final String password;
  final double allowRoaming;
  final double allowInternational;
  final String ocsVersion;
  final String ocsKey;
  final String invoiceDeliveryMethod;
  final String invoiceDeliveryRecipients;
  final String showUsageRecordsOnInvoice;
  final String salesforceId;
  final String primaryPhoneNumber;
  final String wholeSaleId;
  final bool autoPayInvoice;
  final String collectionsStatus;
  final String emaiVerificationStatus;
  final String reason;

  const AccountInfoModel({
    this.island = '',
    this.topUp24HourLimit = 0,
    this.topUpPerTransLimit = 0,
    this.dob = '',
    this.gender = '',
    this.altPhoneNumber = '',
    this.identificationInfo = const IdentificationInfoModel(),
    this.occupation = '',
    this.parentAccountId = 0,
    this.idAcc = 0,
    this.username = '',
    this.fName = '',
    this.lName = '',
    this.email = '',
    this.phoneNumber = '',
    this.address1 = '',
    this.address2 = '',
    this.city = '',
    this.state = '',
    this.postal = '',
    this.country = '',
    this.company = '',
    this.hierarchyType = '',
    this.invoiceType = '',
    this.paymentOption = '',
    this.vip = '',
    this.creditLimit = 0,
    this.notificationOption = '',
    this.autoRenew = false,
    this.depositAmount = 0,
    this.corpId = 0,
    this.accountStatus = '',
    this.accountType = '',
    this.taxId = '',
    this.taxExempt = false,
    this.userNameLocked = false,
    this.tNs = const <String>[],
    this.password = '',
    this.allowRoaming = 0,
    this.allowInternational = 0,
    this.ocsVersion = '',
    this.ocsKey = '',
    this.invoiceDeliveryMethod = '',
    this.invoiceDeliveryRecipients = '',
    this.showUsageRecordsOnInvoice = '',
    this.salesforceId = '',
    this.primaryPhoneNumber = '',
    this.wholeSaleId = '',
    this.autoPayInvoice = false,
    this.collectionsStatus = '',
    this.emaiVerificationStatus = '',
    this.reason = '',
  });

  factory AccountInfoModel.fromJson(Map<String, dynamic>? json) {
    final source = _normalizeMap(json);
    if (source.isEmpty) return const AccountInfoModel();

    return AccountInfoModel(
      island: _asString(_first(source, const ['Island'])),
      topUp24HourLimit: _asDouble(_first(source, const ['TopUp24HourLimit'])),
      topUpPerTransLimit: _asDouble(_first(source, const ['TopUpPerTransLimit'])),
      dob: _asString(_first(source, const ['DOB', 'Dob'])),
      gender: _asString(_first(source, const ['Gender'])),
      altPhoneNumber: _asString(_first(source, const ['AltPhoneNumber'])),
      identificationInfo: IdentificationInfoModel.fromJson(
        _asMap(_first(source, const ['IdentificationInfo'])),
      ),
      occupation: _asString(_first(source, const ['Occupation'])),
      parentAccountId: _asInt(_first(source, const ['ParentAccountID'])),
      idAcc: _asInt(_first(source, const ['id_acc', 'IdAcc'])),
      username: _asString(_first(source, const ['Username', 'UserName'])),
      fName: _asString(_first(source, const ['FName', 'FirstName'])),
      lName: _asString(_first(source, const ['LName', 'LastName'])),
      email: _asString(_first(source, const ['Email'])),
      phoneNumber: _asString(_first(source, const ['PhoneNumber'])),
      address1: _asString(_first(source, const ['Address1'])),
      address2: _asString(_first(source, const ['Address2'])),
      city: _asString(_first(source, const ['City'])),
      state: _asString(_first(source, const ['State'])),
      postal: _asString(_first(source, const ['Postal'])),
      country: _asString(_first(source, const ['Country'])),
      company: _asString(_first(source, const ['Company'])),
      hierarchyType: _asString(_first(source, const ['HierarchyType'])),
      invoiceType: _asString(_first(source, const ['InvoiceType'])),
      paymentOption: _asString(_first(source, const ['PaymentOption'])),
      vip: _asString(_first(source, const ['VIP'])),
      creditLimit: _asDouble(_first(source, const ['CreditLimit'])),
      notificationOption: _asString(_first(source, const ['NotificationOption'])),
      autoRenew: _asBool(_first(source, const ['AutoRenew'])),
      depositAmount: _asDouble(_first(source, const ['DepositAmount'])),
      corpId: _asInt(_first(source, const ['CorpID', 'CorpId'])),
      accountStatus: _asString(_first(source, const ['AccountStatus'])),
      accountType: _asString(_first(source, const ['AccountType'])),
      taxId: _asString(_first(source, const ['TaxID', 'TaxId'])),
      taxExempt: _asBool(_first(source, const ['TaxExempt'])),
      userNameLocked: _asBool(_first(source, const ['UserNameLocked'])),
      tNs: _asStringList(_first(source, const ['TNs', 'Tns'])),
      password: _asString(_first(source, const ['Password'])),
      allowRoaming: _asDouble(_first(source, const ['AllowRoaming'])),
      allowInternational: _asDouble(_first(source, const ['AllowInternational'])),
      ocsVersion: _asString(_first(source, const ['OCSVersion'])),
      ocsKey: _asString(_first(source, const ['OCSKey'])),
      invoiceDeliveryMethod: _asString(
        _first(source, const ['InvoiceDeliveryMethod']),
      ),
      invoiceDeliveryRecipients: _asString(
        _first(source, const ['InvoiceDeliveryRecipients']),
      ),
      showUsageRecordsOnInvoice: _asString(
        _first(source, const ['ShowUsageRecordsOnInvoice']),
      ),
      salesforceId: _asString(_first(source, const ['SalesforceID', 'SalesforceId'])),
      primaryPhoneNumber: _asString(_first(source, const ['PrimaryPhoneNumber'])),
      wholeSaleId: _asString(_first(source, const ['WholeSaleID', 'WholeSaleId'])),
      autoPayInvoice: _asBool(_first(source, const ['AutoPayInvoice'])),
      collectionsStatus: _asString(_first(source, const ['CollectionsStatus'])),
      emaiVerificationStatus: _asString(
        _first(source, const ['EmaiVerificationStatus', 'EmailVerificationStatus']),
      ),
      reason: _asString(_first(source, const ['Reason', 'Message', 'Error', 'Detail'])),
    );
  }

  /// Converts model back to JSON map so it can be cached locally.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'Island': island,
      'TopUp24HourLimit': topUp24HourLimit,
      'TopUpPerTransLimit': topUpPerTransLimit,
      'DOB': dob,
      'Gender': gender,
      'AltPhoneNumber': altPhoneNumber,
      'IdentificationInfo': identificationInfo.toJson(),
      'Occupation': occupation,
      'ParentAccountID': parentAccountId,
      'id_acc': idAcc,
      'Username': username,
      'FName': fName,
      'LName': lName,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'Address1': address1,
      'Address2': address2,
      'City': city,
      'State': state,
      'Postal': postal,
      'Country': country,
      'Company': company,
      'HierarchyType': hierarchyType,
      'InvoiceType': invoiceType,
      'PaymentOption': paymentOption,
      'VIP': vip,
      'CreditLimit': creditLimit,
      'NotificationOption': notificationOption,
      'AutoRenew': autoRenew,
      'DepositAmount': depositAmount,
      'CorpID': corpId,
      'AccountStatus': accountStatus,
      'AccountType': accountType,
      'TaxID': taxId,
      'TaxExempt': taxExempt,
      'UserNameLocked': userNameLocked,
      'TNs': tNs,
      'Password': password,
      'AllowRoaming': allowRoaming,
      'AllowInternational': allowInternational,
      'OCSVersion': ocsVersion,
      'OCSKey': ocsKey,
      'InvoiceDeliveryMethod': invoiceDeliveryMethod,
      'InvoiceDeliveryRecipients': invoiceDeliveryRecipients,
      'ShowUsageRecordsOnInvoice': showUsageRecordsOnInvoice,
      'SalesforceID': salesforceId,
      'PrimaryPhoneNumber': primaryPhoneNumber,
      'WholeSaleID': wholeSaleId,
      'AutoPayInvoice': autoPayInvoice,
      'CollectionsStatus': collectionsStatus,
      'EmaiVerificationStatus': emaiVerificationStatus,
      'Reason': reason,
    };
  }

  static AccountInfoModel fromDynamic(dynamic json) {
    if (json is Map<String, dynamic>) return AccountInfoModel.fromJson(json);
    if (json is Map) {
      final mapped = <String, dynamic>{};
      for (final entry in json.entries) {
        mapped[entry.key.toString()] = entry.value;
      }
      return AccountInfoModel.fromJson(mapped);
    }
    return const AccountInfoModel();
  }

  static Map<String, dynamic> _normalizeMap(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const <String, dynamic>{};
    final result = <String, dynamic>{};
    for (final entry in json.entries) {
      result[entry.key.toString()] = entry.value;
    }
    return result;
  }

  static dynamic _first(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      if (source.containsKey(key)) return source[key];
    }

    final lower = <String, dynamic>{};
    for (final entry in source.entries) {
      lower[entry.key.toLowerCase()] = entry.value;
    }
    for (final key in keys) {
      final value = lower[key.toLowerCase()];
      if (value != null) return value;
    }
    return null;
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    final text = value.toString().trim();
    return text;
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
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
    if (value is num) return value != 0;
    final normalized = value.toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  static List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item?.toString() ?? '').toList();
    }
    if (value == null) return const <String>[];
    final single = value.toString().trim();
    if (single.isEmpty) return const <String>[];
    return <String>[single];
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      final mapped = <String, dynamic>{};
      for (final entry in value.entries) {
        mapped[entry.key.toString()] = entry.value;
      }
      return mapped;
    }
    return null;
  }
}

class IdentificationInfoModel {
  final String niNumber;
  final String niExpirationDate;
  final String secondaryIdType;
  final String secondaryIdCountry;
  final String secondaryIdNumber;
  final String secondaryIdExpirationDate;

  const IdentificationInfoModel({
    this.niNumber = '',
    this.niExpirationDate = '',
    this.secondaryIdType = '',
    this.secondaryIdCountry = '',
    this.secondaryIdNumber = '',
    this.secondaryIdExpirationDate = '',
  });

  factory IdentificationInfoModel.fromJson(Map<String, dynamic>? json) {
    final source = AccountInfoModel._normalizeMap(json);
    if (source.isEmpty) return const IdentificationInfoModel();

    return IdentificationInfoModel(
      niNumber: AccountInfoModel._asString(
        AccountInfoModel._first(source, const ['NINumber']),
      ),
      niExpirationDate: AccountInfoModel._asString(
        AccountInfoModel._first(source, const ['NIExpirationDate']),
      ),
      secondaryIdType: AccountInfoModel._asString(
        AccountInfoModel._first(source, const ['SecondaryIDType']),
      ),
      secondaryIdCountry: AccountInfoModel._asString(
        AccountInfoModel._first(source, const ['SecondaryIDCountry']),
      ),
      secondaryIdNumber: AccountInfoModel._asString(
        AccountInfoModel._first(source, const ['SecondaryIDNumber']),
      ),
      secondaryIdExpirationDate: AccountInfoModel._asString(
        AccountInfoModel._first(source, const ['SecondaryIDExpirationDate']),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'NINumber': niNumber,
      'NIExpirationDate': niExpirationDate,
      'SecondaryIDType': secondaryIdType,
      'SecondaryIDCountry': secondaryIdCountry,
      'SecondaryIDNumber': secondaryIdNumber,
      'SecondaryIDExpirationDate': secondaryIdExpirationDate,
    };
  }
}
