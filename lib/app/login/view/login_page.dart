import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../resources/color_manager.dart';
import '../../../resources/constants/asset_constants.dart';
import '../../../router/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String countryCode = '+1';
  String countryFlag = '🇧🇸';// Default flag for Bangladesh
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Scrollable main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),

                      // Logo
                      Center(
                        child: SvgPicture.asset(
                          AssetConstant.splashLogoSVG,
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Welcome Text
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'The journey to ALIV Events starts here and Aliv together with YOU!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // Country Picker + Phone Number Field
                      GestureDetector(
                        onTap: () => _showCountryPicker(context),
                        child: Row(
                          children: [
                            Text(
                              '$countryFlag $countryCode',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomInputField(
                        controller: phoneController,
                        label: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      CustomInputField(
                        controller: passwordController,
                        label: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.push(AppRoutes.forgotPassword);
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),

                      // Sign In Button
                      BlocListener<AuthBloc, AuthState>(
                        listener: (context, state) {
                          debugPrint("state : ${state.status}");
                          if (state.status == AuthStatus.success) {
                            context.push(
                                AppRoutes.otp,
                                extra: {
                                  "who":"${countryCode.substring(1)}${phoneController.text}",
                                  "isRedirectedFromForgotPass" : "false"
                                }
                            );
                          }
                        },
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {

                            return ElevatedButton(
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                  SignInPressed(
                                    phoneNumber: "${countryCode.substring(1)}${phoneController.text}",
                                    password: passwordController.text,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorManager.buttonColor,
                                minimumSize: const Size(double.infinity, 54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: (state.status == AuthStatus.loading)
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                'Sign In',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Error message
                      if (context.watch<AuthBloc>().state.status == AuthStatus.failure)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            context.watch<AuthBloc>().state.error ?? 'Unknown Error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _showCountryPicker(BuildContext context) {
    showCountryPicker(
      favorite: ['BS'],
      context: context,
      onSelect: (Country country) {
        setState(() {
          countryCode = '+${country.phoneCode}'; // add '+' to phone code
          countryFlag = country.flagEmoji;
        });
      },
      countryListTheme: const CountryListThemeData(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        inputDecoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
