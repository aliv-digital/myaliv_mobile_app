import 'package:equatable/equatable.dart';

enum SupportMenuAction { chatBot, storeLocator, callSupport, whatsapp, faq }

enum SupportNavigationTarget { chatBot, quickHelp }

enum SupportChatMessageType { time, user, bot, typing }

class SupportMenuItem extends Equatable {
  final String id;
  final String title;
  final SupportMenuAction action;

  const SupportMenuItem({
    required this.id,
    required this.title,
    required this.action,
  });

  @override
  List<Object?> get props => [id, title, action];
}

class SupportQuickHelpInfo extends Equatable {
  final String title;
  final String assetPath;
  final String dialNumber;
  final String leadingText;
  final String trailingText;

  const SupportQuickHelpInfo({
    required this.title,
    required this.assetPath,
    required this.dialNumber,
    required this.leadingText,
    required this.trailingText,
  });

  @override
  List<Object?> get props => [
    title,
    assetPath,
    dialNumber,
    leadingText,
    trailingText,
  ];
}

class SupportChatMessage extends Equatable {
  final String id;
  final SupportChatMessageType type;
  final String text;
  final String? avatarUrl;

  const SupportChatMessage({
    required this.id,
    required this.type,
    required this.text,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, type, text, avatarUrl];
}

class SupportNavigationRequest extends Equatable {
  final int id;
  final SupportNavigationTarget target;

  const SupportNavigationRequest({required this.id, required this.target});

  @override
  List<Object?> get props => [id, target];
}

class SupportLaunchRequest extends Equatable {
  final int id;
  final Uri uri;
  final String failureMessage;

  const SupportLaunchRequest({
    required this.id,
    required this.uri,
    required this.failureMessage,
  });

  @override
  List<Object?> get props => [id, uri, failureMessage];
}
