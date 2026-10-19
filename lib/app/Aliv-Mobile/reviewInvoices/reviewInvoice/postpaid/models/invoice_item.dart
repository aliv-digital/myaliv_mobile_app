/// Model representing an invoice item from the API.
///
/// Maps to API response from: GET v1/MyAliv/Account/invoices
class InvoiceItem {
  final int invoiceId;
  final int accountId;
  final String invoiceNo;
  final String invoicePath;
  final double amount;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final List<String> files;
  final String currencySymbol;

  const InvoiceItem({
    required this.invoiceId,
    required this.accountId,
    required this.invoiceNo,
    required this.invoicePath,
    required this.amount,
    required this.invoiceDate,
    required this.dueDate,
    this.files = const [],
    this.currencySymbol = r'$',
  });

  /// Creates an InvoiceItem from API JSON response.
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "InvoiceID": 61916,
  ///   "id_acc": 231856117,
  ///   "InvoiceString": "000072134",
  ///   "InvoicePath": "1332412449\\231856117\\invoice.pdf",
  ///   "InvoiceAmount": 65.99,
  ///   "InvoiceDate": "2025-09-01 04:00:00",
  ///   "InvoiceDueDate": "2025-09-15 04:00:00",
  ///   "Files": ["\\newcofiler0\\reports\\...\\InvoicePage.pdf"]
  /// }
  /// ```
  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      invoiceId: json['InvoiceID'] as int? ?? 0,
      accountId: json['id_acc'] as int? ?? 0,
      invoiceNo: json['InvoiceString'] as String? ?? '',
      invoicePath: json['InvoicePath'] as String? ?? '',
      amount: _parseAmount(json['InvoiceAmount']),
      invoiceDate: _parseDate(json['InvoiceDate']),
      dueDate: _parseDate(json['InvoiceDueDate']),
      files: _parseFiles(json['Files']),
    );
  }

  /// Parses amount from API (handles double, int, or String).
  static double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Parses date from API format "YYYY-MM-DD HH:mm:ss".
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      // Handle format: "2025-09-01 04:00:00"
      return DateTime.tryParse(value.replaceFirst(' ', 'T')) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Parses files list from API.
  static List<String> _parseFiles(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Returns the first file path if available, null otherwise.
  String? get primaryFilePath => files.isNotEmpty ? files.first : null;

  /// Returns true if this invoice has downloadable files.
  bool get hasFiles => files.isNotEmpty;
}
