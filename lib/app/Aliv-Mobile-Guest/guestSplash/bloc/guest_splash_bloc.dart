import 'package:flutter_bloc/flutter_bloc.dart';
import 'guest_splash_event.dart';
import 'guest_splash_state.dart';
import '../repository/guest_splash_repository.dart';

class GuestSplashBloc extends Bloc<GuestSplashEvent, GuestSplashState> {
  final GuestSplashRepository repository;

  GuestSplashBloc(this.repository) : super(GuestSplashInitial()) {
    on<GuestSplashLoaded>(_onGuestSplashLoaded);
  }

  Future<void> _onGuestSplashLoaded(
      GuestSplashLoaded event,
      Emitter<GuestSplashState> emit,
      ) async {
    try {
      final isLoaded = await repository.loadData();
      if (isLoaded) {
        emit(GuestSplashLoadedState(isLoaded: true));
      } else {
        emit(GuestSplashInitial());
      }
    } catch (e) {
      emit(GuestSplashInitial());
    }
  }
}
