// import 'package:country_picker/country_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/guest_splash_bloc.dart';
// import '../bloc/guest_splash_event.dart';
// import '../bloc/guest_splash_state.dart';
// import '../model/guest_purchase_plan_input.dart';
//
//
// Future<GuestSplashPurchasePlanInput?> showGuestSplashPurchasePlanBottomSheet(BuildContext context) async {
//   final service = CountryService();
//   final initialCountry = service.findByCode('BS') ?? service.findByCode('US');
//
//   // ✅ init sheet state inside same GuestSplashBloc
//   context.read<GuestSplashBloc>().add(GuestSplashPurchasePlanInit(initialCountry: initialCountry));
//
//   return showModalBottomSheet<GuestSplashPurchasePlanInput>(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     barrierColor: Colors.black.withOpacity(0.35),
//     builder: (_) {
//       return BlocProvider.value(
//         value: context.read<GuestSplashBloc>(),
//         child: const _GuestSplashPurchasePlanSheetView(),
//       );
//     },
//   );
// }
//
// class _GuestSplashPurchasePlanSheetView extends StatelessWidget {
//   const _GuestSplashPurchasePlanSheetView();
//
//   @override
//   Widget build(BuildContext context) {
//     final bottomInset = MediaQuery.of(context).viewInsets.bottom;
//
//     return BlocListener<GuestSplashBloc, GuestSplashState>(
//       listenWhen: (p, c) {
//         if (p is GuestSplashLoadedState && c is GuestSplashLoadedState) {
//           return p.purchaseStatus != c.purchaseStatus;
//         }
//         return false;
//       },
//       listener: (context, state) {
//         if (state is GuestSplashLoadedState) {
//           if (state.purchaseStatus == GuestSplashPurchasePlanStatus.success && state.purchaseResult != null) {
//             Navigator.of(context).pop(state.purchaseResult);
//
//             // ✅ reset so it won't trigger again
//             context.read<GuestSplashBloc>().add(GuestSplashPurchasePlanReset());
//           }
//         }
//       },
//       child: Padding(
//         padding: EdgeInsets.only(bottom: bottomInset),
//         child: SafeArea(
//           top: false,
//           child: Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 520),
//               child: Material(
//                 color: Colors.transparent,
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//                   padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(22),
//                   ),
//                   child: const _SheetBody(),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _SheetBody extends StatelessWidget {
//   const _SheetBody();
//
//   static const Color _buttonColor = Color(0xFF5D5A8B);
//   static const Color _borderColor = Color(0xFFE3E3E3);
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<GuestSplashBloc, GuestSplashState>(
//       builder: (context, state) {
//         if (state is! GuestSplashLoadedState) {
//           return const SizedBox.shrink();
//         }
//
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _Header(
//               title: 'guest purchase a plan',
//               onBack: () => Navigator.of(context).pop(),
//             ),
//             const SizedBox(height: 18),
//
//             const _Label('enter mobile number'),
//             const SizedBox(height: 8),
//             _PhoneRow(
//               country: state.purchaseCountry,
//               hint: 'eg: 242-899-9999',
//               onPickCountry: () => _pickCountry(context),
//               onChanged: (v) => context.read<GuestSplashBloc>().add(GuestSplashPurchasePlanPhoneChanged(v)),
//             ),
//
//             const SizedBox(height: 16),
//
//             const _Label('confirm mobile number'),
//             const SizedBox(height: 8),
//             _PhoneRow(
//               country: state.purchaseCountry,
//               hint: 'eg: 242-899-9999',
//               onPickCountry: () => _pickCountry(context),
//               onChanged: (v) => context.read<GuestSplashBloc>().add(GuestSplashPurchasePlanConfirmPhoneChanged(v)),
//             ),
//
//             const SizedBox(height: 14),
//
//             if (state.purchaseStatus == GuestSplashPurchasePlanStatus.failure &&
//                 (state.purchaseErrorMessage?.isNotEmpty ?? false))
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 10),
//                 child: Text(
//                   state.purchaseErrorMessage!,
//                   style: const TextStyle(
//                     fontSize: 12.5,
//                     color: Colors.red,
//                     fontFamily: 'CircularPro',
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//
//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _buttonColor,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
//                 ),
//                 onPressed: () => context.read<GuestSplashBloc>().add(GuestSplashPurchasePlanSubmitted()),
//                 child: const Text(
//                   'continue',
//                   style: TextStyle(
//                     fontSize: 14.5,
//                     fontFamily: 'CircularPro',
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _pickCountry(BuildContext context) {
//     showCountryPicker(
//       context: context,
//       showPhoneCode: true,
//       onSelect: (country) {
//         context.read<GuestSplashBloc>().add(GuestSplashPurchasePlanCountryChanged(country));
//       },
//     );
//   }
// }
//
// class _Header extends StatelessWidget {
//   final String title;
//   final VoidCallback onBack;
//
//   const _Header({required this.title, required this.onBack});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         InkWell(
//           borderRadius: BorderRadius.circular(22),
//           onTap: onBack,
//           child: const Padding(
//             padding: EdgeInsets.all(6),
//             child: Icon(Icons.arrow_back, size: 22),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 18,
//             fontFamily: 'CircularPro',
//             fontWeight: FontWeight.w700,
//             color: Colors.black,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _Label extends StatelessWidget {
//   final String text;
//   const _Label(this.text);
//
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: const TextStyle(
//         fontSize: 13,
//         fontFamily: 'CircularPro',
//         fontWeight: FontWeight.w700,
//         color: Colors.black,
//       ),
//     );
//   }
// }
//
// class _PhoneRow extends StatelessWidget {
//   final Country? country;
//   final String hint;
//   final VoidCallback onPickCountry;
//   final ValueChanged<String> onChanged;
//
//   const _PhoneRow({
//     required this.country,
//     required this.hint,
//     required this.onPickCountry,
//     required this.onChanged,
//   });
//
//   static const Color _borderColor = Color(0xFFE3E3E3);
//
//   @override
//   Widget build(BuildContext context) {
//     final dial = country?.phoneCode ?? '1';
//     final flag = country?.flagEmoji ?? '🏳️';
//
//     return Row(
//       children: [
//         InkWell(
//           onTap: onPickCountry,
//           borderRadius: BorderRadius.circular(10),
//           child: Container(
//             height: 52,
//             width: 82,
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             decoration: BoxDecoration(
//               border: Border.all(color: _borderColor, width: 1),
//               borderRadius: BorderRadius.circular(10),
//               color: Colors.white,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(flag, style: const TextStyle(fontSize: 18)),
//                 const SizedBox(width: 6),
//                 Text(
//                   dial,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontFamily: 'CircularPro',
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Container(
//             height: 52,
//             padding: const EdgeInsets.symmetric(horizontal: 14),
//             decoration: BoxDecoration(
//               border: Border.all(color: _borderColor, width: 1),
//               borderRadius: BorderRadius.circular(10),
//               color: Colors.white,
//             ),
//             alignment: Alignment.center,
//             child: TextField(
//               onChanged: onChanged,
//               keyboardType: TextInputType.phone,
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(RegExp(r'[0-9\- ]')),
//               ],
//               decoration: InputDecoration(
//                 border: InputBorder.none,
//                 hintText: hint,
//                 hintStyle: const TextStyle(
//                   color: Color(0xFFB7B7B7),
//                   fontSize: 14,
//                   fontFamily: 'CircularPro',
//                   fontWeight: FontWeight.w400,
//                 ),
//                 isCollapsed: true,
//               ),
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontFamily: 'CircularPro',
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/guest_splash_bloc.dart';
import '../bloc/guest_splash_event.dart';
import '../bloc/guest_splash_state.dart';
import '../model/guest_purchase_plan_input.dart';


Future<GuestSplashPurchasePlanInput?> showGuestSplashPurchasePlanBottomSheet(
    BuildContext context,
    ) async {
  final service = CountryService();
  final initialCountry = service.findByCode('BS') ?? service.findByCode('US');

  // Init bottom-sheet state in same bloc
  context
      .read<GuestSplashBloc>()
      .add(GuestSplashPurchasePlanInit(initialCountry: initialCountry));

  return showModalBottomSheet<GuestSplashPurchasePlanInput>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (_) {
      return BlocProvider.value(
        value: context.read<GuestSplashBloc>(),
        child: const _GuestSplashPurchasePlanSheetView(),
      );
    },
  );
}

class _GuestSplashPurchasePlanSheetView extends StatelessWidget {
  const _GuestSplashPurchasePlanSheetView();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // ✅ BottomSheet route animation
    final routeAnim = ModalRoute.of(context)?.animation;

    Widget sheet = BlocListener<GuestSplashBloc, GuestSplashState>(
      listenWhen: (p, c) {
        if (p is GuestSplashLoadedState && c is GuestSplashLoadedState) {
          return p.purchaseStatus != c.purchaseStatus;
        }
        return false;
      },
      listener: (context, state) {
        if (state is GuestSplashLoadedState) {
          if (state.purchaseStatus == GuestSplashPurchasePlanStatus.success &&
              state.purchaseResult != null) {
            Navigator.of(context).pop(state.purchaseResult);
            context.read<GuestSplashBloc>().add(GuestSplashPurchasePlanReset());
          }
        }
      },
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: const _SheetBody(),
          ),
        ),
      ),
    );

    // ✅ Add extra animation (fade + slide) on top of default bottomSheet motion
    if (routeAnim == null) return sheet;

    final curved = CurvedAnimation(
      parent: routeAnim,
      curve: Curves.easeOutCubic,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.12), // little extra from bottom
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      child: sheet,
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody();

  static const Color _buttonColor = Color(0xFF5D5A8B);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuestSplashBloc, GuestSplashState>(
      builder: (context, state) {
        if (state is! GuestSplashLoadedState) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              title: 'guest purchase a plan',
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 18),

            const _Label('enter mobile number'),
            const SizedBox(height: 8),
            _PhoneRow(
              country: state.purchaseCountry,
              hint: 'eg: 242-899-9999',
              onPickCountry: () => _pickCountry(context),
              onChanged: (v) => context
                  .read<GuestSplashBloc>()
                  .add(GuestSplashPurchasePlanPhoneChanged(v)),
            ),

            const SizedBox(height: 16),

            const _Label('confirm mobile number'),
            const SizedBox(height: 8),
            _PhoneRow(
              country: state.purchaseCountry,
              hint: 'eg: 242-899-9999',
              onPickCountry: () => _pickCountry(context),
              onChanged: (v) => context
                  .read<GuestSplashBloc>()
                  .add(GuestSplashPurchasePlanConfirmPhoneChanged(v)),
            ),

            const SizedBox(height: 14),

            if (state.purchaseStatus == GuestSplashPurchasePlanStatus.failure &&
                (state.purchaseErrorMessage?.isNotEmpty ?? false))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  state.purchaseErrorMessage!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.red,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () {
                 // context.read<GuestSplashBloc>().add(GuestSplashPurchasePlanSubmitted());

                  context.push(AppRoutes.guestPurchasePlan);
                },
                child: const Text(
                  'continue',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _pickCountry(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (country) {
        context
            .read<GuestSplashBloc>()
            .add(GuestSplashPurchasePlanCountryChanged(country));
      },
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onBack,
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.arrow_back, size: 22),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontFamily: 'CircularPro',
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }
}

class _PhoneRow extends StatelessWidget {
  final Country? country;
  final String hint;
  final VoidCallback onPickCountry;
  final ValueChanged<String> onChanged;

  const _PhoneRow({
    required this.country,
    required this.hint,
    required this.onPickCountry,
    required this.onChanged,
  });

  static const Color _borderColor = Color(0xFFE3E3E3);

  @override
  Widget build(BuildContext context) {
    final dial = country?.phoneCode ?? '1';
    final flag = country?.flagEmoji ?? '🏳️';

    return Row(
      children: [
        InkWell(
          onTap: onPickCountry,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 52,
            width: 82,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: _borderColor, width: 1),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(flag, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  dial,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: _borderColor, width: 1),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            alignment: Alignment.center,
            child: TextField(
              onChanged: onChanged,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\- ]')),
              ],
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFFB7B7B7),
                  fontSize: 14,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w400,
                ),
                isCollapsed: true,
              ),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
