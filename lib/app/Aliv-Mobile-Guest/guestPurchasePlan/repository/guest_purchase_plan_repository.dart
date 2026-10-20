import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/models/plan_categorization_result.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plans_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/bundle_response_parser.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_parser_service.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_visibility_filter.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

import '../models/plan_model.dart';
import '../services/guest_plan_presentation_mapper.dart';

enum PlanTab {
  daily,
  weekly,
  monthly,
  roaming,
  roameasy,
  addOns,
  mifi,
  libertyGlobal,
}

class GuestPurchasePlanRepository {
  GuestPurchasePlanRepository({
    required String phoneNumber,
    NetworkService? networkService,
    PlanParserService? parserService,
    GuestPlanPresentationMapper? presentationMapper,
  }) : _phoneNumber = _normalizePhoneNumber(phoneNumber),
       _networkService = networkService ?? instance<NetworkService>(),
       _parserService = parserService ?? PlanParserService(),
       _presentationMapper =
           presentationMapper ?? const GuestPlanPresentationMapper();

  static String _normalizePhoneNumber(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 7) {
      return '242$digits';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      return digits.substring(1);
    }
    return digits;
  }

  final String _phoneNumber;
  final NetworkService _networkService;
  final PlanParserService _parserService;
  final GuestPlanPresentationMapper _presentationMapper;

  Future<PlanCategorizationResult>? _catalogueRequest;
  PlanCategorizationResult? _cachedCatalogue;

  Future<List<GuestPlanDisplayModel>> fetchPlans({required PlanTab tab}) async {
    if (tab == PlanTab.addOns) return const <GuestPlanDisplayModel>[];

    final catalogue = await (_catalogueRequest ??= _fetchCatalogue());
    _cachedCatalogue = catalogue;
    final plans = switch (tab) {
      PlanTab.daily => catalogue.dailyPlans,
      PlanTab.weekly => catalogue.weeklyPlans,
      PlanTab.monthly => catalogue.monthlyPlans,
      PlanTab.roaming => catalogue.roamingPlans,
      PlanTab.roameasy => catalogue.roamEasyPlans,
      PlanTab.mifi => catalogue.mifiPlans,
      PlanTab.libertyGlobal => catalogue.libertyGlobalPlans,
      PlanTab.addOns => const <BasePlanModel>[],
    };

    return _presentationMapper.mapAll(
      PlanVisibilityFilter.visibleBasePlans(plans),
      isRoamEasy: tab == PlanTab.roameasy,
    );
  }

  /// Looks up the raw [BasePlanModel] by `planId` across every catalog
  /// tab. Used when the user taps a primary plan tile so the activate-now
  /// sheet decision tree and the dedicated add-ons screen can access
  /// `availableBoltOns`, `frequency`, etc.
  ///
  /// Returns `null` when the catalog hasn't loaded yet or the id is
  /// unknown.
  BasePlanModel? findBasePlanById(String planId) {
    final catalogue = _cachedCatalogue;
    if (catalogue == null) return null;

    final allTabLists = <List<BasePlanModel>>[
      catalogue.dailyPlans,
      catalogue.weeklyPlans,
      catalogue.monthlyPlans,
      catalogue.roamingPlans,
      catalogue.roamEasyPlans,
      catalogue.mifiPlans,
      catalogue.libertyGlobalPlans,
    ];
    for (final list in allTabLists) {
      for (final plan in list) {
        if (plan.planId == planId) return plan;
      }
    }
    return null;
  }

  Future<PlanCategorizationResult> _fetchCatalogue() async {
    if (_phoneNumber.isEmpty) {
      throw const FormatException('A phone number is required to load plans.');
    }

    final response = await _networkService.request<dynamic>(
      Api.guestAvailablePlansUrl,
      method: HttpMethod.post,
      data: <String, dynamic>{
        'RedirectURL': 'myaliv://topup-callback',
        'ChannelType': 'SelfCare',
        'Branch': 'branch',
        'PhoneNumber': _phoneNumber,
      },
      options: Options(extra: <String, dynamic>{'skipAuth': true}),
    );

    final rawPlans = _normalizePlanList(response.data);
    return _parserService.parseAndCategorize(rawPlans);
  }

  List<Map<String, dynamic>> _normalizePlanList(dynamic data) {
    final dynamic decoded = data is String ? jsonDecode(data) : data;
    final dynamic list = decoded is Map
        ? (decoded['Plans'] ??
              decoded['plans'] ??
              decoded['Data'] ??
              decoded['data'])
        : decoded;

    if (list is! List) {
      throw FormatException(
        'Expected the guest plans API to return an array, got ${list.runtimeType}.',
      );
    }

    return list
        .whereType<Map>()
        .map(
          (item) => item.map(
            (key, value) => MapEntry<String, dynamic>(key.toString(), value),
          ),
        )
        .toList(growable: false);
  }

  /// Fetches the entered phone number's active primary / secondary /
  /// stand-alone plans + available bolt-ons from `POST /Guest/existingplans`.
  ///
  /// The endpoint response shape is byte-for-byte identical to the
  /// authenticated `GET /device/{id}/bundles`, so parsing goes through
  /// the same [BundleResponseParser] the prepaid flow uses.
  Future<AddOnsResult> fetchExistingBundles() async {
    if (_phoneNumber.isEmpty) {
      throw const FormatException(
        'A phone number is required to load bundles.',
      );
    }

    final response = await _networkService.request<dynamic>(
      Api.guestExistingPlansUrl,
      method: HttpMethod.post,
      data: <String, dynamic>{
        'ChannelType': 'SelfCare',
        'PhoneNumber': _phoneNumber,
      },
      options: Options(extra: <String, dynamic>{'skipAuth': true}),
    );

    final bundles = _normalizeBundlesMap(response.data);
    return BundleResponseParser.parse(bundles);
  }

  Map<String, dynamic> _normalizeBundlesMap(dynamic data) {
    final dynamic decoded = data is String ? jsonDecode(data) : data;
    if (decoded is! Map) {
      throw FormatException(
        'Expected the guest existingplans API to return an object, '
        'got ${decoded.runtimeType}.',
      );
    }
    return decoded.map(
      (key, value) => MapEntry<String, dynamic>(key.toString(), value),
    );
  }

  /* PARKED 2026-10-20 — superseded by fetchExistingBundles() + the
     /Guest/existingplans endpoint. The guest add-ons tab now sources
     bolt-ons from the entered number's real active primary plan
     (AddOnsResult.addOns, built from PrimaryPlans[0].AvailableBoltOns).
     Keep until the alternate direct-add-ons entry point also migrates.

  // The direct Add-ons tab is a separate flow and has no guest endpoint yet.
  Future<List<AddOnModel>> fetchAddOns() async {
    return const <AddOnModel>[
      AddOnModel(
        id: 'a1',
        title: 'liberty data 1',
        label: 'data balance',
        value: '1gb',
        price: 5.00,
      ),
      AddOnModel(
        id: 'a2',
        title: 'liberty data 2',
        label: 'data balance',
        value: '2gb',
        price: 10.00,
      ),
      AddOnModel(
        id: 'a3',
        title: 'liberty data 3',
        label: 'data balance',
        value: '3gb',
        price: 16.00,
      ),
    ];
  }
  */
}
