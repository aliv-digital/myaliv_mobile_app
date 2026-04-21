abstract class SecurityRepository {
  Future<SecurityContent> fetchContent();
}

class SecurityContent {
  final String htmlContent;

  const SecurityContent({
    required this.htmlContent,
  });
}