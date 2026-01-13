import 'package:equatable/equatable.dart';

class ProfilePostpaidMenuItemModel extends Equatable {
  final String id;
  final String title;
  final bool enabled;
  final String? route;

  const ProfilePostpaidMenuItemModel({
    required this.id,
    required this.title,
    required this.enabled,
    this.route,
  });

  @override
  List<Object?> get props => [id, title, enabled, route];
}
