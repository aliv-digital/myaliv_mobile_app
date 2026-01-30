abstract class HelpRepository {
  Future<HelpContent> fetchContent();
}

class HelpContent {
  final String title1;
  final String paragraph1;
  final String paragraph2;

  final String title2;
  final String paragraph3;
  final String paragraph4;

  const HelpContent({
    required this.title1,
    required this.paragraph1,
    required this.paragraph2,
    required this.title2,
    required this.paragraph3,
    required this.paragraph4,
  });
}
