import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/repository/home_plans_payment_method_repository_impl.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/view/home_plans_payment_method_view.dart';

/// Entry point for the payment screen: sets the status bar, provides the
/// bloc, and seeds it with the route's configuration. UI lives in
/// [HomePlansPaymentMethodView].
class HomePlansPaymentMethodScreen extends StatelessWidget {
  final HomePlansPaymentMethodRouteArgs args;

  const HomePlansPaymentMethodScreen({
    super.key,
    this.args = const HomePlansPaymentMethodRouteArgs(),
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return BlocProvider<HomePlansPaymentMethodBloc>(
      create: (_) => HomePlansPaymentMethodBloc(
        repository: HomePlansPaymentMethodRepositoryImpl(),
      )..add(
          HomePlansPaymentMethodStarted(
            subscriberType: args.subscriberType,
            amount: args.amount,
            vatNote: args.vatNote,
            phoneNumber: args.phoneNumber,
            selectedItems: args.selectedItems,
            promoCodes: args.promoCodes,
            forceNow: args.forceNow,
            selectedBeginDate: args.selectedBeginDate,
          ),
        ),
      child: const HomePlansPaymentMethodView(),
    );
  }
}
