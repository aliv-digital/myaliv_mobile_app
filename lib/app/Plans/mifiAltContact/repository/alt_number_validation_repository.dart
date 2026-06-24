import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import 'services/alt_number_validation_api_client.dart';

class AltNumberValidationRepository {
  AltNumberValidationRepository({AltNumberValidationApiClient? apiClient})
      : _apiClient = apiClient ?? AltNumberValidationApiClient();

  final AltNumberValidationApiClient _apiClient;

  /// Returns the server's `IsValid` flag.
  ///
  /// Throws [AltNumberValidationException] on transport / parse errors so the
  /// caller can surface a user-facing message.
  Future<bool> validate(String altNumber) async {
    final trimmed = altNumber.trim();
    if (trimmed.isEmpty) {
      throw const AltNumberValidationException(
        'please enter a mobile number.',
      );
    }

    try {
      return await _apiClient.validate(trimmed);
    } on NetworkException catch (e) {
      if (kDebugMode) {
        debugPrint(
          'AltNumberValidationRepository.validate: ${e.statusCode} ${e.message}',
        );
      }
      throw AltNumberValidationException(_validateErrorMessage(e));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AltNumberValidationRepository.validate: error $e');
      }
      throw const AltNumberValidationException(
        'could not verify the mobile number. please try again.',
      );
    }
  }

  /// Persists the alt number on the account. Returns the server's `Success`.
  ///
  /// Throws [AltNumberValidationException] on transport / parse errors.
  Future<bool> updateAltNumber(String altNumber) async {
    final trimmed = altNumber.trim();
    if (trimmed.isEmpty) {
      throw const AltNumberValidationException(
        'please enter a mobile number.',
      );
    }

    try {
      return await _apiClient.updateAltNumber(trimmed);
    } on NetworkException catch (e) {
      if (kDebugMode) {
        debugPrint(
          'AltNumberValidationRepository.update: ${e.statusCode} ${e.message}',
        );
      }
      throw AltNumberValidationException(_updateErrorMessage(e));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AltNumberValidationRepository.update: error $e');
      }
      throw const AltNumberValidationException(
        'could not save the mobile number. please try again.',
      );
    }
  }

  String _validateErrorMessage(NetworkException e) {
    final code = e.statusCode;
    if (code == 401) return 'session expired. please log in again.';
    if (code == 400 || code == 404) return 'this mobile number is not valid.';
    if (code != null && code >= 500) {
      return 'service unavailable. please try again.';
    }
    final msg = e.message.trim();
    if (msg.isNotEmpty && msg.toLowerCase() != 'an error occurred') {
      return msg;
    }
    return 'could not verify the mobile number. please try again.';
  }

  String _updateErrorMessage(NetworkException e) {
    final code = e.statusCode;
    if (code == 401) return 'session expired. please log in again.';
    if (code != null && code >= 500) {
      return 'service unavailable. please try again.';
    }
    final msg = e.message.trim();
    if (msg.isNotEmpty && msg.toLowerCase() != 'an error occurred') {
      return msg;
    }
    return 'could not save the mobile number. please try again.';
  }
}

class AltNumberValidationException implements Exception {
  final String message;

  const AltNumberValidationException(this.message);

  @override
  String toString() => message;
}
