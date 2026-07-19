class HomePlanAddOnModel {
  final String id;
  final String title; // e.g. liberty data 1
  final String label; // e.g. data balance
  final String value; // e.g. 1gb
  final double price; // base amount before VAT
  final double vatAmount;
  final String planTypeCode;

  const HomePlanAddOnModel({
    required this.id,
    required this.title,
    required this.label,
    required this.value,
    required this.price,
    required this.vatAmount,
    this.planTypeCode = 'S',
  });

  double get totalPrice => price + vatAmount;

  factory HomePlanAddOnModel.fromJson(Map<String, dynamic> json) {
    return HomePlanAddOnModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      vatAmount: (json['vatAmount'] as num?)?.toDouble() ?? 0.0,
      planTypeCode: json['planTypeCode'] as String? ?? 'S',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'label': label,
        'value': value,
        'price': price,
        'vatAmount': vatAmount,
        'planTypeCode': planTypeCode,
      };
}
