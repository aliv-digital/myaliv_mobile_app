import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart'; // Replace with your asset constants
import '../bloc/welcome_bloc.dart';
import '../bloc/welcome_event.dart';
import '../bloc/welcome_state.dart';
import '../repository/welcome_repository.dart';
import '../widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,  // Background transparent
        statusBarIconBrightness: Brightness.light, // ANDROID → white icons
        statusBarBrightness: Brightness.dark,       // iOS → white icons
      ),
    );
    return BlocProvider(
      create: (context) => WelcomeBloc(WelcomeRepository())..add(WelcomeLoaded()),
      child: WelcomeView(),
    );
  }
}

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<WelcomeBloc, WelcomeState>(
        builder: (context, state) {
          if (state is WelcomeInitial) {
            return Center(child: CircularProgressIndicator());
          } else if (state is WelcomeLoadedState) {
            return Column(
              children: [
                // Top Half - Background Image with ALIV Logo (stacked section)
                Expanded(
                  flex: 1,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          AssetConstant.welcomeImageSVG,  // Background image
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 80,  // Adjust this to vertically center the logo
                        left: MediaQuery.of(context).size.width / 2 - 96,
                        right: MediaQuery.of(context).size.width / 2 - 96,
                        child: SvgPicture.asset(
                          AssetConstant.splashLogoSVG,  // ALIV logo
                          width: 192,
                          height: 98,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Half - Purple Color Block with Buttons
                Expanded(
                  flex: 0,
                  child: Container(
                    height: 317,
                    width: double.infinity,
                    color: ColorManager.welcomeScreenBloc,  // Purple color block for the bottom section
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // "Welcome to ALIV" text
                        Text(
                          'Welcome to ALIV',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'CircularPro',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.30,
                          ),
                        ),
                        SizedBox(height: 20),

                        // Buttons with spacing
                        CustomButton(
                          label: 'ALIV Mobile',
                          onPressed: () {
                            // Handle the button press
                          },
                        ),
                        SizedBox(height: 18),
                        CustomButton(
                          label: 'ALIVfbr',
                          onPressed: () {
                            // Handle the button press
                          },
                        ),
                        SizedBox(height: 18),
                        CustomButton(
                          label: 'ALIV Mobile Guest',
                          onPressed: () {
                            // Handle the button press
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return Container(); // Default return case
        },
      ),
    );
  }
}
