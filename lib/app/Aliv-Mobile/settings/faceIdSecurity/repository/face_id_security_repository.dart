abstract class FaceIdSecurityRepository {
  Future<FaceIdSecurityContent> fetchContent();
}

class FaceIdSecurityContent {
  final String header;
  final String body;

  const FaceIdSecurityContent({
    required this.header,
    required this.body,
  });
}
