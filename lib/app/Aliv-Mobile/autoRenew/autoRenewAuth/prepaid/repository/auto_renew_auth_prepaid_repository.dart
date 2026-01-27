class AutoRenewAuthContent {
  final String title;
  final String paragraph1;
  final String consentTitle;
  final String paragraph2;
  final String signatureName;
  final String nameLabel;
  final String nameHint;
  final String submitText;

  const AutoRenewAuthContent({
    required this.title,
    required this.paragraph1,
    required this.consentTitle,
    required this.paragraph2,
    required this.signatureName,
    required this.nameLabel,
    required this.nameHint,
    required this.submitText,
  });
}

abstract class AutoRenewAuthPrepaidRepository {
  Future<AutoRenewAuthContent> fetchContent();
  Future<void> submitAuthorization({required String name});
}

class AutoRenewAuthPrepaidRepositoryImpl implements AutoRenewAuthPrepaidRepository {
  @override
  Future<AutoRenewAuthContent> fetchContent() async {
    // Demo: later replace with API / Remote Config
    await Future.delayed(const Duration(milliseconds: 250));

    return const AutoRenewAuthContent(
      title: 'auto renew authorization form',
      paragraph1:
      'by providing my credit card ending *xxxx as payment method, i authorize ALIV and/or its agents to store my payment method information and to automatically charge plan renewal costs of qualifying plans for all subscriber lines on my account. i am certifying i am the payment method owner or have authorization to use the payment method information provided for the automatic charging of plan renewal costs.',
      consentTitle: 'electronic communication consent',
      paragraph2:
      'by entering my pin, full name matching the name displayed and clicking agree, i am providing my electronic signature as evidence that i understand the terms i am to which i am agreeing. in addition, i understand this automatic payment authorization will remain in effect until canceled by me via the myALIV app. the complete ALIV automatic payment policy will be sent to your account email address.',
      signatureName: 'James Brown',
      nameLabel: 'name',
      nameHint: 'type your name exactly as it appears on your account',
      submitText: 'submit',
    );
  }

  @override
  Future<void> submitAuthorization({required String name}) async {
    await Future.delayed(const Duration(milliseconds: 700));
  }
}
