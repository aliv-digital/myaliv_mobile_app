

import '../models/profile_postpaid_models.dart';

class ProfilePostpaidRepository {
  Future<List<ProfilePostpaidMenuItemModel>> fetchMenuItems() async {
    // Future: API call (postpaid-specific endpoints)
    return const [
      ProfilePostpaidMenuItemModel(
        id: 'my_profile',
        title: 'my profile',
        enabled: true,
        route: null,
      ),
      ProfilePostpaidMenuItemModel(
        id: 'my_plans',
        title: 'my plans',
        enabled: true,
        route: null,
      ),
      ProfilePostpaidMenuItemModel(
        id: 'call_logs',
        title: 'call logs',
        enabled: true,
        route: null,
      ),
      ProfilePostpaidMenuItemModel(
        id: 'rewards',
        title: 'rewards',
        enabled: true,
        route: null,
      ),
      ProfilePostpaidMenuItemModel(
        id: 'gift_data',
        title: 'Gift Data',
        enabled: false, // screenshot মতো disabled/grey
        route: null,
      ),
    ];
  }
}
