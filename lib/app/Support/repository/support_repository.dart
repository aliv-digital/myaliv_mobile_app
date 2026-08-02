import 'package:dio/dio.dart';

import '../model/support_models.dart';

class SupportRepository {
  final Dio dio;

  const SupportRepository({required this.dio});

  List<SupportMenuItem> fetchMenuItems() {
    return const <SupportMenuItem>[
      // SupportMenuItem(
      //   id: 'chat_bot',
      //   title: 'chat bot',
      //   action: SupportMenuAction.chatBot,
      // ),
      SupportMenuItem(
        id: 'store_locator',
        title: 'store locator',
        action: SupportMenuAction.storeLocator,
      ),
      SupportMenuItem(
        id: 'support',
        title: 'support',
        action: SupportMenuAction.callSupport,
      ),
      SupportMenuItem(
        id: 'whatsapp',
        title: 'whatsapp',
        action: SupportMenuAction.whatsapp,
      ),
      SupportMenuItem(id: 'faq', title: 'FAQ', action: SupportMenuAction.faq),
    ];
  }

  SupportQuickHelpInfo fetchQuickHelpInfo() {
    return const SupportQuickHelpInfo(
      title: 'get quick help!',
      assetPath: 'assets/icons/support_help.svg',
      dialNumber: '611',
      leadingText: 'Please dial ',
      trailingText: ' from your mobile device for call centre support',
    );
  }

  List<SupportChatMessage> fetchChatMessages() {
    return const <SupportChatMessage>[
      SupportChatMessage(
        id: 'time_0941',
        type: SupportChatMessageType.time,
        text: '09:41 AM',
      ),
      SupportChatMessage(
        id: 'user_hi',
        type: SupportChatMessageType.user,
        text: 'Hi, Mandy',
        avatarUrl: _defaultUserAvatarUrl,
      ),
      SupportChatMessage(
        id: 'user_app',
        type: SupportChatMessageType.user,
        text: "I've tried the app",
        avatarUrl: _defaultUserAvatarUrl,
      ),
      SupportChatMessage(
        id: 'bot_really',
        type: SupportChatMessageType.bot,
        text: 'Really?',
      ),
      SupportChatMessage(
        id: 'user_good',
        type: SupportChatMessageType.user,
        text: "Yeah, It's really good!",
        avatarUrl: _defaultUserAvatarUrl,
      ),
      SupportChatMessage(
        id: 'typing',
        type: SupportChatMessageType.typing,
        text: 'Typing...',
      ),
    ];
  }

  static final faqUri =  Uri.parse("https://www.bealiv.com/aliv-mobile-faqs/");

  Future<Uri> fetchFaqUri() async {
    const String endpoint =
        'https://myalivappuat-api.bealiv.com/api/app-settings/faqs';

    final Response<dynamic> response = await dio.get(endpoint);
    final dynamic responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw Exception('Invalid FAQ response format');
    }

    final dynamic data = responseData['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('FAQ data not found');
    }

    final String? rawUrl = data['value'] as String?;
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      throw Exception('FAQ url is empty');
    }

    final String normalizedUrl = _normalizeUrl(rawUrl);
    return Uri.parse(normalizedUrl);
  }

  Uri get storeLocatorUri => Uri.parse('https://www.bealiv.com/store-locator/');

  Uri get whatsappUri => Uri.parse('https://wa.me/12423002548');

  Uri get callSupportUri => Uri(scheme: 'tel', path: '611');

  String _normalizeUrl(String url) {
    final String trimmedUrl = url.trim();

    if (trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://')) {
      return trimmedUrl;
    }

    return 'https://$trimmedUrl';
  }

  static const String _defaultUserAvatarUrl =
      'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg';
}
