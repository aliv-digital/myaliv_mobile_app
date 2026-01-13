import '../bloc/edit_email_prepaid_state.dart';

class EditEmailPrepaidRepository {
  Future<EditEmailPrepaidData> fetchEditEmailData() async {
    // TODO: API call later
    await Future.delayed(const Duration(milliseconds: 250));

    return const EditEmailPrepaidData(
      fullName: 'Jade Turnquest',
      phoneNumber: '242-801-1616',
      gender: 'female',
      email: 'tanya.bain@bealiv.com',
    );
  }

  Future<void> updateEmail(String email) async {
    // TODO: API call later
    await Future.delayed(const Duration(milliseconds: 350));
  }
}
