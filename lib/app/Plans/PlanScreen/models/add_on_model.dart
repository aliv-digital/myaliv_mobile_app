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
}
