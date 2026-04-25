import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/invoice.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import '../utils/providers.dart';
import '../widgets/reru_card.dart';
import '../widgets/status_badge.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesProvider(_statusFilter));

    return Scaffold(
      appBar: AppBar(title: const Text('Invoices')),
      body: Column(
        children: [
          _FilterBar(
            selected: _statusFilter,
            onChanged: (v) => setState(() => _statusFilter = v),
          ),
          Expanded(
            child: invoicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Could not load invoices', style: AppTextStyles.body),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => ref.refresh(invoicesProvider(_statusFilter)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (invoices) => invoices.isEmpty
                  ? _EmptyState(filter: _statusFilter)
                  : _InvoiceList(invoices: invoices),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;
  const _FilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filters = [
      (null, 'All'),
      ('pending', 'Pending'),
      ('paid', 'Paid'),
      ('overdue', 'Overdue'),
    ];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = selected == f.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(f.$2),
                selected: isSelected,
                onSelected: (_) => onChanged(f.$1),
                selectedColor: AppColors.green100,
                checkmarkColor: AppColors.green700,
                labelStyle: AppTextStyles.label.copyWith(
                  color: isSelected ? AppColors.green700 : AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _InvoiceList extends StatelessWidget {
  final List<Invoice> invoices;
  const _InvoiceList({required this.invoices});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _InvoiceTile(invoice: invoices[i]),
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  final Invoice invoice;
  const _InvoiceTile({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/invoices/${invoice.id}'),
      borderRadius: BorderRadius.circular(16),
      child: ReruCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.green100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_outlined, color: AppColors.green700, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(invoice.id, style: AppTextStyles.cardTitle),
                  Text(formatDate(invoice.date), style: AppTextStyles.caption),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(invoice.total),
                  style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                StatusBadge(invoice.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String? filter;
  const _EmptyState({this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            filter != null ? 'No $filter invoices' : 'No invoices yet',
            style: AppTextStyles.cardTitle,
          ),
        ],
      ),
    );
  }
}
