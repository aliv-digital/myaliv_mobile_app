import 'package:flutter_bloc/flutter_bloc.dart';
import 'welcome_event.dart';
import 'welcome_state.dart';
import '../repository/welcome_repository.dart';

class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  final WelcomeRepository repository;

  // Constructor
  WelcomeBloc(this.repository) : super(WelcomeInitial()) {
    // Registering the event handler for WelcomeLoaded
    on<WelcomeLoaded>(_onWelcomeLoaded);
  }

  // Event handler method for WelcomeLoaded
  Future<void> _onWelcomeLoaded(WelcomeLoaded event, Emitter<WelcomeState> emit) async {
    try {
      // Simulating data loading from the repository
      final isLoaded = await repository.loadData();
      if (isLoaded) {
        emit(WelcomeLoadedState(isLoaded: true));  // Successfully loaded data
      } else {
        emit(WelcomeInitial());  // Handle failure or no data
      }
    } catch (e) {
      emit(WelcomeInitial());  // Handle errors
    }
  }
}
