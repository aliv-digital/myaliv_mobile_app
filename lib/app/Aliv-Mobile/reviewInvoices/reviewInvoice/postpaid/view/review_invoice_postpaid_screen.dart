import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/cubit/review_invoice_postpaid_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/cubit/review_invoice_postpaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/theme/review_invoice_postpaid_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/widgets/invoice_tile.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/widgets/invoice_tile_skeleton.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class ReviewInvoicePostpaidScreen extends StatelessWidget {
  const ReviewInvoicePostpaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => instance<ReviewInvoicePostpaidCubit>()..loadInvoices(),
      child: const _ReviewInvoicePostpaidView(),
    );
  }
}

class _ReviewInvoicePostpaidView extends StatelessWidget {
  const _ReviewInvoicePostpaidView();

  Widget _buildContent(BuildContext context, ReviewInvoicePostpaidState state) {
    // Loading state - show skeleton
    if (state.status == ReviewInvoiceStatus.loading) {
      return const SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: InvoiceTileSkeletonList(),
      );
    }

    // Error state
    if (state.status == ReviewInvoiceStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.errorMessage ?? 'Something went wrong',
                style: ReviewInvoicePostpaidTheme.metaValue(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    context.read<ReviewInvoicePostpaidCubit>().loadInvoices(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (state.invoices.isEmpty) {
      return Center(
        child: Text(
          'No invoices found',
          style: ReviewInvoicePostpaidTheme.metaValue(context),
        ),
      );
    }

    // Success state - show invoice list
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 20, 20),
          sliver: SliverList.separated(
            itemCount: state.invoices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final invoice = state.invoices[index];
              final isDownloading =
                  state.isDownloadingInvoice(invoice.invoiceId);

              return InvoiceTile(
                invoice: invoice,
                isDownloading: isDownloading,
                onTap: () => context
                    .read<ReviewInvoicePostpaidCubit>()
                    .downloadAndOpenPdf(invoice),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReviewInvoicePostpaidTheme.pageBg,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<ReviewInvoicePostpaidCubit,
            ReviewInvoicePostpaidState>(
          listenWhen: (prev, curr) =>
              prev.downloadError != curr.downloadError &&
              curr.downloadError != null,
          listener: (context, state) {
            // Show error snackbar when download fails
            if (state.downloadError != null) {
              AppToast.show(message: state.downloadError!.toString(),type: ToastType.error);
              // ScaffoldMessenger.of(context)
              //   ..hideCurrentSnackBar()
              //   ..showSnackBar(
              //     SnackBar(
              //       content: Text(state.downloadError!),
              //       behavior: SnackBarBehavior.floating,
              //     ),
              //   );
              context.read<ReviewInvoicePostpaidCubit>().clearDownloadError();
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Fixed / sticky top appbar
                DefaultAppBar(
                  title: 'review invoices',
                  backgroundColor: ReviewInvoicePostpaidTheme.appBarColor,
                ),

                const SizedBox(height: 14),

                // Content area
                Expanded(
                  child: _buildContent(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
