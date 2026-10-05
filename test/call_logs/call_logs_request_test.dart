import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/call_log_tab.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/call_logs_cubit.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/call_logs_state.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/repository/call_logs_repository.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/repository/services/call_logs_api_client.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/widgets/call_log_tile.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class _MockNetworkService extends Mock implements NetworkService {}

class _MockDeviceLimitsCubit extends Mock implements DeviceLimitsCubit {}

Map<String, dynamic> _record(String date) => {
  'Date': date,
  'UsageType': 'Voice',
  'CallType': 'Voice',
  'NumberDialed': '5550100',
  'CallingParty': '5550101',
  'Duration': '00:01:00',
  'Amount': 1.5,
  'Tax': 0.15,
  'ServiceFlow': 'Outgoing',
  'RateMeasure': 'Minute',
  'ActualUsage': '60',
  'RatedUsage': '1',
  'Wallet': 'Main',
  'CallDesc': 'Voice call',
  'Bytes': '',
};

void main() {
  late _MockNetworkService network;
  late _MockDeviceLimitsCubit devices;
  late CallLogsApiClient client;
  late CallLogsCubit cubit;

  void setDevice(int? id) {
    when(() => devices.state).thenReturn(
      DeviceLimitsState(
        status: DeviceLimitsStatus.loaded,
        allDeviceLimits: [
          if (id != null) DeviceLimitsModel.fromJson({'DeviceID': id}),
        ],
      ),
    );
  }

  void respond(String body) {
    when(
      () => network.request<String>(any(), method: HttpMethod.get),
    ).thenAnswer(
      (_) async => Response<String>(
        requestOptions: RequestOptions(path: Api.usages),
        statusCode: 200,
        data: body,
      ),
    );
  }

  String requestedUrl() =>
      verify(
            () => network.request<String>(captureAny(), method: HttpMethod.get),
          ).captured.single
          as String;

  setUp(() {
    network = _MockNetworkService();
    devices = _MockDeviceLimitsCubit();
    client = CallLogsApiClient(networkService: network);
    cubit = CallLogsCubit(
      repository: CallLogsRepository(apiClient: client),
      deviceLimitsCubit: devices,
    );
    setDevice(1540278210);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('sends the exact Postman query and removes fractional seconds', () async {
    respond('[]');

    await client.fetchUsages(
      deviceAccountId: 1540278210,
      startDate: DateTime(2026, 9, 1, 0, 0, 0, 123),
      endDate: DateTime(2026, 9, 30, 0, 0, 0, 456),
    );

    expect(
      requestedUrl(),
      '${Api.usages}?AccountId=1540278210&startDate=2026-09-01T00:00:00&endDate=2026-09-30T00:00:00',
    );
    verifyNoMoreInteractions(network);
  });

  test(
    'passes the device ID through the full flow and keeps month bounds',
    () async {
      respond(
        jsonEncode([
          _record('2026-09-02T09:00:00'),
          _record('2026-09-03T10:00:00'),
        ]),
      );
      final states = <CallLogsState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);

      await cubit.selectMonth(DateTime(2026, 9, 15));
      await Future<void>.delayed(Duration.zero);

      expect(Uri.parse(requestedUrl()).queryParameters, {
        'AccountId': '1540278210',
        'startDate': '2026-09-01T00:00:00',
        'endDate': '2026-09-30T23:59:59',
      });
      expect(states.map((state) => state.status), [
        CallLogsStatus.initial,
        CallLogsStatus.loading,
        CallLogsStatus.success,
      ]);
      expect(cubit.state.hasData, isTrue);
      expect(cubit.state.usages.map((usage) => usage.date), [
        DateTime(2026, 9, 3, 10),
        DateTime(2026, 9, 2, 9),
      ]);
      expect(
        cubit.state.usages.first.toJson(),
        _record('2026-09-03T10:00:00')..['Date'] = '2026-09-03T10:00:00.000',
      );
    },
  );

  for (final id in <int?>[null, 0, -1]) {
    test('unavailable device ID ($id) fails without a request', () async {
      setDevice(id);

      await cubit.fetchUsages();

      expect(cubit.state.status, CallLogsStatus.failure);
      expect(
        cubit.state.errorMessage,
        'Device account ID unavailable. Please try again.',
      );
      verifyZeroInteractions(network);
    });
  }

  for (final id in [0, -1]) {
    test('API client also prevents an invalid AccountId ($id)', () async {
      await expectLater(
        client.fetchUsages(
          deviceAccountId: id,
          startDate: DateTime(2026, 9),
          endDate: DateTime(2026, 9, 30),
        ),
        throwsA(isA<Exception>()),
      );
      verifyZeroInteractions(network);
    });
  }

  test(
    'retry reads the current device state rather than caching the ID',
    () async {
      setDevice(null);
      await cubit.fetchUsages();
      expect(cubit.state.status, CallLogsStatus.failure);

      setDevice(42);
      respond('[]');
      await cubit.fetchUsages();

      expect(Uri.parse(requestedUrl()).queryParameters['AccountId'], '42');
      expect(cubit.state.status, CallLogsStatus.success);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.usages, isEmpty);
    },
  );

  test('API failure uses the existing Call Log error state', () async {
    when(
      () => network.request<String>(any(), method: HttpMethod.get),
    ).thenThrow(NetworkException('Unable to load usages', statusCode: 400));

    await cubit.fetchUsages();

    expect(cubit.state.status, CallLogsStatus.failure);
    expect(cubit.state.errorMessage, 'Unable to load usages');
  });

  testWidgets('parsed response records appear in the existing Call Logs tab', (
    tester,
  ) async {
    respond(jsonEncode([_record('2026-09-03T10:00:00')]));
    await cubit.selectMonth(DateTime(2026, 9));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: cubit, child: const CallLogsTab()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CallLogTile), findsOneWidget);
    expect(find.text('5550100'), findsOneWidget);
    expect(find.text('outgoing call, 00:01:00'), findsOneWidget);
    expect(find.text('September 03, 2026'), findsOneWidget);
  });

  testWidgets('empty response shows the existing empty state', (tester) async {
    respond('[]');
    await cubit.fetchUsages();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: cubit, child: const CallLogsTab()),
      ),
    );

    expect(find.text('No call logs found for this month'), findsOneWidget);
  });

  testWidgets('missing device ID displays the error and Retry', (tester) async {
    setDevice(null);
    await cubit.fetchUsages();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: cubit, child: const CallLogsTab()),
      ),
    );

    expect(
      find.text('Device account ID unavailable. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    verifyZeroInteractions(network);
  });
}
