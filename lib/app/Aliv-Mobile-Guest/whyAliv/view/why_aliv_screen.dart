import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import '../../../../resources/widgets/default_app_bar.dart';
import '../bloc/why_aliv_bloc.dart';
import '../bloc/why_aliv_event.dart';
import '../bloc/why_aliv_state.dart';
import '../data/string_constants.dart';
import '../repository/why_aliv_repository.dart';
import '../theme/why_aliv_theme.dart';

class WhyAlivScreen extends StatelessWidget {
  const WhyAlivScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WhyAlivBloc(repository: const WhyAlivRepository())
        ..add(const WhyAlivStarted()),
      child: const _WhyAlivView(),
    );
  }
}

class _WhyAlivView extends StatelessWidget {
  const _WhyAlivView();

  static const List<({String title, String body})> _sections = [
    (
      title: '1. The Bahamas’ Fastest LTE',
      body:
          'ALIV powers The Bahamas’ fastest LTE network, recognized by Ookla® 5 times in 2025 alone for award-winning performance. Enjoy seamless streaming, effortless browsing, and reliable connectivity at your fingertips.',
    ),
    (
      title: '2. More Rewards When You Switch',
      body:
          'Bring your number to ALIV and unlock free bonus data, wallet credits, discounts, and a complimentary 30-day plan packed with value. No hassle, all reward.',
    ),
    (
      title: '3. Talk & Text Freely (Prepaid)',
      body:
          'Enjoy unlimited local calls, texts and unlimited WhatsApp messaging on any prepaid plan. Easy, reliable communication for both every day use and emergencies.',
    ),
    (
      title: '4. Roam Easy, Save More',
      body:
          'Stay online across the USA, Canada, the Caribbean, and Europe with ALIV’s affordable 7- or 14-day roaming plans. Get reliable coverage, total convenience, and peace of mind-powered by a growing network of 180+ global partners.',
    ),
    (
      title: '5. Total Account Control in One Powerful App',
      body:
          'With the MyALIV app, you can top up, pay bills, track usage, and earn rewards all in one place. It’s fast, simple, and built to put you in control of your account.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: HexColor.fromHex('#F1F2FA'),
      body: SafeArea(

        child: BlocListener<WhyAlivBloc, WhyAlivState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status &&
              curr.status == WhyAlivStatus.failure,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'Something went wrong',
                  style: WhyAlivTheme.snackBarText,
                ),
              ),
            );
          },
          child: Column(
            children: [
              DefaultAppBar(
                backgroundColor: HexColor.fromHex('FF645D9C'),
                title: WhyAlivStrings.whyAlivAppbarTitle,
                onBack: () {
                  context.pop();
                },
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                        child: BlocBuilder<WhyAlivBloc, WhyAlivState>(
                          builder: (context, state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (int i = 0; i < _sections.length; i++) ...[
                                  Text(
                                    _sections[i].title,
                                    style: WhyAlivTheme.headingOne,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _sections[i].body,
                                    style: WhyAlivTheme.body,
                                  ),
                                  if (i != _sections.length - 1)
                                    const SizedBox(height: 32),
                                ],
                              ],
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
