import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/change_bundle_result.dart';

void main() {
  group('CardPaymentService', () {
    test(
      'maps ToManyOrders from a 5xx payload to the pending-orders copy',
      () async {
        final service = CardPaymentService(
          networkService: _ThrowingNetworkService(
            ServerException(
              'API serving error',
              statusCode: 500,
              data: const <String, dynamic>{'ErrorCodeName': 'ToManyOrders'},
            ),
          ),
        );

        final result = await service.send(url: '/top-up', body: const {});

        expect(result, isA<ChangeBundleFailure>());
        expect(
          (result as ChangeBundleFailure).message,
          CardPaymentService.pendingOrdersMessage,
        );
      },
    );

    test(
      'accepts the corrected TooManyOrders spelling in a JSON payload',
      () async {
        final service = CardPaymentService(
          networkService: _ThrowingNetworkService(
            NetworkException(
              'API serving error',
              statusCode: 400,
              data: '{"errorCodeName":"TooManyOrders"}',
            ),
          ),
        );

        final result = await service.send(url: '/top-up', body: const {});

        expect(result, isA<ChangeBundleFailure>());
        expect(
          (result as ChangeBundleFailure).message,
          CardPaymentService.pendingOrdersMessage,
        );
      },
    );
  });
}

class _ThrowingNetworkService extends NetworkService {
  _ThrowingNetworkService(this.error);

  final NetworkException error;

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
  }) {
    return Future<Response<T>>.error(error);
  }
}
