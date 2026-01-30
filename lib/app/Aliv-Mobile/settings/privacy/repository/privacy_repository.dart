abstract class PrivacyRepository {
  Future<PrivacyContent> fetchContent();
}

class PrivacyContent {
  final String title1;
  final String paragraph1;
  final String paragraph2;

  final String title2;
  final String paragraph3;
  final String paragraph4;

  const PrivacyContent({
    required this.title1,
    required this.paragraph1,
    required this.paragraph2,
    required this.title2,
    required this.paragraph3,
    required this.paragraph4,
  });
}
