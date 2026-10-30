import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_bottom_stripes.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
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
      create: (_) =>
          WhyAlivBloc(repository: const WhyAlivRepository())
            ..add(const WhyAlivStarted()),
      child: const _WhyAlivView(),
    );
  }
}

class _WhyAlivView extends StatelessWidget {
  const _WhyAlivView();

  static const List<({String title, String body})> _sections = [
    (
      title: 'The Bahamas’\nFastest LTE',
      body:
          'ALIV powers The Bahamas’ fastest LTE network, recognized by Ookla® 5 times in 2025 alone for award-winning performance. Enjoy seamless streaming, effortless browsing, and reliable connectivity at your fingertips.',
    ),
    (
      title: 'More Rewards When You Switch',
      body:
          'Bring your number to ALIV and unlock free bonus data, wallet credits, discounts, and a complimentary 30-day plan packed with value. No hassle, all reward.',
    ),
    (
      title: 'Talk & Text Freely (Prepaid)',
      body:
          'Enjoy unlimited local calls, texts and unlimited WhatsApp messaging on any prepaid plan. Easy, reliable communication for both everyday use and emergencies.',
    ),
    (
      title: 'Roam Easy, Save More',
      body:
          'Stay online across the USA, Canada, the Caribbean, and Europe with ALIV’s affordable 7- or 14-day roaming plans. Get reliable coverage, total convenience, and peace of mind—powered by a growing network of 180+ global partners.',
    ),
    (
      title: 'Total Account Control in One Powerful App',
      body:
          'With the MyALIV app, you can top-up, pay bills, track usage, and earn rewards all in one place. It’s fast, simple, and built to put you in control of your account.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WhyAlivTheme.backgroundColor,
      body: SafeArea(
        top: false,
        child: BlocListener<WhyAlivBloc, WhyAlivState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status &&
              curr.status == WhyAlivStatus.failure,
          listener: (context, state) {
            final sms = state.errorMessage ?? 'Something went wrong';
            AppToast.show(message: sms);
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text(
            //       state.errorMessage ?? 'Something went wrong',
            //       style: WhyAlivTheme.snackBarText,
            //     ),
            //   ),
            // );
          },
          child: Column(
            children: [
              DefaultAppBar(
                backgroundColor: WhyAlivTheme.appBarColor,
                title: WhyAlivStrings.whyAlivAppbarTitle,
                onBack: () {
                  context.pop();
                },
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: BlocBuilder<WhyAlivBloc, WhyAlivState>(
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _WhyAlivHero(
                                title: _sections.first.title,
                                body: _sections.first.body,
                              ),
                              for (int i = 1; i < _sections.length; i++)
                                _WhyAlivSection(
                                  number: i + 1,
                                  title: _sections[i].title,
                                  body: _sections[i].body,
                                  backgroundColor: i.isOdd
                                      ? WhyAlivTheme.alternateSectionColor
                                      : WhyAlivTheme.backgroundColor,
                                ),
                              const BottomStripes(),
                            ],
                          );
                        },
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

class _WhyAlivHero extends StatelessWidget {
  const _WhyAlivHero({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WhyAlivTheme.heroPadding,
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: WhyAlivTheme.heroImageWidth,
            ),
            child: AspectRatio(
              aspectRatio:
                  WhyAlivTheme.heroImageWidth / WhyAlivTheme.heroImageHeight,
              child: Image.asset(
                AssetConstant.whyAlivModelPNG,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: WhyAlivTheme.imageToHeadingGap),
          Text(
            title,
            textAlign: TextAlign.center,
            style: WhyAlivTheme.headingOne,
          ),
          const SizedBox(height: WhyAlivTheme.headingToBodyGap),
          Text(body, textAlign: TextAlign.center, style: WhyAlivTheme.body),
        ],
      ),
    );
  }
}

class _WhyAlivSection extends StatelessWidget {
  const _WhyAlivSection({
    required this.number,
    required this.title,
    required this.body,
    required this.backgroundColor,
  });

  final int number;
  final String title;
  final String body;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Padding(
        padding: WhyAlivTheme.sectionPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$number.', style: WhyAlivTheme.headingTwo),
                const SizedBox(width: WhyAlivTheme.sectionNumberGap),
                Expanded(child: Text(title, style: WhyAlivTheme.headingTwo)),
              ],
            ),
            const SizedBox(height: WhyAlivTheme.headingToBodyGap),
            Text(body, style: WhyAlivTheme.body),
          ],
        ),
      ),
    );
  }
}
