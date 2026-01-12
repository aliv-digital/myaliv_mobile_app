import 'package:equatable/equatable.dart';

sealed class EditEmailPrepaidEvent extends Equatable {
  const EditEmailPrepaidEvent();

  @override
  List<Object?> get props => [];
}

class EditEmailPrepaidStarted extends EditEmailPrepaidEvent {
  const EditEmailPrepaidStarted();
}

class EditEmailPrepaidBackPressed extends EditEmailPrepaidEvent {
  const EditEmailPrepaidBackPressed();
}

class EditEmailPrepaidHomePressed extends EditEmailPrepaidEvent {
  const EditEmailPrepaidHomePressed();
}

class EditEmailPrepaidEmailChanged extends EditEmailPrepaidEvent {
  final String email;
  const EditEmailPrepaidEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class EditEmailPrepaidSavePressed extends EditEmailPrepaidEvent {
  const EditEmailPrepaidSavePressed();
}
