import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/refer_friend_response_prepaid_repository.dart';
import 'refer_friend_response_prepaid_event.dart';
import 'refer_friend_response_prepaid_state.dart';

class ReferFriendResponsePrepaidBloc
    extends Bloc<ReferFriendResponsePrepaidEvent, ReferFriendResponsePrepaidState> {
  final ReferFriendResponsePrepaidRepository repository;

  ReferFriendResponsePrepaidBloc({required this.repository})
      : super(const ReferFriendResponsePrepaidState()) {
    on<ReferFriendResponsePrepaidStarted>(_onStarted);
    on<ReferFriendResponsePrepaidCopyPressed>(_onCopy);
    on<ReferFriendResponsePrepaidToastConsumed>((e, emit) => emit(state.copyWith(toastMessage: null)));
    on<ReferFriendResponsePrepaidBackHomePressed>(_onBackHome);
  }

  Future<void> _onStarted(
      ReferFriendResponsePrepaidStarted event,
      Emitter<ReferFriendResponsePrepaidState> emit,
      ) async {
    final code = await repository.fetchReferralCode();
    emit(state.copyWith(referralCode: code));
  }

  void _onCopy(
      ReferFriendResponsePrepaidCopyPressed event,
      Emitter<ReferFriendResponsePrepaidState> emit,
      ) {
    emit(state.copyWith(toastMessage: 'Copied ${event.code}'));
  }

  void _onBackHome(
      ReferFriendResponsePrepaidBackHomePressed event,
      Emitter<ReferFriendResponsePrepaidState> emit,
      ) {
    // navigation screen-level e handle করবে (go_router)
  }
}
