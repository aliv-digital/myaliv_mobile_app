import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:myaliv_mobile_app/app/Home/best-plans/cubit/best_plan_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/cubit/best_plan_state.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/models/best_plan_model.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/repository/best_plan_repository.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/repository/best_plan_repository_exception.dart';

class MockBestPlanRepository extends Mock implements BestPlanRepository {}

BestPlanModel _plan({
  int id = 1,
  String type = 'prepaid',
  String status = 'active',
  DateTime? expireOn,
}) {
  final now = DateTime.now();
  return BestPlanModel(
    id: id,
    price: '25.00',
    planName: 'Test Plan $id',
    subHeading: 'Subtitle',
    startFrom: now.subtract(const Duration(days: 1)),
    expireOn: expireOn ?? now.add(const Duration(days: 30)),
    type: type,
    status: status,
  );
}

List<BestPlanModel> _prepaidPlans() => [
  _plan(id: 1, type: 'prepaid'),
  _plan(id: 2, type: 'prepaid'),
  _plan(id: 3, type: 'prepaid'),
];

void main() {
  late MockBestPlanRepository repository;

  setUp(() {
    repository = MockBestPlanRepository();
  });

  group('BestPlanCubit — initial state', () {
    test('starts with initial status and empty plans', () {
      final cubit = BestPlanCubit(repository);
      expect(cubit.state.status, BestPlanStatus.initial);
      expect(cubit.state.plans, isEmpty);
      expect(cubit.state.hasPlans, false);
      cubit.close();
    });
  });

  group('BestPlanCubit — loadPlans success', () {
    blocTest<BestPlanCubit, BestPlanState>(
      'emits [loading, loaded] when prepaid plans are returned',
      build: () {
        when(
          () => repository.fetchActivePlans(userType: 'prepaid'),
        ).thenAnswer((_) async => _prepaidPlans());
        return BestPlanCubit(repository);
      },
      act: (cubit) => cubit.loadPlans(userType: 'prepaid'),
      expect: () => [
        isA<BestPlanState>().having((s) => s.isLoading, 'isLoading', true),
        isA<BestPlanState>()
            .having((s) => s.isLoaded, 'isLoaded', true)
            .having((s) => s.planCount, 'planCount', 3)
            .having((s) => s.hasPlans, 'hasPlans', true),
      ],
    );

    blocTest<BestPlanCubit, BestPlanState>(
      'emits [loading, empty] when repository returns empty list',
      build: () {
        when(
          () => repository.fetchActivePlans(userType: 'prepaid'),
        ).thenAnswer((_) async => []);
        return BestPlanCubit(repository);
      },
      act: (cubit) => cubit.loadPlans(userType: 'prepaid'),
      expect: () => [
        isA<BestPlanState>().having((s) => s.isLoading, 'isLoading', true),
        isA<BestPlanState>().having((s) => s.isEmpty, 'isEmpty', true),
      ],
    );

    blocTest<BestPlanCubit, BestPlanState>(
      'passes userType to repository',
      build: () {
        when(
          () => repository.fetchActivePlans(userType: 'postpaid'),
        ).thenAnswer((_) async => [_plan(type: 'postpaid')]);
        return BestPlanCubit(repository);
      },
      act: (cubit) => cubit.loadPlans(userType: 'postpaid'),
      verify: (_) => verify(
        () => repository.fetchActivePlans(userType: 'postpaid'),
      ).called(1),
    );
  });

  group('BestPlanCubit — error paths', () {
    blocTest<BestPlanCubit, BestPlanState>(
      'emits [loading, failure] on network error',
      build: () {
        when(() => repository.fetchActivePlans(userType: 'prepaid')).thenThrow(
          const BestPlanRepositoryException(
            'Network error',
            type: BestPlanErrorType.network,
          ),
        );
        return BestPlanCubit(repository);
      },
      act: (cubit) => cubit.loadPlans(userType: 'prepaid'),
      expect: () => [
        isA<BestPlanState>().having((s) => s.isLoading, 'isLoading', true),
        isA<BestPlanState>()
            .having((s) => s.hasError, 'hasError', true)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('No internet'),
            ),
      ],
    );

    blocTest<BestPlanCubit, BestPlanState>(
      'emits [loading, failure] on timeout',
      build: () {
        when(() => repository.fetchActivePlans(userType: 'prepaid')).thenThrow(
          const BestPlanRepositoryException(
            'Timeout',
            type: BestPlanErrorType.timeout,
          ),
        );
        return BestPlanCubit(repository);
      },
      act: (cubit) => cubit.loadPlans(userType: 'prepaid'),
      expect: () => [
        isA<BestPlanState>().having((s) => s.isLoading, 'isLoading', true),
        isA<BestPlanState>()
            .having((s) => s.hasError, 'hasError', true)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('timed out'),
            ),
      ],
    );

    blocTest<BestPlanCubit, BestPlanState>(
      'emits [loading, failure] on unexpected exception',
      build: () {
        when(
          () => repository.fetchActivePlans(userType: 'prepaid'),
        ).thenThrow(Exception('Unexpected'));
        return BestPlanCubit(repository);
      },
      act: (cubit) => cubit.loadPlans(userType: 'prepaid'),
      expect: () => [
        isA<BestPlanState>().having((s) => s.isLoading, 'isLoading', true),
        isA<BestPlanState>()
            .having((s) => s.hasError, 'hasError', true)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Failed to load plans',
            ),
      ],
    );
  });

  group('BestPlanCubit — cache guard', () {
    blocTest<BestPlanCubit, BestPlanState>(
      'second call within 5-min TTL skips fetch',
      build: () {
        when(
          () => repository.fetchActivePlans(userType: 'prepaid'),
        ).thenAnswer((_) async => _prepaidPlans());
        return BestPlanCubit(repository);
      },
      act: (cubit) async {
        await cubit.loadPlans(userType: 'prepaid');
        await cubit.loadPlans(userType: 'prepaid');
      },
      verify: (_) => verify(
        () => repository.fetchActivePlans(userType: 'prepaid'),
      ).called(1),
    );

    blocTest<BestPlanCubit, BestPlanState>(
      'forceRefresh: true bypasses valid cache',
      build: () {
        when(
          () => repository.fetchActivePlans(userType: 'prepaid'),
        ).thenAnswer((_) async => _prepaidPlans());
        return BestPlanCubit(repository);
      },
      act: (cubit) async {
        await cubit.loadPlans(userType: 'prepaid');
        await cubit.loadPlans(userType: 'prepaid', forceRefresh: true);
      },
      verify: (_) => verify(
        () => repository.fetchActivePlans(userType: 'prepaid'),
      ).called(2),
    );
  });

  group('BestPlanCubit — duplicate load prevention', () {
    blocTest<BestPlanCubit, BestPlanState>(
      'second loadPlans while loading is ignored',
      build: () {
        when(() => repository.fetchActivePlans(userType: 'prepaid')).thenAnswer(
          (_) async {
            await Future.delayed(const Duration(milliseconds: 50));
            return _prepaidPlans();
          },
        );
        return BestPlanCubit(repository);
      },
      act: (cubit) async {
        final first = cubit.loadPlans(userType: 'prepaid');
        final second = cubit.loadPlans(userType: 'prepaid');
        await Future.wait([first, second]);
      },
      verify: (_) => verify(
        () => repository.fetchActivePlans(userType: 'prepaid'),
      ).called(1),
    );
  });

  group('BestPlanCubit — reset', () {
    blocTest<BestPlanCubit, BestPlanState>(
      'reset returns to initial state',
      build: () {
        when(
          () => repository.fetchActivePlans(userType: 'prepaid'),
        ).thenAnswer((_) async => _prepaidPlans());
        return BestPlanCubit(repository);
      },
      act: (cubit) async {
        await cubit.loadPlans(userType: 'prepaid');
        cubit.reset();
      },
      expect: () => [
        isA<BestPlanState>().having((s) => s.isLoading, 'isLoading', true),
        isA<BestPlanState>().having((s) => s.isLoaded, 'isLoaded', true),
        isA<BestPlanState>().having(
          (s) => s.status,
          'status',
          BestPlanStatus.initial,
        ),
      ],
    );
  });
}
