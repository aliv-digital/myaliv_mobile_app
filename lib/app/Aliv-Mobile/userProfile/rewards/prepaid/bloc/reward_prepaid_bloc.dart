import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/reward_model.dart';
import '../repository/reward_prepaid_repository.dart';
import 'reward_prepaid_event.dart';
import 'reward_prepaid_state.dart';

class RewardPrepaidBloc extends Bloc<RewardPrepaidEvent, RewardPrepaidState> {
  final RewardPrepaidRepository rewardRepository;

  RewardPrepaidBloc(this.rewardRepository) : super(RewardPrepaidState.initial()) {
    on<FetchRewardPrepaidEvent>(_fetchRewards);

    on<GetThisTapped>(_onGetThisTapped);
    on<ReadMoreTapped>(_onReadMoreTapped);
    on<DealsLinkTapped>(_onDealsLinkTapped);
    on<ClearRewardPrepaidAction>(_onClearAction);
  }

  Future<void> _fetchRewards(
      FetchRewardPrepaidEvent event,
      Emitter<RewardPrepaidState> emit,
      ) async {
    emit(state.copyWith(status: RewardPrepaidStatus.loading, errorMessage: null, clearAction: true));
    try {
      final rewards = await rewardRepository.fetchRewards();
      emit(state.copyWith(status: RewardPrepaidStatus.success, rewards: rewards));
    } catch (e) {
      emit(state.copyWith(status: RewardPrepaidStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onGetThisTapped(GetThisTapped event, Emitter<RewardPrepaidState> emit) async {
    await _handleGetThisTap(event.reward, emit);
  }

  Future<void> _onReadMoreTapped(ReadMoreTapped event, Emitter<RewardPrepaidState> emit) async {
    await _handleReadMoreTap(event.reward, emit);
  }

  Future<void> _onDealsLinkTapped(DealsLinkTapped event, Emitter<RewardPrepaidState> emit) async {
    await _handleDealsLinkTap(emit);
  }

  void _onClearAction(ClearRewardPrepaidAction event, Emitter<RewardPrepaidState> emit) {
    emit(state.copyWith(clearAction: true));
  }

  // ---- Dedicated methods for future logic ----

  Future<void> _handleGetThisTap(RewardPrepaid reward, Emitter<RewardPrepaidState> emit) async {
    // future: API call, analytics, loading, etc.
    emit(state.copyWith(action: StartGetThisFlow(reward)));
  }

  Future<void> _handleReadMoreTap(RewardPrepaid reward, Emitter<RewardPrepaidState> emit) async {
    // future: open details page, fetch details, etc.
    emit(state.copyWith(action: OpenRewardDetails(reward)));
  }

  Future<void> _handleDealsLinkTap(Emitter<RewardPrepaidState> emit) async {
    // future: url launch / deeplink / analytics
    emit(state.copyWith(action: const NavigateToDeals()));
  }
}
