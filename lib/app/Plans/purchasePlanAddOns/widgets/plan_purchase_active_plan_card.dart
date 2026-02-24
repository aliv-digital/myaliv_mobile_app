// import 'package:flutter/material.dart';
//
// import '../model/plan_purchase_add_on_models.dart';
// import '../theme/plan_purchase_plan_add_ons_theme.dart';
//
// /// PlanPurchaseActivePlanCard
// /// কেন LayoutBuilder ব্যবহার করছি?
// /// - তোমার card height fixed হলে ছোট device এ text/padding যোগ হয়ে overflow হয়
// /// - LayoutBuilder দিয়ে available height/width বুঝে আমরা scale factor বের করি
// /// - scale factor দিয়ে সব font/spacing proportional ভাবে ছোট/বড় হয়, তাই overflow হয় না
// class PlanPurchaseActivePlanCard extends StatelessWidget {
//   final PlanPurchaseActivePlanSummary plan;
//   final ValueChanged<bool> onAutoRenewChanged;
//
//   const PlanPurchaseActivePlanCard({
//     super.key,
//     required this.plan,
//     required this.onAutoRenewChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // card width-এর উপর ভিত্তি করে height রাখলে responsive হয়
//         // (screenshot-like proportion + overflow safe)
//         final w = constraints.maxWidth;
//         final h = (w * 0.46).clamp(140.0, 175.0); // responsive height
//
//         // design baseline ধরা হলো 170 height
//         final scale = (h / 170.0).clamp(0.82, 1.0);
//
//         return SizedBox(
//           height: h,
//           child: _CardBody(
//             plan: plan,
//             onAutoRenewChanged: onAutoRenewChanged,
//             scale: scale,
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _CardBody extends StatelessWidget {
//   final PlanPurchaseActivePlanSummary plan;
//   final ValueChanged<bool> onAutoRenewChanged;
//   final double scale;
//
//   const _CardBody({
//     required this.plan,
//     required this.onAutoRenewChanged,
//     required this.scale,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final padH = 26.0 * scale;
//     final padV = 22.0 * scale;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: PlanPurchasePlanAddOnsTheme.planRed,
//         borderRadius: BorderRadius.circular(26),
//         boxShadow: const [
//           BoxShadow(
//             blurRadius: 26,
//             offset: Offset(0, 18),
//             color: PlanPurchasePlanAddOnsTheme.shadow,
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(26),
//         child: Stack(
//           children: [
//             // --- Background shapes (visual only) ---
//             Positioned(
//               left: -80,
//               bottom: -90,
//               child: Container(
//                 width: 220,
//                 height: 220,
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.08),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ),
//             Positioned(
//               right: -90,
//               top: -110,
//               child: Container(
//                 width: 260,
//                 height: 260,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.10),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ),
//
//             // watermark
//             Positioned.fill(
//               child: Opacity(
//                 opacity: 0.10,
//                 child: Center(
//                   child: Text(
//                     'aliv',
//                     style: PlanPurchasePlanAddOnsTheme.t(
//                       96 * scale,
//                       weight: FontWeight.w800,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // content
//             Padding(
//               padding: EdgeInsets.fromLTRB(padH, padV, padH, padV),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Top row
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         plan.label,
//                         style: PlanPurchasePlanAddOnsTheme.t(
//                           18 * scale,
//                           weight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const Spacer(),
//
//                       AutoRenewToggle(
//                         value: plan.autoRenew,
//                         scale: scale,
//                         onChanged: onAutoRenewChanged,
//                       ),
//                       SizedBox(width: 10 * scale),
//                       Text(
//                         'auto renew',
//                         style: PlanPurchasePlanAddOnsTheme.t(
//                           18 * scale,
//                           weight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   SizedBox(height: 10 * scale),
//
//                   // Plan name (scaleDown to avoid vertical/horizontal overflow)
//                   Expanded(
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: FittedBox(
//                         fit: BoxFit.scaleDown,
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           plan.name,
//                           maxLines: 1,
//                           style: PlanPurchasePlanAddOnsTheme.t(
//                             44 * scale,
//                             weight: FontWeight.w900,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   SizedBox(height: 6 * scale),
//
//                   // Bottom dates
//                   Row(
//                     children: [
//                       _DateBlock(
//                         label: plan.activeDateLabel,
//                         value: plan.activeDate,
//                         alignEnd: false,
//                         scale: scale,
//                       ),
//                       const Spacer(),
//                       _DateBlock(
//                         label: plan.expireDateLabel,
//                         value: plan.expireDate,
//                         alignEnd: true,
//                         scale: scale,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /// Toggle: tap করলে on/off হবে (BLoC event wired)
// class AutoRenewToggle extends StatelessWidget {
//   final bool value;
//   final ValueChanged<bool> onChanged;
//   final double scale;
//
//   const AutoRenewToggle({
//     super.key,
//     required this.value,
//     required this.onChanged,
//     required this.scale,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     const offCircle = Color(0xFFEDECF6);
//
//     return InkWell(
//       onTap: () => onChanged(!value),
//       borderRadius: BorderRadius.circular(999),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         curve: Curves.easeOut,
//         height: 34 * scale,
//         padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(999),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Padding(
//               padding: EdgeInsets.only(left: 6 * scale, right: 8 * scale),
//               child: Text(
//                 value ? 'on' : 'off',
//                 style: PlanPurchasePlanAddOnsTheme.t(
//                   16 * scale,
//                   weight: FontWeight.w800,
//                   color: PlanPurchasePlanAddOnsTheme.textBlack,
//                 ),
//               ),
//             ),
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 180),
//               curve: Curves.easeOut,
//               width: 26 * scale,
//               height: 26 * scale,
//               decoration: BoxDecoration(
//                 color: value ? PlanPurchasePlanAddOnsTheme.planRedDark : offCircle,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 value ? Icons.check : Icons.close,
//                 size: 16 * scale,
//                 color: value ? Colors.white : PlanPurchasePlanAddOnsTheme.planRedDark,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _DateBlock extends StatelessWidget {
//   final String label;
//   final String value;
//   final bool alignEnd;
//   final double scale;
//
//   const _DateBlock({
//     required this.label,
//     required this.value,
//     required this.alignEnd,
//     required this.scale,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: PlanPurchasePlanAddOnsTheme.t(
//             18 * scale,
//             weight: FontWeight.w700,
//             color: Colors.white,
//           ),
//         ),
//         SizedBox(height: 8 * scale),
//         FittedBox(
//           fit: BoxFit.scaleDown,
//           child: Text(
//             value,
//             style: PlanPurchasePlanAddOnsTheme.t(
//               30 * scale,
//               weight: FontWeight.w900,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import '../model/plan_purchase_add_on_models.dart';
// import '../theme/plan_purchase_plan_add_ons_theme.dart';
//
// /// PlanPurchaseActivePlanCard (Figma-match)
// /// - Plan name (liberty70) visible + big
// /// - "aliv" watermark behind
// /// - Toggle looks like Figma and is functional
// /// - Responsive-safe: scale only when card gets smaller
// class PlanPurchaseActivePlanCard extends StatelessWidget {
//   final PlanPurchaseActivePlanSummary plan;
//   final ValueChanged<bool> onAutoRenewChanged;
//
//   const PlanPurchaseActivePlanCard({
//     super.key,
//     required this.plan,
//     required this.onAutoRenewChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (_, constraints) {
//         final w = constraints.maxWidth;
//
//         // Figma-like proportion: width-based height
//         final h = (w * 0.46).clamp(150.0, 175.0);
//         final scale = (h / 170.0).clamp(0.86, 1.0);
//
//         return SizedBox(
//           height: h,
//           child: _Card(
//             plan: plan,
//             scale: scale,
//             onAutoRenewChanged: onAutoRenewChanged,
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _Card extends StatelessWidget {
//   final PlanPurchaseActivePlanSummary plan;
//   final double scale;
//   final ValueChanged<bool> onAutoRenewChanged;
//
//   const _Card({
//     required this.plan,
//     required this.scale,
//     required this.onAutoRenewChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final padH = 26.0 * scale;
//     final padV = 22.0 * scale;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: PlanPurchasePlanAddOnsTheme.planRed,
//         borderRadius: BorderRadius.circular(26),
//         boxShadow: const [
//           BoxShadow(
//             blurRadius: 26,
//             offset: Offset(0, 18),
//             color: PlanPurchasePlanAddOnsTheme.shadow,
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(26),
//         child: Stack(
//           children: [
//             // Background soft curves (visual only)
//             Positioned(
//               left: -80,
//               bottom: -90,
//               child: Container(
//                 width: 220,
//                 height: 220,
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.08),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ),
//             Positioned(
//               right: -90,
//               top: -110,
//               child: Container(
//                 width: 260,
//                 height: 260,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.10),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ),
//
//             // "aliv" watermark behind
//             Positioned.fill(
//               child: Opacity(
//                 opacity: 0.10,
//                 child: Center(
//                   child: Transform.translate(
//                     offset: Offset(0, 6 * scale),
//                     child: Text(
//                       'aliv',
//                       style: PlanPurchasePlanAddOnsTheme.t(
//                         96 * scale,
//                         weight: FontWeight.w900,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // Content
//             Padding(
//               padding: EdgeInsets.fromLTRB(padH, padV, padH, padV),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Top row: active plan + toggle + auto renew
//                   Row(
//                     children: [
//                       Text(
//                         plan.label,
//                         style: PlanPurchasePlanAddOnsTheme.t(
//                           18 * scale,
//                           weight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const Spacer(),
//                       AutoRenewToggle(
//                         value: plan.autoRenew,
//                         scale: scale,
//                         onChanged: onAutoRenewChanged,
//                       ),
//                       SizedBox(width: 10 * scale),
//                       Text(
//                         'auto renew',
//                         style: PlanPurchasePlanAddOnsTheme.t(
//                           18 * scale,
//                           weight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   SizedBox(height: 10 * scale),
//
//                   // Plan name (Figma: big, bold)
//                   SizedBox(
//                     height: 54 * scale,
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: FittedBox(
//                         fit: BoxFit.scaleDown,
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           plan.name,
//                           maxLines: 1,
//                           style: PlanPurchasePlanAddOnsTheme.t(
//                             44 * scale,
//                             weight: FontWeight.w900,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const Spacer(),
//
//                   // Bottom dates
//                   Row(
//                     children: [
//                       _DateBlock(
//                         label: plan.activeDateLabel,
//                         value: plan.activeDate,
//                         alignEnd: false,
//                         scale: scale,
//                       ),
//                       const Spacer(),
//                       _DateBlock(
//                         label: plan.expireDateLabel,
//                         value: plan.expireDate,
//                         alignEnd: true,
//                         scale: scale,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /// Toggle pill (Figma style) + state changes via BLoC
// class AutoRenewToggle extends StatelessWidget {
//   final bool value;
//   final ValueChanged<bool> onChanged;
//   final double scale;
//
//   const AutoRenewToggle({
//     super.key,
//     required this.value,
//     required this.onChanged,
//     required this.scale,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     const offCircle = Color(0xFFEDECF6);
//
//     return InkWell(
//       onTap: () => onChanged(!value),
//       borderRadius: BorderRadius.circular(999),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         curve: Curves.easeOut,
//         height: 34 * scale,
//         padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(999),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Padding(
//               padding: EdgeInsets.only(left: 6 * scale, right: 8 * scale),
//               child: Text(
//                 value ? 'on' : 'off',
//                 style: PlanPurchasePlanAddOnsTheme.t(
//                   16 * scale,
//                   weight: FontWeight.w800,
//                   color: PlanPurchasePlanAddOnsTheme.textBlack,
//                 ),
//               ),
//             ),
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 180),
//               curve: Curves.easeOut,
//               width: 26 * scale,
//               height: 26 * scale,
//               decoration: BoxDecoration(
//                 color: value ? PlanPurchasePlanAddOnsTheme.planRedDark : offCircle,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 value ? Icons.check : Icons.close,
//                 size: 16 * scale,
//                 color: value ? Colors.white : PlanPurchasePlanAddOnsTheme.planRedDark,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _DateBlock extends StatelessWidget {
//   final String label;
//   final String value;
//   final bool alignEnd;
//   final double scale;
//
//   const _DateBlock({
//     required this.label,
//     required this.value,
//     required this.alignEnd,
//     required this.scale,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: PlanPurchasePlanAddOnsTheme.t(
//             2 * scale,
//             weight: FontWeight.w700,
//             color: Colors.white,
//           ),
//         ),
//         SizedBox(height: 8 * scale),
//         FittedBox(
//           fit: BoxFit.scaleDown,
//           child: Text(
//             value,
//             style: PlanPurchasePlanAddOnsTheme.t(
//               30 * scale,
//               weight: FontWeight.w900,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../model/plan_purchase_add_on_models.dart';

