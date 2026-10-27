import 'dart:convert';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/can_send_data_share_response.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/data_share_status.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class GiftDataApiException implements Exception {
  const GiftDataApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'GiftDataApiException($statusCode): $message';
}

/// Handles API calls for the gift-data flow. Uses the shared [NetworkService]
/// so Basic Auth headers are added automatically from `GlobalState`.
class GiftDataApiClient {
  GiftDataApiClient({NetworkService? networkService})
    : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  Future<CanSendDataShareResponse> fetchCanSendDataShare(
    String senderMsisdn,
  ) async {
    final digits = senderMsisdn.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      throw const GiftDataApiException(
        'Missing sender phone number',
        statusCode: 400,
      );
    }

    try {
      final response = await _networkService.request<dynamic>(
        Api.canSendDataShare(digits),
        method: HttpMethod.get,
      );

      final data = response.data;
      final Map<String, dynamic> json;
      if (data is Map<String, dynamic>) {
        json = data;
      } else if (data is String && data.isNotEmpty) {
        json = jsonDecode(data) as Map<String, dynamic>;
      } else {
        throw const GiftDataApiException(
          'Empty response from server',
          statusCode: 0,
        );
      }

      if (kDebugMode) {
        debugPrint(
          'GiftDataApiClient: can-send-data-share status=${response.statusCode} '
          'reason=${json['Reason']}',
        );
      }
      return CanSendDataShareResponse.fromJson(json);
    } on NetworkException catch (e) {
      throw GiftDataApiException(e.message, statusCode: e.statusCode);
    } catch (e) {
      if (e is GiftDataApiException) rethrow;
      throw GiftDataApiException(e.toString());
    }
  }

  Future<DataShareStatus> fetchDataShareStatus(int deviceAccountId) async {
    if (deviceAccountId <= 0) {
      throw const GiftDataApiException(
        'Missing device account id',
        statusCode: 400,
      );
    }

    try {
      final response = await _networkService.request<dynamic>(
        Api.dataShareStatus(deviceAccountId),
        method: HttpMethod.get,
      );

      final data = response.data;
      final Map<String, dynamic> json;
      if (data is Map<String, dynamic>) {
        json = data;
      } else if (data is String && data.isNotEmpty) {
        json = jsonDecode(data) as Map<String, dynamic>;
      } else {
        throw const GiftDataApiException(
          'Empty response from server',
          statusCode: 0,
        );
      }

      if (kDebugMode) {
        debugPrint(
          'GiftDataApiClient: data-share-status status=${response.statusCode} '
          'endDate=${json['DataShareEndDate']} sendLimit=${json['DataQtySendLimit']}',
        );
      }
      return DataShareStatus.fromJson(json);
    } on NetworkException catch (e) {
      throw GiftDataApiException(e.message, statusCode: e.statusCode);
    } catch (e) {
      if (e is GiftDataApiException) rethrow;
      throw GiftDataApiException(e.toString());
    }
  }

  /// Submits a gift-data transfer and returns the backend-issued `OrderId`.
  /// POST /Order/data-share
  /// Body: `{ "SenderNumber": "<digits>", "RecipientNumber": "<digits>", "PlanId": <int> }`.
  /// `PlanId` is taken from the chip the user selected
  /// (`AvailablePlans[].PlanID`).
  Future<int> submitDataShare({
    required String senderMsisdn,
    required String recipientMsisdn,
    required int planId,
  }) async {
    final senderDigits = senderMsisdn.replaceAll(RegExp(r'\D'), '');
    final recipientDigits = recipientMsisdn.replaceAll(RegExp(r'\D'), '');
    if (senderDigits.isEmpty) {
      throw const GiftDataApiException(
        'Missing sender phone number',
        statusCode: 400,
      );
    }
    if (recipientDigits.isEmpty) {
      throw const GiftDataApiException(
        'Missing recipient phone number',
        statusCode: 400,
      );
    }

    try {
      final response = await _networkService.request<dynamic>(
        Api.dataShareOrderUrl,
        method: HttpMethod.post,
        data: <String, dynamic>{
          'SenderNumber': senderDigits,
          'RecipientNumber': recipientDigits,
          'PlanId': planId,
        },
      );

      final data = response.data;
      final Map<String, dynamic> json;
      if (data is Map<String, dynamic>) {
        json = data;
      } else if (data is String && data.isNotEmpty) {
        json = jsonDecode(data) as Map<String, dynamic>;
      } else {
        throw const GiftDataApiException(
          'Empty response from server',
          statusCode: 0,
        );
      }

      final rawOrderId = json['OrderId'];
      final orderId = rawOrderId is int
          ? rawOrderId
          : (rawOrderId is num
                ? rawOrderId.toInt()
                : int.tryParse('$rawOrderId') ?? 0);

      if (kDebugMode) {
        debugPrint(
          'GiftDataApiClient: data-share status=${response.statusCode} orderId=$orderId',
        );
      }

      if (orderId <= 0) {
        throw const GiftDataApiException(
          'Invalid order id returned by server',
          statusCode: 0,
        );
      }

      return orderId;
    } on NetworkException catch (e) {
      throw GiftDataApiException(e.message, statusCode: e.statusCode);
    } catch (e) {
      if (e is GiftDataApiException) rethrow;
      throw GiftDataApiException(e.toString());
    }
  }
}
