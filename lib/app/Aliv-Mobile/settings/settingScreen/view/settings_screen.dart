import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../../../../../resources/widgets/default_app_bar.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../repository/settings_repository_impl.dart';
import '../theme/settings_theme.dart';
import '../widgets/biometric_turn_off_confirm_bottom_sheet.dart';
import '../widgets/settings_nav_tile.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/settings_toggle_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SettingsBloc(repository: SettingsRepositoryImpl())
            ..add(const SettingsStarted()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  // The toggle stays on until the user confirms with "yes".
  Future<void> _confirmTurnOff(
    BuildContext context, {
    required String message,
    required SettingsEvent event,
  }) async {
    final confirmed = await BiometricTurnOffConfirmBottomSheet.show(
      context,
      message: message,
    );
    if (confirmed && context.mounted) {
      context.read<SettingsBloc>().add(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listenWhen: (p, c) => p.navTarget != c.navTarget,
      listener: (context, state) {
        if (state.navTarget != SettingsNavTarget.none) {
          // navigation hook (pattern) - wire routes later
          context.read<SettingsBloc>().add(const SettingsNavConsumed());
        }
      },
      builder: (context, state) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: StripedScaffold(
            backgroundColor: SettingsTheme.bg,
            body: Column(
              children: [
                DefaultAppBar(
                  title: 'settings',
                  height: SettingsTheme.appBarHeight,
                  backgroundColor: SettingsTheme.appBarBg,
                  showBackArrow: true,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      31,
                      24,
                      16,
                    ), //SettingsTheme.pagePadding.copyWith(bottom: 120),
                    child: Column(
                      children: [
                        // Card 1: security
                        SettingsSectionCard(
                          children: [
                            SettingsNavTile(
                              iconAsset: AssetConstant.securityIconSVG,
                              title: 'security',
                              onTap: () {
                                context.push(AppRoutes.securityScreen);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Card 2: privacy + help
                        SettingsSectionCard(
                          children: [
                            SettingsNavTile(
                              iconAsset: AssetConstant.lockIconSVG,
                              title: 'privacy',
                              onTap: () {
                                context.read<SettingsBloc>().add(
                                  const PrivacyPressed(),
                                );
                                context.push(AppRoutes.privacyScreen);
                              },
                            ),

                            // SettingsNavTile(
                            //     iconAsset: AssetConstant.securityIconSVG,
                            //     title: 'security',
                            //     onTap: (){
                            //       context.push(AppRoutes.securityScreen);
                            //       context.read<SettingsBloc>().add(const SecurityPressed());
                            //     }
                            // ),
                            // SettingsNavTile(
                            //   iconAsset: AssetConstant.lifeRingIconSVG,
                            //   title: 'help',
                            //   onTap: () {
                            //     context.push(AppRoutes.helpScreen);
                            //     context.read<SettingsBloc>().add(
                            //       const HelpPressed(),
                            //     );
                            //   },
                            // ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Card 3: toggles — active only if device supports that biometric type
                        SettingsSectionCard(
                          printLine: false,
                          children: [
                            SettingsToggleTile(
                              title: 'login with fingerprint',
                              value: state.fingerprintEnabled,
                              enabled: state.isFingerprintAvailable,
                              onChanged: (v) {
                                if (v) {
                                  // Navigate to terms screen; after user agrees,
                                  // the security bloc calls enableFingerprintBiometric().
                                  // Reload settings state from the cubit on return.
                                  context
                                      .push(AppRoutes.fingerPrintSecurityScreen)
                                      .then((_) {
                                        if (context.mounted) {
                                          context.read<SettingsBloc>().add(
                                            const SettingsStarted(),
                                          );
                                        }
                                      });
                                } else {
                                  _confirmTurnOff(
                                    context,
                                    message:
                                        'are you sure you want to turn off fingerprint?',
                                    event: FingerprintToggled(false),
                                  );
                                }
                              },
                              iconAsset: AssetConstant.fingerprintIconSVG,
                            ),
                            SettingsToggleTile(
                              title: 'login with face id',
                              value: state.faceScanEnabled,
                              enabled: state.isFaceIdAvailable,
                              onChanged: (v) {
                                if (v) {
                                  context
                                      .push(AppRoutes.faceIdSecurityScreen)
                                      .then((_) {
                                        if (context.mounted) {
                                          context.read<SettingsBloc>().add(
                                            const SettingsStarted(),
                                          );
                                        }
                                      });
                                } else {
                                  _confirmTurnOff(
                                    context,
                                    message:
                                        'are you sure you want to turn off face id?',
                                    event: FaceScanToggled(false),
                                  );
                                }
                              },
                              iconAsset: AssetConstant.faceViewFinderIconSVG,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
