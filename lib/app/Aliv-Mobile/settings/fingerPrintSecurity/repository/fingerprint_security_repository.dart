abstract class FingerPrintSecurityRepository {
  Future<FingerPrintSecurityContent> fetchContent();
}

class FingerPrintSecurityContent {
  final String header;
  final String body;

  const FingerPrintSecurityContent({
    required this.header,
    required this.body,
  });
}
