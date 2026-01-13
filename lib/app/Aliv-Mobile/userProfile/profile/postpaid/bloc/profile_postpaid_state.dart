import 'package:equatable/equatable.dart';

import '../models/profile_postpaid_models.dart';


enum ProfilePostpaidStatus { initial, loading, ready, failure }

class ProfilePostpaidState extends Equatable {
  final ProfilePostpaidStatus status;
  final List<ProfilePostpaidMenuItemModel> items;

  /// navigation signals
  final int backRequestId;
  final int openRouteRequestId;
  final String? routeToOpen;

  const ProfilePostpaidState({
    required this.status,
    required this.items,
    required this.backRequestId,
    required this.openRouteRequestId,
    required this.routeToOpen,
  });

  factory ProfilePostpaidState.initial() {
    return const ProfilePostpaidState(
      status: ProfilePostpaidStatus.initial,
      items: [],
      backRequestId: 0,
      openRouteRequestId: 0,
      routeToOpen: null,
    );
  }

  ProfilePostpaidState copyWith({
    ProfilePostpaidStatus? status,
    List<ProfilePostpaidMenuItemModel>? items,
    int? backRequestId,
    int? openRouteRequestId,
    String? routeToOpen,
  }) {
    return ProfilePostpaidState(
      status: status ?? this.status,
      items: items ?? this.items,
      backRequestId: backRequestId ?? this.backRequestId,
      openRouteRequestId: openRouteRequestId ?? this.openRouteRequestId,
      routeToOpen: routeToOpen ?? this.routeToOpen,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    backRequestId,
    openRouteRequestId,
    routeToOpen,
  ];
}
