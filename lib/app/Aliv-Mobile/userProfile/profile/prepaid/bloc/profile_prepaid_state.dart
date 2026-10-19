import 'package:equatable/equatable.dart';
import '../model/profile_prepaid_models.dart';

enum ProfilePrepaidStatus { initial, loading, ready, failure }

class ProfilePrepaidState extends Equatable {
  final ProfilePrepaidStatus status;
  final List<ProfileMenuItemModel> items;

  /// navigation signals (UI will listen)
  final int backRequestId;
  final int openRouteRequestId;
  final String? routeToOpen;

  const ProfilePrepaidState({
    required this.status,
    required this.items,
    required this.backRequestId,
    required this.openRouteRequestId,
    required this.routeToOpen,
  });

  factory ProfilePrepaidState.initial() {
    return const ProfilePrepaidState(
      status: ProfilePrepaidStatus.initial,
      items: [],
      backRequestId: 0,
      openRouteRequestId: 0,
      routeToOpen: null,
    );
  }

  ProfilePrepaidState copyWith({
    ProfilePrepaidStatus? status,
    List<ProfileMenuItemModel>? items,
    int? backRequestId,
    int? openRouteRequestId,
    String? routeToOpen,
  }) {
    return ProfilePrepaidState(
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
