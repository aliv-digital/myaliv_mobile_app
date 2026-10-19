/// Request model for updating device credit limits
///
/// Used with PUT /v1/MyAliv/device/{deviceAccountId}/limits
class UpdateLimitsRequest {
  final double maxAllowedInternational;
  final double maxAllowedRoaming;
  final double maxAllowedLocalVoice;
  final double maxAllowedLocalData;
  final double maxAllowedLocalText;

  const UpdateLimitsRequest({
    required this.maxAllowedInternational,
    required this.maxAllowedRoaming,
    required this.maxAllowedLocalVoice,
    required this.maxAllowedLocalData,
    required this.maxAllowedLocalText,
  });

  /// Create from text field values (parsed from string)
  factory UpdateLimitsRequest.fromFormValues({
    required String localText,
    required String localData,
    required String localVoice,
    required String international,
    required String roaming,
  }) {
    return UpdateLimitsRequest(
      maxAllowedLocalText: double.tryParse(localText) ?? 0.0,
      maxAllowedLocalData: double.tryParse(localData) ?? 0.0,
      maxAllowedLocalVoice: double.tryParse(localVoice) ?? 0.0,
      maxAllowedInternational: double.tryParse(international) ?? 0.0,
      maxAllowedRoaming: double.tryParse(roaming) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MaxAllowedInternational': maxAllowedInternational,
      'MaxAllowedRoaming': maxAllowedRoaming,
      'MaxAllowedLocalVoice': maxAllowedLocalVoice,
      'MaxAllowedLocalData': maxAllowedLocalData,
      'MaxAllowedLocalText': maxAllowedLocalText,
    };
  }

  @override
  String toString() {
    return 'UpdateLimitsRequest('
        'localText: $maxAllowedLocalText, '
        'localData: $maxAllowedLocalData, '
        'localVoice: $maxAllowedLocalVoice, '
        'international: $maxAllowedInternational, '
        'roaming: $maxAllowedRoaming)';
  }
}
