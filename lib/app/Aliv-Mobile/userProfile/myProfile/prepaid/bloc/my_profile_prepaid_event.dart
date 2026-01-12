import 'package:equatable/equatable.dart';

abstract class MyProfilePrepaidEvent extends Equatable {
  const MyProfilePrepaidEvent();

  @override
  List<Object?> get props => [];
}

class MyProfilePrepaidStarted extends MyProfilePrepaidEvent {
  const MyProfilePrepaidStarted();
}

class MyProfilePrepaidBackPressed extends MyProfilePrepaidEvent {
  const MyProfilePrepaidBackPressed();
}

class MyProfilePrepaidHomePressed extends MyProfilePrepaidEvent {
  const MyProfilePrepaidHomePressed();
}

class MyProfilePrepaidEditEmailPressed extends MyProfilePrepaidEvent {
  const MyProfilePrepaidEditEmailPressed();
}

class MyProfilePrepaidChangePasswordPressed extends MyProfilePrepaidEvent {
  const MyProfilePrepaidChangePasswordPressed();
}
