import 'package:equatable/equatable.dart';

import '../model/support_models.dart';

enum SupportStatus { initial, ready }

class SupportState extends Equatable {
  final SupportStatus status;
  final List<SupportMenuItem> menuItems;
  final SupportQuickHelpInfo quickHelp;
  final List<SupportChatMessage> chatMessages;
  final SupportNavigationRequest? navigationRequest;
  final SupportLaunchRequest? launchRequest;
  final int actionSequence;

  const SupportState({
    required this.status,
    required this.menuItems,
    required this.quickHelp,
    required this.chatMessages,
    required this.navigationRequest,
    required this.launchRequest,
    required this.actionSequence,
  });

  factory SupportState.initial() {
    return const SupportState(
      status: SupportStatus.initial,
      menuItems: <SupportMenuItem>[],
      quickHelp: SupportQuickHelpInfo(
        title: 'get quick help!',
        assetPath: 'assets/icons/support_help.svg',
        dialNumber: '611',
        leadingText: 'Please dial ',
        trailingText: ' from your mobile device for call centre support',
      ),
      chatMessages: <SupportChatMessage>[],
      navigationRequest: null,
      launchRequest: null,
      actionSequence: 0,
    );
  }

  SupportState copyWith({
    SupportStatus? status,
    List<SupportMenuItem>? menuItems,
    SupportQuickHelpInfo? quickHelp,
    List<SupportChatMessage>? chatMessages,
    SupportNavigationRequest? navigationRequest,
    SupportLaunchRequest? launchRequest,
    int? actionSequence,
  }) {
    return SupportState(
      status: status ?? this.status,
      menuItems: menuItems ?? this.menuItems,
      quickHelp: quickHelp ?? this.quickHelp,
      chatMessages: chatMessages ?? this.chatMessages,
      navigationRequest: navigationRequest,
      launchRequest: launchRequest,
      actionSequence: actionSequence ?? this.actionSequence,
    );
  }

  @override
  List<Object?> get props => [
    status,
    menuItems,
    quickHelp,
    chatMessages,
    navigationRequest,
    launchRequest,
    actionSequence,
  ];
}