import '../theme/plan_purchase_plan_add_ons_theme.dart';

/// PlanPurchaseActivePlanCard (Overflow-safe + Figma-like)
/// কেন overflow হচ্ছিল?
/// - ছোট ডিভাইসে card-এর height কম হয়
/// - কিন্তু text sizes/padding fixed থাকলে Column content বেশি হয়ে যায়
///
/// এই সমাধান কী করে?
/// - card height width অনুযায়ী set করে (responsive)
/// - content height কম হলে scale down করে দেয় (0.72..1.0)
/// - plan name অংশ Expanded করে দিলাম, তাই fixed height না ধরে space share করে
/// - date/value গুলো FittedBox(scaleDown) দিয়ে shrink করতে পারে, overflow না দিয়ে
class PlanPurchaseActivePlanCard extends StatelessWidget {
  final PlanPurchaseActivePlanSummary plan;
  final ValueChanged<bool> onAutoRenewChanged;

  const PlanPurchaseActivePlanCard({
    super.key,
    required this.plan,
    required this.onAutoRenewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;

        // Screenshot proportion-এর কাছাকাছি রেখে responsive height
        // ছোট ডিভাইসে height কম হবে, বড় ডিভাইসে একটু বাড়বে।
        final h = (w * 0.50).clamp(160.0, 190.0);

        // Design baseline ধরা হলো 185 height (এই baseline এ text/padding সুন্দর বসে)
        // height কম হলে scale down হবে।
        final scale = (h / 185.0).clamp(0.72, 1.0);

        return SizedBox(
          height: h,
          child: _CardBody(
            plan: plan,
            scale: scale,
            onAutoRenewChanged: onAutoRenewChanged,
          ),
        );
      },
    );
  }
}

