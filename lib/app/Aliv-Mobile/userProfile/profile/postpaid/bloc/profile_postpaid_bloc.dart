import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/profile_postpaid_repository.dart';
import 'profile_postpaid_event.dart';
import 'profile_postpaid_state.dart';

class ProfilePostpaidBloc extends Bloc<ProfilePostpaidEvent, ProfilePostpaidState> {
  final ProfilePostpaidRepository repository;

  ProfilePostpaidBloc({required this.repository}) : super(ProfilePostpaidState.initial()) {
    on<ProfilePostpaidStarted>(_onStarted);
    on<ProfilePostpaidBackPressed>(_onBackPressed);
    on<ProfilePostpaidItemPressed>(_onItemPressed);
  }

  Future<void> _onStarted(
      ProfilePostpaidStarted event,
      Emitter<ProfilePostpaidState> emit,
      ) async {
    emit(state.copyWith(status: ProfilePostpaidStatus.loading));

    try {
      final items = await repository.fetchMenuItems();
      emit(state.copyWith(status: ProfilePostpaidStatus.ready, items: items));
    } catch (_) {
      emit(state.copyWith(status: ProfilePostpaidStatus.failure));
    }
  }

  void _onBackPressed(
      ProfilePostpaidBackPressed event,
      Emitter<ProfilePostpaidState> emit,
      ) {
    emit(state.copyWith(backRequestId: state.backRequestId + 1));
  }

  void _onItemPressed(
      ProfilePostpaidItemPressed event,
      Emitter<ProfilePostpaidState> emit,
      ) {
    if (!event.item.enabled) return;

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
