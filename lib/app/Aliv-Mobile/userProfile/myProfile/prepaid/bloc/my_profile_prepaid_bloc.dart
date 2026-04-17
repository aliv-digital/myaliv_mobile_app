import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';

import '../repository/my_profile_prepaid_repository.dart';
import 'my_profile_prepaid_event.dart';
import 'my_profile_prepaid_state.dart';

class MyProfilePrepaidBloc extends Bloc<MyProfilePrepaidEvent, MyProfilePrepaidState> {
  final MyProfilePrepaidRepository repository;

  MyProfilePrepaidBloc(this.repository) : super(MyProfilePrepaidState.initial()) {
    on<MyProfilePrepaidStarted>(_onStarted);

    on<MyProfilePrepaidBackPressed>(_onBack);
    on<MyProfilePrepaidHomePressed>(_onHome);
    on<MyProfilePrepaidEditEmailPressed>(_onEditEmail);
    on<MyProfilePrepaidChangePasswordPressed>(_onChangePassword);
  }

  Future<void> _onStarted(
      MyProfilePrepaidStarted event,
      Emitter<MyProfilePrepaidState> emit,
      ) async {
    try {
      emit(state.copyWith(status: MyProfilePrepaidStatus.loading, errorMessage: null));

      // Ensure device limits are loaded
      final deviceLimitsCubit = instance<DeviceLimitsCubit>();
      if (!deviceLimitsCubit.state.hasDeviceLimits) {
        await deviceLimitsCubit.loadDeviceLimits();
      }

      final data = await repository.fetchProfile();
      emit(state.copyWith(status: MyProfilePrepaidStatus.success, data: data));
    } catch (e) {
      emit(state.copyWith(
        status: MyProfilePrepaidStatus.failure,
        errorMessage: 'Failed to load profile',
      ));
    }
  }

  void _onBack(MyProfilePrepaidBackPressed event, Emitter<MyProfilePrepaidState> emit) {
    emit(state.copyWith(
      navAction: MyProfilePrepaidNavAction.back,
      navRequestId: state.navRequestId + 1,
    ));
  }

  void _onHome(MyProfilePrepaidHomePressed event, Emitter<MyProfilePrepaidState> emit) {
    emit(state.copyWith(
      navAction: MyProfilePrepaidNavAction.home,
      navRequestId: state.navRequestId + 1,
    ));
  }

  void _onEditEmail(MyProfilePrepaidEditEmailPressed event, Emitter<MyProfilePrepaidState> emit) {
    emit(state.copyWith(
      navAction: MyProfilePrepaidNavAction.editEmail,
      navRequestId: state.navRequestId + 1,
    ));
  }

  void _onChangePassword(
      MyProfilePrepaidChangePasswordPressed event,
      Emitter<MyProfilePrepaidState> emit,
      ) {
    emit(state.copyWith(
      navAction: MyProfilePrepaidNavAction.changePassword,
      navRequestId: state.navRequestId + 1,
    ));
  }
}
