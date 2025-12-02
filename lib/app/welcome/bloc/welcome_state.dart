abstract class WelcomeState {}

class WelcomeInitial extends WelcomeState {}

class WelcomeLoadedState extends WelcomeState {
  // You can store data here that the UI will use (e.g., isLoaded flag)
  final bool isLoaded;

  WelcomeLoadedState({required this.isLoaded});
}
