import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/cubit/limited_offer_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/cubit/limited_offer_state.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/widgets/animated_timer_box.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';

/// Self-contained Limited Time Offer widget
///
/// This widget handles:
/// - BlocBuilder for state management
/// - Conditional rendering (shows only when offer is available)
/// - Live countdown timer display
/// - Click handling (opens offer link)
/// - Error handling
///
/// Usage in HomeScreen:
/// ```dart
/// import 'package:myaliv_mobile_app/app/Home/limited-time-offer/view/limited_offer_view.dart';
///
/// // In build method:
/// LimitedOfferView(),
/// ```
class LimitedOfferView extends StatefulWidget {
  const LimitedOfferView({super.key, this.onSeeCurrentOffers});

  /// Supplied only by prepaid Home, using its existing ALIV deals action.
  final VoidCallback? onSeeCurrentOffers;

  @override
  State<LimitedOfferView> createState() => _LimitedOfferViewState();
}

class _LimitedOfferViewState extends State<LimitedOfferView> {
  bool _hasExpiredOffer = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LimitedOfferCubit, LimitedOfferState>(
      builder: (context, state) {
        final offer = state.currentOffer;
        final timeRemaining = offer?.timeRemaining;

        // Retain the prepaid ended card during the existing automatic refresh.
        // A new offer or session reset clears this presentation-only state.
        if (widget.onSeeCurrentOffers == null ||
            state.status == LimitedOfferStatus.initial) {
          _hasExpiredOffer = false;
        } else if (offer != null) {
          _hasExpiredOffer =
              offer.isPrepaid &&
              offer.status == 'active' &&
              timeRemaining!.inSeconds <= 0;
        }

        // Reduced logging to avoid spam (timer updates every second)
        // Uncomment for debugging:
        // debugPrint('🖼️ LIMITED OFFER VIEW: Rebuilding (status: ${state.status})');

        // Don't show widget if:
        // - No offer available
        // - Still loading
        // - State is empty
        if (!_hasExpiredOffer &&
            (!state.hasOffer || state.isLoading || state.isEmpty)) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 11, 24, 0),
            child: GestureDetector(
              onTap: _hasExpiredOffer
                  ? null
                  : () => _handleTap(context, offer!.link),
              child: Container(
                width: double.infinity,
                height: 112,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9D933), // Yellow background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (_hasExpiredOffer) {
                      return _buildExpiredOffer();
                    }

                    final timerGap = constraints.maxWidth < 320 ? 4.0 : 6.0;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left side: Title + Subtitle
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offer!.title,
                                style: const TextStyle(
                                  color: Color(0xFF101828),
                                  fontSize: 20,
                                  // 40/2
                                  fontFamily: 'CircularPro',
                                  fontWeight: FontWeight.w700,
                                  height: 1.05,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                offer.subHeading,
                                style: const TextStyle(
                                  color: Color(0xFF101828),
                                  fontSize: 10,
                                  fontFamily: 'CircularPro',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.05,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Right side: Live countdown timer
                        Expanded(
                          flex: 7,
                          child: Row(
                            children: [
                              // Days
                              Expanded(
                                child: AnimatedTimerBox(
                                  _formatTimerValue(timeRemaining!.inDays),
                                  'Days',
                                  compact: true,
                                ),
                              ),
                              SizedBox(width: timerGap),

                              // Hours
                              Expanded(
                                child: AnimatedTimerBox(
                                  _formatTimerValue(timeRemaining.inHours % 24),
                                  'Hours',
                                  compact: true,
                                ),
                              ),
                              SizedBox(width: timerGap),

                              // Minutes
                              Expanded(
                                child: AnimatedTimerBox(
                                  _formatTimerValue(
                                    timeRemaining.inMinutes % 60,
                                  ),
                                  'Min',
                                  compact: true,
                                ),
                              ),
                              SizedBox(width: timerGap),

                              // Seconds
                              Expanded(
                                child: AnimatedTimerBox(
                                  _formatTimerValue(
                                    timeRemaining.inSeconds % 60,
                                  ),
                                  'Sec',
                                  compact: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpiredOffer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'this offer has ended',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF101828),
            fontSize: 20,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 4),
        DefaultButton(
          label: 'see current offers',
          isLoading: false,
          onPressed: widget.onSeeCurrentOffers,
        ),
      ],
    );
  }

  /// Handle tap on offer card
  ///
  /// Opens the offer link in external browser if available
  void _handleTap(BuildContext context, String? link) {
    if (link == null || link.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(link);
    if (uri == null) {
      return;
    }

    launchUrl(uri, mode: LaunchMode.externalApplication).catchError((error) {
      // Silently fail if URL can't be opened
      // In production, you might want to show a toast/snackbar
      debugPrint('Failed to open offer link: $error');
      return false;
    });
  }

  /// Format timer value with leading zero
  ///
  /// Examples:
  /// - 5 → "05"
  /// - 12 → "12"
  String _formatTimerValue(int value) {
    return value.toString().padLeft(2, '0');
  }
}
