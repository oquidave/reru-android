import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import '../utils/providers.dart';
import '../widgets/reru_card.dart';
import '../widgets/status_badge.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  final String invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceAsync = ref.watch(invoiceDetailProvider(invoiceId));

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice')),
      body: invoiceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Invoice not found', style: AppTextStyles.body)),
        data: (invoice) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ReruCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(invoice.id, style: AppTextStyles.h2),
                      StatusBadge(invoice.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(formatDate(invoice.date), style: AppTextStyles.caption),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  _LineItem(label: 'Plan', value: invoice.plan == 'monthly' ? 'Monthly' : 'Annual'),
                  const SizedBox(height: 8),
                  _LineItem(label: 'Unit price', value: formatCurrency(invoice.unitPrice)),
                  const SizedBox(height: 8),
                  _LineItem(label: 'Qty', value: '${invoice.qty}'),
                  const SizedBox(height: 8),
                  _LineItem(label: 'Subtotal', value: formatCurrency(invoice.subtotal)),
                  const SizedBox(height: 8),
                  _LineItem(label: 'Tax', value: formatCurrency(invoice.tax)),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: AppTextStyles.cardTitle),
                      Text(
                        formatCurrency(invoice.total),
                        style: AppTextStyles.h2.copyWith(color: AppColors.green700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (invoice.isPaid) ...[
              const SizedBox(height: 12),
              ReruCard(
                backgroundColor: AppColors.successBg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.successText, size: 18),
                        const SizedBox(width: 8),
                        Text('Payment received', style: AppTextStyles.label.copyWith(color: AppColors.successText)),
                      ],
                    ),
                    if (invoice.paidAt != null) ...[
                      const SizedBox(height: 4),
                      Text(formatDate(invoice.paidAt!), style: AppTextStyles.caption),
                    ],
                    if (invoice.paymentMethod != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        invoice.paymentMethod!.replaceAll('_', ' ').toUpperCase(),
                        style: AppTextStyles.caption,
                      ),
                    ],
                    if (invoice.paymentRef != null) ...[
                      const SizedBox(height: 4),
                      Text('Ref: ${invoice.paymentRef}', style: AppTextStyles.caption),
                    ],
                  ],
                ),
              ),
            ],
            if (!invoice.isPaid) ...[
              const SizedBox(height: 16),
              ReruCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How to pay', style: AppTextStyles.cardTitle),
                    const SizedBox(height: 8),
                    _PaymentInstructions(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  final String label;
  final String value;
  const _LineItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body),
        Text(value, style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}

class _PaymentInstructions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const steps = [
      ('MTN MoMo', 'Dial *165# → Send money → Enter business number'),
      ('Airtel Money', 'Dial *185# → Make payment → Enter business number'),
      ('Bank transfer', 'Contact Brian Twesigye: 0778527802'),
    ];
    return Column(
      children: steps.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 6, right: 8),
              decoration: const BoxDecoration(
                color: AppColors.green700,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.$1, style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
                  Text(s.$2, style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
