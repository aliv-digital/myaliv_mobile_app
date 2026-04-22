import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/models/invoice_item.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/theme/review_invoice_postpaid_theme.dart';

class InvoiceTile extends StatelessWidget {
  final InvoiceItem invoice;
  final VoidCallback onTap;
  final bool isDownloading;

  const InvoiceTile({
    super.key,
    required this.invoice,
    required this.onTap,
    this.isDownloading = false,
  });

  String _formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ReviewInvoicePostpaidTheme.cardBg,
      borderRadius: BorderRadius.circular(ReviewInvoicePostpaidTheme.radius),
      child: InkWell(
        onTap: isDownloading ? null : onTap,
        borderRadius: BorderRadius.circular(ReviewInvoicePostpaidTheme.radius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNo,
                      style: ReviewInvoicePostpaidTheme.invoiceNo(context),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _MetaBlock(
                          label: 'invoice date',
                          value: _formatDate(invoice.invoiceDate),
                        ),
                        const SizedBox(width: 16),
                        _MetaBlock(
                          label: 'due date',
                          value: _formatDate(invoice.dueDate),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isDownloading)
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    SvgPicture.asset(
                      ReviewInvoicePostpaidAssets.pdfSvg,
                      width: 32,
                      height: 32,
                    ),
                  const SizedBox(height: 14),
                  Text(
                    '${invoice.currencySymbol}${invoice.amount.toStringAsFixed(2)}',
                    style: ReviewInvoicePostpaidTheme.amountStyle(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  final String label;
  final String value;

  const _MetaBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ReviewInvoicePostpaidTheme.metaLabel(context)),
        const SizedBox(height: 2),
        Text(value, style: ReviewInvoicePostpaidTheme.metaValue(context)),
      ],
    );
  }
}
