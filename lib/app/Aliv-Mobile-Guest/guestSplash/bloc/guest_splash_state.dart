abstract class GuestSplashState {}

class GuestSplashInitial extends GuestSplashState {}

class GuestSplashLoadedState extends GuestSplashState {
  // You can store data here that the UI will use (e.g., isLoaded flag)
  final bool isLoaded;

  GuestSplashLoadedState({required this.isLoaded});
}
