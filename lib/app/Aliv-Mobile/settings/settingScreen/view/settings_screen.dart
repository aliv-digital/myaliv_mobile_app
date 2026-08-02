import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
import '../../../../../../resources/widgets/default_app_bar.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../repository/settings_repository_impl.dart';
import '../theme/settings_theme.dart';
import '../widgets/settings_nav_tile.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/settings_toggle_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc(
        repository: SettingsRepositoryImpl(),
      )..add(const SettingsStarted()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

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
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
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
                    padding: EdgeInsets.fromLTRB(24, 31, 24, 16),//SettingsTheme.pagePadding.copyWith(bottom: 120),
                    child: Column(
                      children: [
                            // Card 1: security
                            SettingsSectionCard(
                              children: [
                                SettingsNavTile(
                                    iconAsset: AssetConstant.securityIconSVG,
                                    title: 'security',
                                    onTap: (){
                                      context.push(AppRoutes.securityScreen);
                                    }
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
                                    onTap: (){
                                      context.read<SettingsBloc>().add(const PrivacyPressed());
                                      context.push(AppRoutes.privacyScreen);
                                    }
                                ),
                                // SettingsNavTile(
                                //     iconAsset: AssetConstant.securityIconSVG,
                                //     title: 'security',
                                //     onTap: (){
                                //       context.push(AppRoutes.securityScreen);
                                //       context.read<SettingsBloc>().add(const SecurityPressed());
                                //     }
                                // ),

                                SettingsNavTile(
                                    iconAsset: AssetConstant.lifeRingIconSVG,
                                    title: 'help',
                                    onTap: (){
                                      context.push(AppRoutes.helpScreen);
                                      context.read<SettingsBloc>().add(const HelpPressed());
                                    }
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Card 3: toggles
                            SettingsSectionCard(
                              printLine: false,
                              children: [
                                SettingsToggleTile(

                                  title: 'login with fingerprint',
                                  value: state.fingerprintEnabled,
                                  onChanged: (v) {
                                    context.push(AppRoutes.fingerPrintSecurityScreen);
                                    context.read<SettingsBloc>().add(FingerprintToggled(v));
                                  },
                                  iconAsset: AssetConstant.fingerprintIconSVG,
                                ),
                                SettingsToggleTile(
                                  title: 'login with face scan',
                                  value: state.faceScanEnabled,
                                  onChanged: (v) {
                                    context.push(AppRoutes.faceIdSecurityScreen);
                                    context.read<SettingsBloc>().add(FaceScanToggled(v));
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
