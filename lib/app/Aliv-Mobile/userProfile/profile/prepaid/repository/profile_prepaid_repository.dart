import '../model/profile_prepaid_models.dart';

class ProfilePrepaidRepository {
  Future<List<ProfileMenuItemModel>> fetchMenuItems() async {
    // Future: API call
    return const [
      ProfileMenuItemModel(
        id: 'my_profile',
        title: 'my profile',
        enabled: true,
        route: null,
      ),
      ProfileMenuItemModel(
        id: 'my_plans',
        title: 'my plans',
        enabled: true,
        route: null,
      ),
      ProfileMenuItemModel(
        id: 'call_logs',
        title: 'call logs',
        enabled: true,
        route: null,
      ),
      ProfileMenuItemModel(
        id: 'rewards',
        title: 'rewards',
        enabled: true,
        route: null,
      ),
      ProfileMenuItemModel(
        id: 'gift_data',
        title: 'Gift Data',
        enabled: false, // screenshot e disabled/grey
        route: null,
      ),
    ];
  }
}
