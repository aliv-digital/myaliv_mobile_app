abstract class PrivacyRepository {
  Future<PrivacyContent> fetchContent();
}

class PrivacyContent {
  final String htmlContent;

  const PrivacyContent({
    required this.htmlContent,
  });
}