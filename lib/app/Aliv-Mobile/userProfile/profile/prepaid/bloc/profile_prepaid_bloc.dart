import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/profile_prepaid_repository.dart';
import 'profile_prepaid_event.dart';
import 'profile_prepaid_state.dart';

class ProfilePrepaidBloc extends Bloc<ProfilePrepaidEvent, ProfilePrepaidState> {
  final ProfilePrepaidRepository repository;

  ProfilePrepaidBloc({required this.repository}) : super(ProfilePrepaidState.initial()) {
    on<ProfilePrepaidStarted>(_onStarted);
    on<ProfilePrepaidBackPressed>(_onBackPressed);
    on<ProfilePrepaidItemPressed>(_onItemPressed);
  }

  Future<void> _onStarted(
      ProfilePrepaidStarted event,
      Emitter<ProfilePrepaidState> emit,
      ) async {
    emit(state.copyWith(status: ProfilePrepaidStatus.loading));

    try {
      final items = await repository.fetchMenuItems();
      emit(state.copyWith(status: ProfilePrepaidStatus.ready, items: items));
    } catch (_) {
      emit(state.copyWith(status: ProfilePrepaidStatus.failure));
    }
  }

  void _onBackPressed(
      ProfilePrepaidBackPressed event,
      Emitter<ProfilePrepaidState> emit,
      ) {
    emit(state.copyWith(backRequestId: state.backRequestId + 1));
  }

  void _onItemPressed(
      ProfilePrepaidItemPressed event,
      Emitter<ProfilePrepaidState> emit,
      ) {
    if (!event.item.enabled) return;

    // route future e add korba, ekhon null thakle just ignore
    final route = event.item.route;
    if (route == null || route.isEmpty) return;

    emit(
      state.copyWith(
        openRouteRequestId: state.openRouteRequestId + 1,
        routeToOpen: route,
      ),
    );
  }
}
