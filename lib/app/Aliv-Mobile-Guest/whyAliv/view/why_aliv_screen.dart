
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/whyAliv/widgets/app_bar.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/whyAliv/widgets/heading_one.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/whyAliv/widgets/heading_two.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/whyAliv/widgets/text_body.dart';
import '../bloc/why_aliv_bloc.dart';
import '../bloc/why_aliv_event.dart';
import '../bloc/why_aliv_state.dart';
import '../data/string_constants.dart';
import '../repository/why_aliv_repository.dart';

class WhyAlivScreen extends StatelessWidget {
  const WhyAlivScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WhyAlivBloc(
          repository: const WhyAlivRepository()
      )..add(const WhyAlivStarted()),
      child: const _WhyAlivView(),
    );
  }
}

class _WhyAlivView extends StatelessWidget {
  const _WhyAlivView();

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
      body: SafeArea(
        child: BlocListener<WhyAlivBloc, WhyAlivState>(
          listenWhen: (prev, curr) => prev.status != curr.status && curr.status == WhyAlivStatus.failure,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'Something went wrong',
                ),
              ),
            );
          },
          child: Column(
            children: [
              WhyAlivAppBar(
                title: WhyAlivStrings.whyAlivAppbarTitle,
                onBack: () {},
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
                        child: BlocBuilder<WhyAlivBloc, WhyAlivState>(
                          builder: (context, state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HeadingOne(text: WhyAlivStrings.whyAlivHeading1),
                                const SizedBox(height: 12),
                                TextBody(
                                  text: WhyAlivStrings.whyAlivSubheading1,
                                ),
                                const SizedBox(height: 26),
                                TextBody(text: WhyAlivStrings.whyAlivBody1),
                                const SizedBox(height: 30),
                                HeadingTwo(text: WhyAlivStrings.whyAlivHeading2),
                                const SizedBox(height: 12),
                                TextBody(text: WhyAlivStrings.whyAlivBody2a),
                                const SizedBox(height: 18),
                                TextBody(text: WhyAlivStrings.whyAlivBody2b),
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





