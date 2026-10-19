import 'package:equatable/equatable.dart';

class ProfileMenuItemModel extends Equatable {
  final String id;
  final String title;
  final bool enabled;

  /// route future e router/app_routes diye connect korba
  /// example: '/prepaid/my-profile'
  final String? route;

  const ProfileMenuItemModel({
    required this.id,
    required this.title,
    required this.enabled,
    this.route,
  });

  @override
  List<Object?> get props => [id, title, enabled, route];
}
