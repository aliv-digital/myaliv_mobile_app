import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/balance/models/balance_model.dart';
import 'package:myaliv_mobile_app/app/Home/balance/repository/balance_repository.dart';

void main() {
  group('BalanceCubit authenticated device account ID', () {
    test('uses the AccountId supplied by the authentication context', () async {
      final repository = _RecordingBalanceRepository();
      final cubit = BalanceCubit(
        repository,
        deviceAccountIdProvider: () => '1259947673',
      );
      addTearDown(cubit.close);

      await cubit.loadBalances();

      expect(repository.requestedDeviceAccountIds, [1259947673]);
      expect(cubit.state.status, BalanceStatus.loaded);
      expect(cubit.state.walletBalance, 181.87);
    });

    test(
      'does not request balances without a valid authenticated ID',
      () async {
        final repository = _RecordingBalanceRepository();
        final cubit = BalanceCubit(
          repository,
          deviceAccountIdProvider: () => null,
        );
        addTearDown(cubit.close);

        await cubit.loadBalances();

        expect(repository.requestedDeviceAccountIds, isEmpty);
        expect(cubit.state.status, BalanceStatus.failure);
        expect(
          cubit.state.errorMessage,
          'Unable to identify the authenticated account.',
        );
      },
    );

    test(
      'does not reuse cached balances after the authenticated ID changes',
      () async {
        var authenticatedId = '1259947673';
        final repository = _RecordingBalanceRepository();
        final cubit = BalanceCubit(
          repository,
          deviceAccountIdProvider: () => authenticatedId,
        );
        addTearDown(cubit.close);

        await cubit.loadBalances();
        authenticatedId = '856707518';
        await cubit.loadBalances();

        expect(repository.requestedDeviceAccountIds, [1259947673, 856707518]);
      },
    );
  });
}

class _RecordingBalanceRepository implements BalanceRepository {
  final List<int> requestedDeviceAccountIds = [];

  @override
  Future<BalanceModel> fetchBalances({required int deviceAccountId}) async {
    requestedDeviceAccountIds.add(deviceAccountId);
    return BalanceModel(
      walletBalance: 181.87,
      bonusBalance: 0,
      bonusDetails: const [],
      fetchedAt: DateTime.now(),
    );
  }
}
