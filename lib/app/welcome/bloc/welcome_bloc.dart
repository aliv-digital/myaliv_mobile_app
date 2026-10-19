import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'welcome_event.dart';
import 'welcome_state.dart';
import '../repository/welcome_repository.dart';

class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  final WelcomeRepository repository;

  WelcomeBloc({required this.repository}) : super(WelcomeInitial()) {
    on<WelcomeLoaded>(_onWelcomeLoaded);
  }

  Future<void> _onWelcomeLoaded(
    WelcomeLoaded event,
    Emitter<WelcomeState> emit,
  ) async {
    try {
      final data = await repository.loadData();
      if (data.isLoaded) {
        emit(
          WelcomeLoadedState(
            isLoaded: true,
            mobileImageUrl: data.mobileImageUrl,
          ),
        );
      } else {
        emit(WelcomeInitial());
      }
    } catch (e) {
      emit(WelcomeInitial());
    }
  }

  /// Resolves destination for "ALIV Mobile" button: always goes to Login.
  /// UI config is set up by AuthCompletionService after successful login.
  Future<String> resolveAlivMobileRoute() async {
    return AppRoutes.logIn;
  }
}
