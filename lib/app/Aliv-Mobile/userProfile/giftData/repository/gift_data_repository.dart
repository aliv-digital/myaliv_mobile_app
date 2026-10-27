import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/data_share_status.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/gift_data_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/repository/services/gift_data_api_client.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/repository/services/gift_data_parser_service.dart';

/// Shape returned by [GiftDataRepository.fetchSendDataShareOptions].
/// Carries the full catalog and any sender-eligibility flag. The sender's
/// giftable budget comes from the separate `data-share-status` endpoint
/// (`AvailableToShow`), not from summing this catalog.
class GiftDataSendOptions {
  const GiftDataSendOptions({
    required this.isSenderEligible,
    required this.options,
    required this.reason,
  });

  final bool isSenderEligible;
  final List<GiftAmountOption> options;
  final String reason;
}

class GiftDataRepository {
  GiftDataRepository({
    required GiftDataApiClient apiClient,
    required GiftDataParserService parserService,
  }) : _apiClient = apiClient,
       _parserService = parserService;

  final GiftDataApiClient _apiClient;
  final GiftDataParserService _parserService;

  /// Fetches the available gift plans + total giftable budget for a sender.
  /// Backed by GET /device/can-send-data-share/{senderMsisdn}.
  Future<GiftDataSendOptions> fetchSendDataShareOptions(
    String senderMsisdn,
  ) async {
    final response = await _apiClient.fetchCanSendDataShare(senderMsisdn);
    return GiftDataSendOptions(
      isSenderEligible: response.isSenderEligible,
      options: _parserService.parseOptions(response),
      reason: response.reason,
    );
  }

  /// Sender's data-share quota and window.
  /// Backed by GET /device/{deviceAccountId}/data-share-status.
  Future<DataShareStatus> fetchDataShareStatus(int deviceAccountId) {
    return _apiClient.fetchDataShareStatus(deviceAccountId);
  }

  /// Submits the gift-data transfer. Returns the backend-issued OrderId.
  /// Backed by POST /Order/data-share.
  Future<int> submitGift({
    required String senderMsisdn,
    required String recipientMsisdn,
    required int planId,
  }) {
    return _apiClient.submitDataShare(
      senderMsisdn: senderMsisdn,
      recipientMsisdn: recipientMsisdn,
      planId: planId,
    );
  }
}
