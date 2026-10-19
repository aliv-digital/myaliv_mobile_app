import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/model/login_country_selection.dart';

sealed class ReferFriendPrepaidEvent extends Equatable {
  const ReferFriendPrepaidEvent();

  @override
  List<Object?> get props => [];
}

class ReferFriendPrepaidStarted extends ReferFriendPrepaidEvent {
  const ReferFriendPrepaidStarted();
}

class ReferFriendPrepaidTabChanged extends ReferFriendPrepaidEvent {
  final int index;
  const ReferFriendPrepaidTabChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class ReferFriendPrepaidFriendPhoneChanged extends ReferFriendPrepaidEvent {
  final String value;
  const ReferFriendPrepaidFriendPhoneChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class ReferFriendPrepaidCountryChanged extends ReferFriendPrepaidEvent {
  final LoginCountrySelection selectedCountry;

  const ReferFriendPrepaidCountryChanged(this.selectedCountry);

  @override
  List<Object?> get props => [selectedCountry];
}

class ReferFriendPrepaidFriendEmailChanged extends ReferFriendPrepaidEvent {
  final String value;
  const ReferFriendPrepaidFriendEmailChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class ReferFriendPrepaidSharePressed extends ReferFriendPrepaidEvent {
  const ReferFriendPrepaidSharePressed();
}

class ReferFriendPrepaidRedeemCodeChanged extends ReferFriendPrepaidEvent {
  final String value;
  const ReferFriendPrepaidRedeemCodeChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class ReferFriendPrepaidRedeemPressed extends ReferFriendPrepaidEvent {
  const ReferFriendPrepaidRedeemPressed();
}

class ReferFriendPrepaidCopyPressed extends ReferFriendPrepaidEvent {
  final String code;
  const ReferFriendPrepaidCopyPressed(this.code);

  @override
  List<Object?> get props => [code];
}

class ReferFriendPrepaidToastConsumed extends ReferFriendPrepaidEvent {
  const ReferFriendPrepaidToastConsumed();
}

class ReferFriendPrepaidErrorConsumed extends ReferFriendPrepaidEvent {
  const ReferFriendPrepaidErrorConsumed();
}
