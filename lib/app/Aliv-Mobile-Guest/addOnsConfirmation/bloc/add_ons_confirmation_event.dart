import 'package:equatable/equatable.dart';

sealed class AddOnsConfirmationEvent extends Equatable {
  const AddOnsConfirmationEvent();
  @override
  List<Object?> get props => [];
}

final class AddOnsConfirmationStarted
    extends AddOnsConfirmationEvent {
  final String phoneNumber;
  const AddOnsConfirmationStarted(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

final class AddOnsConfirmationRemoveItemPressed
    extends AddOnsConfirmationEvent {
  final String itemId;
  const AddOnsConfirmationRemoveItemPressed(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

final class AddOnsConfirmationTermsPressed
    extends AddOnsConfirmationEvent {
  const AddOnsConfirmationTermsPressed();
}

final class AddOnsConfirmationTermsCheckboxToggled
    extends AddOnsConfirmationEvent {
  final bool isChecked;

  const AddOnsConfirmationTermsCheckboxToggled(this.isChecked);

  @override
  List<Object?> get props => [isChecked];
}

final class AddOnsConfirmationPayNowPressed
    extends AddOnsConfirmationEvent {
  const AddOnsConfirmationPayNowPressed();
}
