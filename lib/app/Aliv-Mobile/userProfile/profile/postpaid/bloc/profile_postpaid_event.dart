import 'package:equatable/equatable.dart';

import '../models/profile_postpaid_models.dart';

sealed class ProfilePostpaidEvent extends Equatable {
  const ProfilePostpaidEvent();

  @override
  List<Object?> get props => [];
}

final class ProfilePostpaidStarted extends ProfilePostpaidEvent {
  const ProfilePostpaidStarted();
}

final class ProfilePostpaidBackPressed extends ProfilePostpaidEvent {
  const ProfilePostpaidBackPressed();
}

final class ProfilePostpaidItemPressed extends ProfilePostpaidEvent {
  final ProfilePostpaidMenuItemModel item;
  const ProfilePostpaidItemPressed(this.item);

  @override
  List<Object?> get props => [item];
}
