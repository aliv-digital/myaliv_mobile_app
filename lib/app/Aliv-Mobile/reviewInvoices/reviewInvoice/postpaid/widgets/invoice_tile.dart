import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../models/invoice_item.dart';
import '../theme/review_invoice_postpaid_theme.dart';

class InvoiceTile extends StatelessWidget {
  final InvoiceItem invoice;
  final VoidCallback onTap;

  const InvoiceTile({
    super.key,
    required this.invoice,
    required this.onTap,
  });

  String _formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ReviewInvoicePostpaidTheme.cardBg,
      borderRadius: BorderRadius.circular(ReviewInvoicePostpaidTheme.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ReviewInvoicePostpaidTheme.radius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(invoice.invoiceNo, style: ReviewInvoicePostpaidTheme.invoiceNo(context)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _MetaBlock(label: 'invoice date', value: _formatDate(invoice.invoiceDate)),
                        const SizedBox(width: 18),
                        _MetaBlock(label: 'due date', value: _formatDate(invoice.dueDate)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    ReviewInvoicePostpaidAssets.pdfSvg,
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'PDF',
                    style: TextStyle(
                      fontFamily: ReviewInvoicePostpaidTheme.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
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
