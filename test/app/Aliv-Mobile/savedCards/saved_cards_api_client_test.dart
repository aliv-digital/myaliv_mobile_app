import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/repository/saved_cards_exception.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/repository/services/saved_cards_api_client.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

void main() {
  const details = NewCardDetails(
    cardNumber: '4111111111111111',
    cardExpiration: '2030-12',
    cardSecurityCode: '456',
    cardHolderName: 'Demo Visa User',
  );

  test('addCreditCard sends exact API payload and returns map token', () async {
    final network = _RecordingNetworkService(
      responseData: <String, dynamic>{'Token': 'card-token'},
    );
    final client = SavedCardsApiClient(networkService: network);

    final token = await client.addCreditCard(details);

    expect(token, 'card-token');
    expect(network.path, Api.addCreditCard);
    expect(network.method, HttpMethod.post);
    expect(network.data, <String, dynamic>{
      'Number': '4111111111111111',
      'Name': 'Demo Visa User',
      'ExpirationMonth': 12,
      'ExpirationYear': 2030,
      'SecurityCode': '456',
    });
    final redactedFields =
        network.options?.extra?[networkLogRedactedFieldsExtraKey] as List;
    expect(redactedFields,
        containsAll(<String>['Number', 'Name', 'SecurityCode', 'Token']));
  });

  test('addCreditCard parses token from a JSON string response', () async {
    final network = _RecordingNetworkService(
      responseData: '{"Token":"string-token"}',
    );
    final client = SavedCardsApiClient(networkService: network);

    expect(await client.addCreditCard(details), 'string-token');
  });

  test('addCreditCard rejects a response without a token', () async {
    final network = _RecordingNetworkService(
      responseData: <String, dynamic>{'Success': true},
    );
    final client = SavedCardsApiClient(networkService: network);

    await expectLater(
      client.addCreditCard(details),
      throwsA(
        isA<SavedCardsException>().having(
          (error) => error.type,
          'type',
          SavedCardsErrorType.invalidResponse,
        ),
      ),
    );
  });

  test('addCreditCard maps network failures', () async {
    final network = _RecordingNetworkService(error: TimeoutException());
    final client = SavedCardsApiClient(networkService: network);

    await expectLater(
      client.addCreditCard(details),
      throwsA(
        isA<SavedCardsException>().having(
          (error) => error.type,
          'type',
          SavedCardsErrorType.timeout,
        ),
      ),
    );
  });
}

class _RecordingNetworkService extends NetworkService {
  _RecordingNetworkService({this.responseData, this.error});

  final dynamic responseData;
  final Object? error;

  String? path;
  HttpMethod? method;
  dynamic data;
  Options? options;

  @override
  Future<Response<T>> request<T>(
    String path, {
    required HttpMethod method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    String? requestId,
  }) async {
    this.path = path;
    this.method = method;
    this.data = data;
    this.options = options;

    if (error != null) throw error!;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: responseData as T?,
      statusCode: 200,
    );
  }
}
