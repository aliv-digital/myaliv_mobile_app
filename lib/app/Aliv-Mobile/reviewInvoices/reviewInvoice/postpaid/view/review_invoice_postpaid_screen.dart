import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../resources/widgets/default_app_bar.dart';
import '../bloc/review_invoice_postpaid_bloc.dart';
import '../bloc/review_invoice_postpaid_event.dart';
import '../bloc/review_invoice_postpaid_state.dart';
import '../repository/review_invoice_postpaid_repository.dart';
import '../theme/review_invoice_postpaid_theme.dart';
import '../widgets/invoice_tile.dart';

class ReviewInvoicePostpaidScreen extends StatelessWidget {
  const ReviewInvoicePostpaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReviewInvoicePostpaidBloc(
        repository: ReviewInvoicePostpaidRepositoryImpl(),
      )..add(const ReviewInvoicePostpaidStarted()),
      child: const _ReviewInvoicePostpaidView(),
    );
  }
}

class _ReviewInvoicePostpaidView extends StatelessWidget {
  const _ReviewInvoicePostpaidView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReviewInvoicePostpaidTheme.pageBg,
      body: BlocConsumer<ReviewInvoicePostpaidBloc, ReviewInvoicePostpaidState>(
        listenWhen: (prev, curr) =>
        prev.lastPressed != curr.lastPressed && curr.lastPressed != null,
        listener: (context, state) {
          //  Future hook: tapped invoice -> state.lastPressed
        },
        builder: (context, state) {
          if (state.status == ReviewInvoicePostpaidStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ReviewInvoicePostpaidStatus.failure) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Something went wrong',
                style: ReviewInvoicePostpaidTheme.metaValue(context),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              //  Sliver 1: DefaultAppBar inside scroll view
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: DefaultAppBar(
                    title: 'review invoices',
                    backgroundColor: ReviewInvoicePostpaidTheme.appBarColor,
                  ),
                ),
              ),

              //  Sliver 2: top spacing below appbar
              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              //  Sliver 3: invoice list
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: SliverList.separated(
                  itemCount: state.invoices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final invoice = state.invoices[index];
                    return InvoiceTile(
                      invoice: invoice,
                      onTap: () => context
                          .read<ReviewInvoicePostpaidBloc>()
                          .add(PostpaidInvoicePressed(invoice)),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
