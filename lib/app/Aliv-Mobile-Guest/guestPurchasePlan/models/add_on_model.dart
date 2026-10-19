class AddOnModel {
  final String id;
  final String title; // e.g. liberty data 1
  final String label; // e.g. data balance
  final String value; // e.g. 1gb
  final double price; // e.g. 5.00

  const AddOnModel({
    required this.id,
    required this.title,
    required this.label,
    required this.value,
    required this.price,
  });
}
