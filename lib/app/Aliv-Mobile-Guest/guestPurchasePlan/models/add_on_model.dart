class AddOnModel {
  final String id;
  final String title; // e.g. liberty data 1
  final String label; // e.g. data balance
  final String value; // e.g. 1gb
  final double
  price; // base amount before VAT (matches HomePlanAddOnModel.price)
  final double vatAmount;

  const AddOnModel({
    required this.id,
    required this.title,
    required this.label,
    required this.value,
    required this.price,
    this.vatAmount = 0,
  });
}
