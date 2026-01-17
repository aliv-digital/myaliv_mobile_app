import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/reward_details_prepaid_repository.dart';
import 'reward_details_prepaid_event.dart';
import 'reward_details_prepaid_state.dart';

class RewardDetailsPrepaidBloc
    extends Bloc<RewardDetailsPrepaidEvent, RewardDetailsPrepaidState> {
  final RewardDetailsPrepaidRepository repository;

  RewardDetailsPrepaidBloc({required this.repository})
      : super(RewardDetailsPrepaidState.initial()) {
    on<FetchRewardDetailsPrepaid>(_onFetch);
  }

  Future<void> _onFetch(
      FetchRewardDetailsPrepaid event,
      Emitter<RewardDetailsPrepaidState> emit,
      ) async {
    emit(state.copyWith(
      status: RewardDetailsPrepaidStatus.loading,
      clearError: true,
    ));

    try {
      final details = await repository.fetchDetails();
      emit(state.copyWith(
        status: RewardDetailsPrepaidStatus.success,
        details: details,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RewardDetailsPrepaidStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
