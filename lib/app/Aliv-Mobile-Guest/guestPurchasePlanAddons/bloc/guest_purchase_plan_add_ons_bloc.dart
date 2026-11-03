import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_frequency.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_frequency_estimator.dart';

import '../../guestPurchasePlan/models/plan_model.dart';
import '../../guestPurchasePlan/services/guest_add_on_filter_service.dart';
import '../model/add_on_models.dart';
import '../repository/guest_purchase_plan_add_ons_repository.dart';
import 'guest_purchase_plan_add_ons_event.dart';
import 'guest_purchase_plan_add_ons_state.dart';

class GuestPurchasePlanAddOnsBloc
    extends Bloc<GuestPurchasePlanAddOnsEvent, GuestPurchasePlanAddOnsState> {
  final GuestPurchasePlanAddOnsRepository repository;
  final GuestAddOnFilterService _addOnFilterService;

  GuestPurchasePlanAddOnsBloc({
    required this.repository,
    GuestAddOnFilterService? addOnFilterService,
  }) : _addOnFilterService =
           addOnFilterService ?? const GuestAddOnFilterService(),
       super(GuestPurchasePlanAddOnsState.initial()) {
    on<GuestPurchasePlanAddOnsStarted>(_onStarted);
    on<GuestPurchasePlanAddOnsAutoRenewToggled>(_onAutoRenewToggled);
    on<GuestPurchasePlanAddOnsSelectionToggled>(_onSelectionToggled);
    on<GuestPurchasePlanAddOnsSkipPressed>(_onSkipPressed);
    on<GuestPurchasePlanAddOnsProceedPressed>(_onProceedPressed);
  }

  static final DateFormat _cardDateFormat = DateFormat('dd/MM/yy');

  Future<void> _onStarted(
    GuestPurchasePlanAddOnsStarted event,
    Emitter<GuestPurchasePlanAddOnsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GuestPurchasePlanAddOnsStatus.loading,
        errorMessage: null,
      ),
    );

    // Preferred path — build everything from the real catalog model +
    // /Guest/existingplans context passed through route args.
    final GuestPurchasePlanAddOnsRouteArgs? args = event.routeArgs;
    final BasePlanModel? selectedBasePlan = args?.selectedBasePlan;
    if (args != null && selectedBasePlan != null) {
      try {
        final FairUsePolicy policy = await repository.fetchFairUsePolicy();

        final ActivePlanSummary summary = _buildActivePlanSummary(
          selected: selectedBasePlan,
          existingActivePlan: args.existingActivePlan,
        );

        final List<AddOnItem> addOns = _buildAddOnItems(selectedBasePlan);

        emit(
          state.copyWith(
            status: GuestPurchasePlanAddOnsStatus.ready,
            activePlan: summary,
            fairUsePolicy: policy,
            addOns: addOns,
          ),
        );
        return;
      } catch (e) {
        emit(
          state.copyWith(
            status: GuestPurchasePlanAddOnsStatus.error,
            errorMessage: 'Failed to load add-ons',
          ),
        );
        return;
      }
    }

    // Legacy / fallback path — kept so existing callers (direct deep
    // links, tests, the standalone "add-ons" direct-entry flow) still
    // work until they migrate to pass route args.
    try {
      // Loading in parallel makes UI faster (clean + readable).
      final results = await Future.wait([
        repository.fetchActivePlan(),
        repository.fetchFairUsePolicy(),
        repository.fetchAddOns(),
      ]);

      emit(
        state.copyWith(
          status: GuestPurchasePlanAddOnsStatus.ready,
          activePlan: results[0] as dynamic,
          fairUsePolicy: results[1] as dynamic,
          addOns: results[2] as dynamic,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GuestPurchasePlanAddOnsStatus.error,
          errorMessage: 'Failed to load add-ons',
        ),
      );
    }
  }

  /// Builds the red "new active plan will be" card using the plan the
  /// user picked + the entered number's existing active plan context.
  /// Dates are computed by [PlanFrequencyEstimator] so the math matches
  /// prepaid's optimistic active-plan injection exactly.
  ActivePlanSummary _buildActivePlanSummary({
    required BasePlanModel selected,
    required BasePlanModel? existingActivePlan,
  }) {
    final DateTime nowUtc = DateTime.now().toUtc();
    // If there's an existing active plan, the new plan chains after its
    // end date. Otherwise it starts immediately.
    final DateTime startUtc =
        existingActivePlan?.endDateTime?.toUtc() ?? nowUtc;
    final PlanFrequency? frequency = PlanFrequency.parse(selected.frequency);
    final DateTime? endUtc = PlanFrequencyEstimator.estimateEndDate(
      startUtc,
      frequency,
    );

    return ActivePlanSummary(
      label: 'new active plan will be',
      name: selected.planName,
      autoRenew: selected.autoRenew,
      activeDateLabel: 'will active on',
      activeDate: _cardDateFormat.format(startUtc.toLocal()),
      expireDateLabel: 'will expire on',
      expireDate: endUtc != null
          ? _cardDateFormat.format(endUtc.toLocal())
          : '--/--/--',
    );
  }

  /// Builds the add-on tile list from the selected plan's
  /// `AvailableBoltOns`, using the same guest rules as the route decision.
  List<AddOnItem> _buildAddOnItems(BasePlanModel selected) {
    return _addOnFilterService
        .filterAvailableAddOns(selected.availableBoltOns)
        .map(
          (addOn) => AddOnItem(
            id: addOn.id,
            title: addOn.title,
            subtitleLabel: addOn.label,
            subtitleValue: addOn.value,
            price: addOn.price,
            vatAmount: addOn.vatAmount,
          ),
        )
        .toList(growable: false);
  }

  void _onAutoRenewToggled(
    GuestPurchasePlanAddOnsAutoRenewToggled event,
    Emitter<GuestPurchasePlanAddOnsState> emit,
  ) {
    final plan = state.activePlan;
    if (plan == null) return;

    emit(state.copyWith(activePlan: plan.copyWith(autoRenew: event.value)));
  }

  void _onSelectionToggled(
    GuestPurchasePlanAddOnsSelectionToggled event,
    Emitter<GuestPurchasePlanAddOnsState> emit,
  ) {
    final updated = {...state.selectedAddOnIds};
    if (event.selected) {
      updated.add(event.addOnId);
    } else {
      updated.remove(event.addOnId);
    }
    emit(state.copyWith(selectedAddOnIds: updated));
  }

  void _onSkipPressed(
    GuestPurchasePlanAddOnsSkipPressed event,
    Emitter<GuestPurchasePlanAddOnsState> emit,
  ) {
    emit(state.copyWith(skipRequestId: state.skipRequestId + 1));
  }

  void _onProceedPressed(
    GuestPurchasePlanAddOnsProceedPressed event,
    Emitter<GuestPurchasePlanAddOnsState> emit,
  ) {
    emit(state.copyWith(proceedRequestId: state.proceedRequestId + 1));
  }
}
