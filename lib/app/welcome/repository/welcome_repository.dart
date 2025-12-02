class WelcomeRepository {
  // For now, we'll simulate a delay for loading data
  Future<bool> loadData() async {
    await Future.delayed(Duration(seconds: 2));
    return true;  // Return true to indicate the data is successfully loaded
  }
}