class _CardBody extends StatelessWidget {
  final PlanPurchaseActivePlanSummary plan;
  final double scale;
  final ValueChanged<bool> onAutoRenewChanged;

  const _CardBody({
    required this.plan,
    required this.scale,
    required this.onAutoRenewChanged,
  });

  @override
  Widget build(BuildContext context) {
    // padding একটু কমানো হলো, যাতে ছোট height এও content ফিট হয়
    final padH = 22.0 * scale;
    final padV = 16.0 * scale;

    return Container(
      decoration: BoxDecoration(
        color: PlanPurchasePlanAddOnsTheme.planRed,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            blurRadius: 26,
            offset: Offset(0, 18),
            color: PlanPurchasePlanAddOnsTheme.shadow,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // ---- Soft background curves (visual only) ----
            Positioned(
              left: -80,
              bottom: -90,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -90,
              top: -110,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ---- Watermark "aliv" (behind) ----
            Positioned.fill(
              child: Opacity(
                opacity: 0.10,
                child: Center(
                  child: Transform.translate(
                    offset: Offset(0, 6 * scale),
                    child: Text(
                      'aliv',
                      style: PlanPurchasePlanAddOnsTheme.t(
                        92 * scale,
                        weight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ---- Main content ----
            Padding(
              padding: EdgeInsets.fromLTRB(padH, padV, padH, padV),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(
                    children: [
                      Text(
                        plan.label, // "active plan"
                        style: PlanPurchasePlanAddOnsTheme.t(
                          16 * scale,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      AutoRenewToggle(
                        value: plan.autoRenew,
                        scale: scale,
                        onChanged: onAutoRenewChanged,
                      ),
                      SizedBox(width: 10 * scale),
                      Text(
                        'auto renew',
                        style: PlanPurchasePlanAddOnsTheme.t(
                          16 * scale,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8 * scale),

                  // Plan name: Expanded করে দিলাম যাতে height share করে
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          plan.name, // "liberty70"
                          maxLines: 1,
                          style: PlanPurchasePlanAddOnsTheme.t(
                            42 * scale,
                            weight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 6 * scale),

                  // Bottom dates (always visible + overflow-safe)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        _DateBlock(
                          label: plan.activeDateLabel, // "active"
                          value: plan.activeDate,      // "20/08/24"
                          alignEnd: false,
                          scale: scale,
                        ),
                        const Spacer(),
                        _DateBlock(
                          label: plan.expireDateLabel, // "expire"
                          value: plan.expireDate,      // "19/09/24"
                          alignEnd: true,
                          scale: scale,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Toggle pill (Figma style) + BLoC state connect
class AutoRenewToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double scale;

  const AutoRenewToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    const offCircle = Color(0xFFEDECF6);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 32 * scale,
        padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 6 * scale, right: 8 * scale),
              child: Text(
                value ? 'on' : 'off',
                style: PlanPurchasePlanAddOnsTheme.t(
                  15 * scale,
                  weight: FontWeight.w800,
                  color: PlanPurchasePlanAddOnsTheme.textBlack,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 24 * scale,
              height: 24 * scale,
              decoration: BoxDecoration(
                color: value ? PlanPurchasePlanAddOnsTheme.planRedDark : offCircle,
                shape: BoxShape.circle,
              ),
              child: Icon(
                value ? Icons.check : Icons.close,
                size: 15 * scale,
                color: value ? Colors.white : PlanPurchasePlanAddOnsTheme.planRedDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;
  final double scale;

  const _DateBlock({
    required this.label,
    required this.value,
    required this.alignEnd,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: PlanPurchasePlanAddOnsTheme.t(
            14 * scale,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6 * scale),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: PlanPurchasePlanAddOnsTheme.t(
              26 * scale,
              weight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
