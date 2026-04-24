import 'package:equatable/equatable.dart';

/// Model representing a saved credit card.
///
/// API response format:
/// ```json
/// {
///   "Token": "f304acbe-54e6-4c7e-8e5a-7bf9b49efa11",
///   "Number": "*3686"
/// }
/// ```
class SavedCardModel extends Equatable {
  final String token;
  final String number;

  const SavedCardModel({
    required this.token,
    required this.number,
  });

  factory SavedCardModel.fromJson(Map<String, dynamic> json) {
    return SavedCardModel(
      token: json['Token'] as String? ?? '',
      number: json['Number'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Token': token,
      'Number': number,
    };
  }

  /// Display label for dropdown: "card ending in 3686"
  String get displayLabel {
    final lastDigits = number.replaceAll('*', '').trim();
    return 'card ending in $lastDigits';
  }

  /// Returns just the last digits without the asterisk
  String get lastDigits => number.replaceAll('*', '').trim();

  @override
  List<Object?> get props => [token, number];
}
