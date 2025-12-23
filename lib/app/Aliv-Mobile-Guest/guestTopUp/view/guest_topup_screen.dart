// lib/features/guest_top_up/guest_top_up/view/guest_top_up_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/widgets/gradient_input_field.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import '../../../../resources/widgets/defaultButton.dart';
import '../bloc/guest_topup_bloc.dart';
import '../bloc/guest_topup_event.dart';
import '../bloc/guest_topup_state.dart';
import '../data/guest_topup_data.dart';
import '../repository/guest_topup_repository.dart';
import '../widgets/phone_number_input.dart';


class GuestTopUpScreen extends StatelessWidget {
  const GuestTopUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuestTopUpBloc(
          repository: const GuestTopUpRepository()
      )..add(const GuestTopUpStarted()),
      child: const _GuestTopUpView(),
    );
  }
}

class _GuestTopUpView extends StatelessWidget {
  const _GuestTopUpView();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<GuestTopUpBloc, GuestTopUpState>(
          listenWhen: (prev, curr) =>
          prev.status != curr.status && curr.status == GuestTopUpStatus.failure,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'll',
                ),
              ),
            );
          },
          child: Column(
            children: [
              DefaultAppBar(
                title: GuestTopUpStrings.guestTopUpAppbarTitle,
                onBack: () {
                  context.pop();
                },
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // enter phone number
                    SliverToBoxAdapter(
                      child: Padding(
                          padding: EdgeInsets.only(
                            top: 25,
                            left: 16,
                            right: 16
                          ),
                        child: LabeledInputField(
                            label: 'please enter an active prepaid number to top up',
                            hintText: 'eg: 242-899-9999',
                            onChanged: (v){}
                        ),
                      ),
                    ),
                    // confirm phone number
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 20,
                            left: 16,
                            right: 16
                        ),
                        child: LabeledInputField(
                            label: 'confirm mobile number',
                            hintText: 'eg: 242-899-9999',
                            onChanged: (v){}
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 44,bottom: 44),
                        child: GradientInputField(
                            label: 'enter top up amount',
                            hint: '00.00',
                            onChanged: (value){

                            }
                        ),
                      )
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 43,right: 43),
                        child: BlocBuilder<GuestTopUpBloc, GuestTopUpState>(

                          builder: (context, state) {
                            return DefaultButton(
                              onPressed: () {},
                              label: 'next',
                              isLoading: false,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class _TopBar extends StatelessWidget {
//   const _TopBar({
//     required this.title,
//     required this.onBack,
//   });
//
//   final String title;
//   final VoidCallback onBack;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 56,
//       width: double.infinity,
//       color: ColorManager.blueColor,
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: Row(
//         children: [
//           IconButton(
//             onPressed: onBack,
//             icon: const Icon(Icons.arrow_back_ios_new_rounded),
//             color: Colors.white,
//             iconSize: 20,
//             splashRadius: 22,
//           ),
//           const SizedBox(width: 4),
//           Expanded(
//             child: Text(
//               title,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 fontSize: 16,
//                 height: 1.25,
//                 fontFamily: 'CircularPro',
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



